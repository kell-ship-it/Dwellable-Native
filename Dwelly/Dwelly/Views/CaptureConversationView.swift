import SwiftUI
import UIKit
import Combine

/// The real "Dwelly Responds" conversation (Figma `jBOzv1vO2C2DSMePqRl4c4`, node 38:246,
/// "Scenario 2: Dwelly Responds") — the piece of P1 Capture that was blocked on T-168
/// (Shared LLM Proxy Service) until it existed. Up to 3 of Dwelly's responses per the
/// locked design's "Response N of 3" counter, then the conversation closes and the whole
/// exchange is saved as one moment.
///
/// Scoped to the typed-text entry path only (CaptureView's compose pill → here). Voice
/// capture still goes through the separate, unchanged ReviewView save path — folding
/// voice into this same conversational flow is real additional scope, not done here.
struct CaptureConversationView: View {
    let userId: String
    let userEmail: String?
    let syncManager: SyncManager
    // Nov 17 2026 merge (Kell's direct call): this screen used to only ever be reached
    // AFTER a separate screen, `CaptureView`, had already collected the opening
    // message -- two different SwiftUI views, two separate composers/mic handlers,
    // crossfaded to look like one continuous conversation. That split is exactly why
    // the same "voice should preview before sending" bug had to be fixed twice in one
    // session (once here, once there) before anyone noticed the two screens had
    // drifted apart. `CaptureView` is deleted; this is now the one real screen for
    // the whole capture flow, start to finish. Empty (the default) means there's no
    // preset opening message yet -- the idle "What's stirring in you today?" /
    // topic-card state renders instead (see `turns.isEmpty` branches in `body`) until
    // the user's own first message (typed, recorded, or a tapped topic card) becomes
    // `turns`' first entry via the same `sendUserTurn()`/`selectPromptCard()` every
    // later turn already uses. Non-empty is unchanged: the Today tab's preset-prompt
    // tiles (MainTabView) still open straight into a question, skipping the idle state.
    var initialMessage: String = ""
    // When the conversation is opened already carrying a preset question (MainTabView's
    // Today-tab tiles) or via a tapped topic card, `initialMessage`/the card's title is
    // a question Dwelly is posing TO the user ("Any stillness stand out to you?"), not
    // something the user is saying to Dwelly — sending it as a user turn made the model
    // answer its own question in the first person instead of inviting a real answer
    // (caught by Kell live, Nov 9 2026). Defaults to false for the free-typed-text path.
    var initialMessageIsPrompt: Bool = false
    // The mandatory onboarding first-capture (OnboardingCoordinatorView, presented
    // with .interactiveDismissDisabled()) has nowhere to go "back" TO — there's no
    // prior screen in onboarding for this chevron to return to, confirmed by Kell
    // (Nov 10 2026) as the one thing still wrong after everything else in this
    // screen. Defaults to false for every other CaptureView call site, where the
    // back chevron is correct.
    var isOnboarding: Bool = false
    var onMomentSaved: (() -> Void)?
    // Kell's direct ask (Nov 16 2026): once you've tapped "Open" on the just-saved
    // journal card, the back chevron INSIDE that journal entry shouldn't land you
    // back in the chat you just finished -- you're done with capture at that
    // point, so it should take you all the way back to the Entries tab instead.
    // Post-onboarding only (hence a separate param from `onMomentSaved`, not a
    // repurposing of it) -- onboarding's own first-ever capture still needs its
    // existing `completeOnboarding()` hand-off untouched, not a tab switch that
    // doesn't even apply yet (the tab bar isn't reachable until onboarding ends).
    // Falls back to the old plain-dismiss-into-the-chat behavior when nil (every
    // call site that hasn't wired this yet, e.g. the legacy MomentsListView push).
    var onFinishedViewingJournal: (() -> Void)?

    @Environment(\.apiClient) private var apiClient
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Fix #1 (prompt-selection -> thread handoff), now owned directly by this screen
    // since the Nov 17 2026 merge folded the topic-card grid in from the deleted
    // `CaptureView` -- the tapped card's `.matchedGeometryEffect` and the resulting
    // first assistant bubble's own both key into this ONE namespace, letting
    // SwiftUI interpolate between them continuously within this same view, not
    // synced across two separate screens via passed-in params like before.
    // `selectedPromptTitle` drives the fade of the OTHER (untapped) cards.
    @Namespace private var promptTransition
    @State private var selectedPromptTitle: String?
    // T-271 (Nov 17 2026): the journal-preview card's own namespace for its
    // "Open" morph -- same technique as `promptTransition` above, just for the
    // opposite end of this screen's life. Kell's explicit call when this ticket
    // was raised: the card itself should expand to BECOME the full journal
    // entry, not just push a new screen on top of it.
    @Namespace private var journalMorph
    // Model-download + idle-state fields merged in from `CaptureView` (Nov 17 2026) --
    // see `modelDownloadOverlay`/`startModelDownload`/`topicCards` below.
    @State private var isDownloadingModel = false
    @State private var downloadProgress: Double = 0.0
    @State private var downloadFailed = false
    @State private var progressTimer: Timer?
    @State private var spinnerRotation: Double = 0
    @Environment(\.dismiss) private var dismiss
    @FocusState private var inputFocused: Bool
    // Voice was scoped out of this screen entirely when it was first built ("Voice
    // capture still goes through the separate, unchanged ReviewView save path —
    // folding voice into this same conversational flow is real additional scope, not
    // done here"). Kell asked for it back in (Nov 10 2026): voice should be available
    // for every reply in the conversation, not just CaptureView's own first entry.
    // Reuses the same AudioRecordingManager/TranscriptionManager pattern CaptureView
    // already uses — record, transcribe, then feed the transcript through the exact
    // same sendUserTurn() path typed text already uses.
    @StateObject private var audioManager = AudioRecordingManager()

    private struct Turn: Identifiable {
        let id = UUID()
        let role: LLMMessage.Role
        let text: String
    }

    // Guards the one-time setup block in `.onAppear` against re-running when this
    // screen reappears after a pushed destination (JournalDetailView) is popped --
    // see that modifier's own comment for the bug this caused.
    @State private var hasInitialized = false
    @State private var turns: [Turn] = []
    @State private var inputText = ""
    @State private var isWaitingForDwelly = false
    @State private var isTranscribingVoice = false
    // T-300 (Nov 17 2026, keyboard->voice transition): `AudioRecordingManager`
    // flips its own `isRecording` on its own internal `DispatchQueue.main.async`
    // hops (often from a background queue first) -- completely detached from
    // any `withAnimation` transaction this screen's button actions set up, so
    // wrapping the call to `audioManager.startRecording()`/`stopRecording()`
    // itself does nothing: the real mutation lands later, outside that
    // transaction, and `unifiedComposeSurface`'s card just snaps to its new
    // size/position with no animation at all. Mirroring it into this plain
    // local `@State` via `.onChange` below -- explicitly re-wrapped in our own
    // `withAnimation` once the change actually lands -- is what the geometry
    // below reads instead of `audioManager.isRecording` directly.
    @State private var isRecordingAnimated = false
    // Bridges the gap between tapping Stop (`audioManager.isRecording` -> false,
    // near-instant) and `isTranscribingVoice` actually becoming true, which only
    // fires once `AVAudioRecorder`'s delegate confirms the file finished writing
    // to disk -- a second, separate async hop. Without this, the capsule's
    // driving condition below would briefly go fully false in that gap, snapping
    // back toward the text editor for a frame or two before immediately
    // re-expanding into the transcribing capsule -- a flicker, not the one
    // continuous capsule Kell asked for. Cleared the moment transcription
    // actually starts (or, failing that, by a short fallback timer -- see
    // `handleRecordTap`'s stop branch -- so a real recorder failure can't leave
    // this stuck true forever).
    @State private var isStoppingToTranscribe = false
    // Component/Typed-Text-Box (node 651:3966) has its own Collapsed/Expanded states
    // once there's typed/transcribed content — Kell caught this missing entirely
    // (Nov 10 2026): no way to grow the compose box for a long reflection. Collapsed
    // is 120pt, Expanded is 524pt -- both FIXED, per the Figma component spec (pulled
    // directly, Nov 10 2026), not computed from screen/keyboard height. Several
    // intermediate attempts at a "fill the screen, keyboard draws in front of it"
    // ChatGPT-style behavior caused repeated real-device bugs and were a departure
    // from this locked spec -- reverted back to it entirely.
    @State private var isComposeExpanded = false
    // Nov 18 2026 (Kell's explicit ask, ChatGPT-style): a fluid downward drag on
    // the chevron handle collapses an expanded composer, or dismisses the
    // keyboard from an already-collapsed one -- never the text content itself.
    // Lives entirely in this one offset, added only to the card's and chevron's
    // own `.position()` y-coordinates (see `unifiedComposeSurface`), reset to 0
    // the instant the gesture ends either way (commit or spring-back). The drag
    // gesture itself is attached ONLY to the chevron button via
    // `.simultaneousGesture`, never to the `TextEditor` -- so native text
    // selection/scrolling inside the editor is completely untouched by this.
    @State private var composeDragOffset: CGFloat = 0
    // Kell's fix (Nov 16 2026): a single shared `audioLevel` scaled by a fixed
    // per-bar random multiplier made every bar move in lockstep -- same instant,
    // just different heights, which reads as "pulsing," not a waveform. Voice
    // Memos' own timeline instead shows a HISTORY of past mic samples, oldest at
    // one end, newest at the other, so speech creates visible, traveling shape
    // as it scrolls through. This ring buffer is that history -- each slot is
    // one real past sample, not a shared instantaneous value.
    private static let waveformBarCount = 24
    @State private var waveformHistory: [CGFloat] = Array(repeating: 0, count: 24)
    // `unifiedComposeSurface` positions itself by hand (`.position()`, not
    // `.safeAreaInset`), so it does NOT get the automatic keyboard-avoidance
    // `.safeAreaInset(edge: .bottom)` gave the old `composePill`/
    // `expandedComposeOverlay` for free -- confirmed live by Kell (Nov 10 2026):
    // with the keyboard up, the collapsed card sat at its no-keyboard position,
    // leaving a dead gap between the box and the keyboard's top edge. Tracking the
    // real keyboard height by hand via `UIResponder` notifications (below) and
    // folding it into that surface's own position math is what `.safeAreaInset`
    // was doing automatically before.
    @State private var keyboardHeight: CGFloat = 0
    // The "Response N of 3" counter hides while the user is actively scrolling the
    // thread and fades back in once scrolling settles — Kell's own suggestion (Nov 10
    // 2026) after flagging it as sitting awkwardly out of line with the header; this
    // also resolved the alignment complaint by moving it into the header's own row
    // instead of a separate one below it.
    @State private var isScrollingNow = false
    @State private var scrollSettleWorkItem: DispatchWorkItem?
    @State private var isSaving = false
    @State private var isSyncPending = false
    @State private var errorMessage: String?
    @State private var savedMoment: Moment?
    @State private var journalMeta: JournalMeta?
    // T-159: tracks whether `journalMeta` above is real synthesis output or the
    // local display-only fallback -- `journalMeta` itself always has SOMETHING
    // (Kell's own call: the inline card must never show without a verse), but
    // only a real success should ever be written to `journal_entries` as
    // `status: "approved"`. A failure persists as `status: "pending"` instead
    // (title/scripture left nil, picked up by the real retry sweep later) rather
    // than writing the fallback copy to the DB as if it were genuine synthesis.
    @State private var journalSynthesisSucceeded = false
    // T-271 (Nov 17 2026): replaces the old `showMomentDetail` +
    // `.navigationDestination` push -- this screen is shown via `fullScreenCover`
    // from MainTabView with no ancestor `NavigationStack` of its own, so that
    // push was a silent no-op in the real app (only ever worked in this file's
    // own `#Preview`, which wraps itself in one). Driving JournalDetailView as a
    // plain overlay sharing `journalMorph`'s namespace with the card both fixes
    // that and gives Kell the morph he asked for.
    @State private var showJournalMorph = false
    // Fix #1, final step: once a prompt card has morphed into its thread bubble,
    // the composer should appear AFTER that settles, not already be sitting there
    // the instant this screen mounts (which would make the morph look like it's
    // racing an already-finished layout). Starts `false` only when this screen was
    // actually opened via a tapped card; every other entry path leaves it `true`
    // from the start, same as before this fix.
    @State private var isComposerRevealed = true
    // Kell's rule (Nov 16 2026): leaving mid-conversation (post-onboarding, before
    // the moment is saved) must ask Save vs. Discard -- it can't just vanish the
    // words someone already spoke. "Save" reuses the exact same `manuallyFinished`
    // path the header's own "Done" button already triggers (same finishAndSave(),
    // same journal-preview UI after it) rather than a second, separate save
    // routine -- this is just another way of saying "I'm done," not a new way to
    // finish. "Discard" is today's old unconditional behavior, now opt-in instead
    // of the only option.
    @State private var showLeaveConfirmation = false

    private let maxResponses = 3

    // T-272: a hard per-turn length cap. Nothing upstream (llm-proxy's
    // DEFAULT_MAX_TOKENS, DAILY_CALL_LIMIT) bounds the size of a single input --
    // the first only caps the model's OUTPUT, the second only counts calls, not
    // size -- so a pasted block of arbitrary length went straight to the LLM
    // uncapped and fully billed. Character count, not a real token count: the
    // actual tokenizer is model/provider-specific and isn't available client-side,
    // so ~4 chars/token is used as a cheap, reliable proxy. 2000 chars lands
    // around ~500 tokens, well under budget with real margin. Figma: E9 --
    // "Message Too Long (Character Cap)" on both the Capture Onboarding and P1b
    // Capture Post-Onboarding pages (node 1188:1198 / 1189:1216, file
    // jBOzv1vO2C2DSMePqRl4c4) -- caption sits below the collapsed compose card,
    // same placement E6's "Reached 10 min" caption uses, not inside the pill
    // (that pattern, per E2/E3, is reserved for replacing EMPTY field content --
    // doesn't apply here since real typed text needs to stay visible/editable).
    private let maxInputLength = 2000
    private var isOverCharacterLimit: Bool { inputText.count > maxInputLength }
    // The prompt-card opening question renders as an assistant turn (see
    // `initialMessageIsPrompt` below) but isn't one of Dwelly's 3 real generated
    // responses — it's the question the user is about to answer, so it's excluded
    // from the count and from the "Response N of 3" header until a real answer lands.
    @State private var openedWithPromptQuestion = false
    private var dwellyResponseCount: Int {
        turns.filter { $0.role == .assistant }.count - (openedWithPromptQuestion ? 1 : 0)
    }
    // Kell's direct ask (Nov 11 2026): post-onboarding conversations need a real way to
    // stop early instead of being forced through exactly 3 responses -- the "Done"
    // button in the header sets this, which this flag folds into the exact same
    // completion path reaching maxResponses already uses (same finishAndSave() call,
    // same journal-preview UI afterward). Onboarding has no such button and never sets
    // this -- it keeps the existing forced-3 behavior unchanged.
    @State private var manuallyFinished = false
    // Kell caught this directly (Nov 11 2026): adding the Done button wasn't enough on
    // its own -- post-onboarding was still silently force-completing at exactly 3
    // responses underneath it, same as onboarding, which is exactly the fixed-count
    // behavior post-onboarding was supposed to diverge from (runs until the user says
    // they're done, not count-capped at all). Onboarding is the ONLY place the 3-count
    // cap still applies -- post-onboarding completes only via manuallyFinished (Done).
    private var isConversationComplete: Bool {
        manuallyFinished || (isOnboarding && dwellyResponseCount >= maxResponses)
    }

    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
    }

    /// Generated once, right after the conversation closes — a title/excerpt/scripture
    /// pairing for the journal-entry card (Figma's closing screen, which Kell confirmed
    /// Nov 9 2026 shows a real titled entry with a scripture pairing, not a plain dump of
    /// what was typed). Ephemeral: `Moment` has no title/scripture columns of its own yet
    /// (that's real P4/Journal schema scope), so this is generated fresh for display here
    /// and not persisted — reopening a saved moment later just shows its plain body.
    private struct JournalMeta {
        let title: String
        let excerpt: String
        // The real synthesized narrative (Nov 11 2026) -- nil only on the
        // hard-failure fallback below, where there's no real synthesis to show.
        let body: String?
        let scriptureQuote: String?
        let scriptureReference: String?
        // LLM-suggested moods (Nov 11 2026) -- empty on the hard-failure fallback,
        // same as `body`.
        let moods: [String]
        // T-127 (rebuilt Nov 17 2026): independent of whether synthesis ran -- gates
        // whether this capture ever reaches DwellerProfileManager/Growth eligibility.
        // Defaults true/nil for the two pre-existing call sites (a real synthesis
        // success, and the hard-LLM-failure fallback, which still has genuine user
        // words behind it even though the model call itself errored) -- only the new
        // below-floor-replacement path below sets this false.
        var formationEligible: Bool = true
        var extractedFacts: String? = nil
    }

    /// Kept short and narrow on purpose — this is a first real wiring of T-168 into a
    /// feature, not a tuned persona. Revisit once there's an actual conversation to judge
    /// tone against. One prompt, used for all 3 responses: the Figma reference Kell sent
    /// (Nov 9, 2026) shows response 3 asking a real follow-up question same as 1 and 2 —
    /// there's no separate "closing tone" response. What actually introduces the journal
    /// hand-off is a distinct, fixed message (`closingMessage` below) that appears AFTER
    /// the 3rd response, not generated by the model at all — see the comment there.
    private let systemPrompt = """
    You are Dwelly, a warm, compassionate companion helping someone reflect honestly on \
    a moment with God today. Respond in 1-2 short sentences. Ask one gentle, Socratic \
    follow-up question that helps them go deeper — don't lecture, don't quote scripture \
    unless it truly fits, don't be clinical.
    """

    // Kell's ask (Nov 2026): pass device-local time/time zone, and whether this is the
    // first reflection of the user's local day (when known), into the existing
    // `systemPrompt` context -- so an early-morning reflection can orient toward the
    // day ahead ("...shape the rest of your day?") instead of defaulting to
    // evening-flavored language, without ever assuming "tonight" or "tomorrow" when
    // it isn't actually known. This is appended as its own system turn, not folded
    // into `systemPrompt` itself, so the base persona prompt stays a plain constant.
    private var timeAwareContext: String {
        let now = Date()
        let timeString = now.formatted(.dateTime.hour().minute())
        let tz = TimeZone.current.identifier
        let dayLine = isFirstReflectionTodayLocally
            ? "This is the user's first reflection today."
            : "The user has already reflected at least once today."
        return """
        Context for this conversation only -- never mention these details directly, \
        just let them quietly shape tone and framing: it is currently \(timeString) \
        in the user's local time zone (\(tz)). \(dayLine) If it's early morning, feel \
        free to gently orient a question toward the day ahead when it genuinely fits \
        (e.g. "How might remembering His faithfulness shape the rest of your day?") -- \
        but never assume it's evening/"tonight" or guess at "tomorrow" unless the \
        user's own words say so first.
        """
    }

    // `true` until this device has recorded a reflection today; checked once on
    // `onAppear` (before this conversation's own capture updates it) so the flag
    // reflects the state BEFORE this conversation, not after. Device-local only --
    // no server round-trip, matching every other piece of local-time awareness here.
    @State private var isFirstReflectionTodayLocally = true
    private static let lastReflectionDateKey = "dwelly.lastLocalReflectionDate"

    /// Shown once, right after the 3rd response, before the journal card — a fixed
    /// string, not an LLM call. Earlier this was LLM-generated and once produced a
    /// generic greeting ("Hi there! I'm here for you...") instead of an actual hand-off,
    /// confirmed live by Kell (Nov 9, 2026) — a line whose only job is "transition into
    /// the journal card" shouldn't depend on model behavior to get right every time, and
    /// the Figma reference itself uses this exact copy. Costs nothing extra to show,
    /// unlike the old approach which spent a whole LLM call on it.
    private let closingMessage = "That makes sense to me. Now, let's go ahead and take what you've shared here and add this to your journal. Feel free to continue processing there."

    // Plain top-to-bottom `VStack` — header, scrolling transcript, then the input/save
    // footer as a normal trailing sibling — rather than the original `ZStack(alignment:
    // .bottom)` that overlaid a separate footer VStack on top of the ScrollView. That
    // overlay structure reproduced the same dead-hit-target bug chased down elsewhere
    // this session (WelcomeView, IntentSelectionView, CaptureView): the compose
    // TextField rendered correctly, in the correct place, but never once took focus on
    // tap — confirmed across many retries and coordinates, both for the TextField and
    // (separately) the Send button when there was already text to send. A ScrollView
    // z-stacked under another interactive view, instead of laid out as a sibling above
    // it, is the common thread in this whole family of bugs. Root cause not fully
    // understood — see WelcomeView's comment for the fuller account.
    // Height the floating header (chevron/rock icon, "Response N of 3" all in one row
    // now) occupies, including its own top padding — used both to inset the
    // ScrollView's content (so the first bubble doesn't start underneath the header)
    // and to size the fade behind it. Kell caught (Nov 10 2026) the counter sitting
    // out of line with the rock icon in its own row below — it's one row now, so this
    // no longer varies by whether the counter is showing.
    private let headerHeight: CGFloat = 62

    // `unifiedComposeSurface` (Nov 10 2026 rebuild) needs the device's REAL top/
    // bottom safe-area insets to compute its full-bleed expanded frame and its
    // collapsed position -- but it has to read them this way, not via a
    // `GeometryReader`'s `proxy.safeAreaInsets`. This screen's outer `ZStack`
    // already has `.ignoresSafeArea()` applied (for `Theme.background`), and once
    // ANY ancestor in the chain ignores the safe area, every `GeometryReader`
    // further down reports its insets as already-consumed -- i.e. 0 -- regardless
    // of whether that specific reader itself calls `.ignoresSafeArea()`. Confirmed
    // empirically: the collapse chevron kept landing under the status bar no
    // matter what padding math was tried against `proxy.safeAreaInsets.top`,
    // because that number was always 0 by the time it reached this subtree. Going
    // straight to the key window's own `safeAreaInsets` sidesteps that entirely.
    private var deviceSafeAreaInsets: UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: \.isKeyWindow)?
            .safeAreaInsets ?? .zero
    }

    // `GeometryReader.proxy.size` is ALSO unreliable here, for the same family of
    // reason as `deviceSafeAreaInsets` above -- confirmed Nov 10 2026 with a
    // temporary on-screen readout showing `proxy.size.height` reporting 778pt on a
    // device whose true screen height is ~874pt, a ~96pt shortfall that tracked
    // almost exactly with this screen's OTHER views' own `.safeAreaInset` usage
    // elsewhere in the same ancestor `ZStack`. SwiftUI's safe-area bookkeeping
    // isn't cleanly scoped per-sibling; a `.safeAreaInset` used by one sibling can
    // still shrink what a `GeometryReader` elsewhere in the same tree reports. The
    // key window's own `bounds.size` sidesteps that exactly like
    // `deviceSafeAreaInsets` does for insets.
    private var deviceScreenSize: CGSize {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: \.isKeyWindow)?
            .bounds.size ?? .zero
    }

    // Nov 18 2026 (Kell's explicit ChatGPT-style spec, superseding the prior
    // fixed-120pt requirement): the collapsed composer's height is no longer a
    // constant -- it measures the REAL wrapped height of `inputText` against
    // the exact content width the `TextEditor` renders at, so an empty or
    // short draft stays slim (ChatGPT-style), and the box only grows as
    // actual wrapped lines or explicit newlines demand more room, shrinking
    // right back down as text is deleted. Same font/size the `TextEditor`
    // itself uses below, so this measurement and the editor's own real
    // layout agree. `NSString.boundingRect` (not a live `GeometryReader` on
    // the actual rendered text) is deliberate -- a reader would need the text
    // to already be laid out once to report back, which is exactly the kind
    // of one-frame-late feedback loop that produced visible jumps elsewhere
    // in this same screen's history; measuring the string directly is
    // synchronous and available in the same render pass that decides the
    // frame.
    private let composeEditorFont = UIFont.systemFont(ofSize: 13)
    // Cap -- past this many lines' worth of height, the `TextEditor`'s own
    // `.clipped()` + native internal scrolling (unchanged, already there)
    // takes over instead of the card growing further; matches Kell's "capped
    // about 5-6 lines" ask.
    private let composeMaxVisibleLines: CGFloat = 6

    private func composeTextContentHeight(for text: String, width: CGFloat) -> CGFloat {
        guard width > 0 else { return ceil(composeEditorFont.lineHeight) }
        // At least one line's worth even when empty -- there is always a
        // caret/placeholder row to show, never a zero-height box.
        let measured = text.isEmpty ? "A" : text
        let constraint = CGSize(width: width, height: .greatestFiniteMagnitude)
        let bounds = (measured as NSString).boundingRect(
            with: constraint,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: composeEditorFont],
            context: nil
        )
        let singleLine = ceil(composeEditorFont.lineHeight)
        let capped = ceil(composeEditorFont.lineHeight * composeMaxVisibleLines)
        return min(max(ceil(bounds.height), singleLine), capped)
    }

    // Shared by `composePill` (the ScrollView-clearance spacer) and
    // `unifiedComposeSurface` (the real floating card) so both agree on
    // exactly the same collapsed height -- computed once, here, rather than
    // each recomputing its own copy and risking the two drifting apart.
    // `collapsedLeadingPadding`/`collapsedTrailingPadding`/`collapsedTopPadding`/
    // `collapsedBottomPadding` MUST match the real `TextEditor`'s own
    // collapsed-state padding exactly (see its padding modifiers below), or
    // this measures a different content width/box than the editor actually
    // renders.
    private var composeCollapsedHeight: CGFloat {
        let collapsedWidth = deviceScreenSize.width - 48
        let collapsedLeadingPadding: CGFloat = 16
        let collapsedTrailingPadding: CGFloat = 44
        let collapsedTopPadding: CGFloat = 16
        let collapsedBottomPadding: CGFloat = 58
        let collapsedTextWidth = collapsedWidth - collapsedLeadingPadding - collapsedTrailingPadding
        let collapsedTextHeight = composeTextContentHeight(for: inputText, width: collapsedTextWidth)
        return collapsedTopPadding + collapsedTextHeight + collapsedBottomPadding
    }

    var body: some View {
            ZStack(alignment: .top) {
                // Content scrolls the full height of the screen, UNDER the floating
                // header below — like ChatGPT/iMessage, not a fixed opaque bar the
                // thread starts beneath. Kell showed a reference video (Nov 10 2026):
                // the top fade needs to reach the very top of the screen, with content
                // visibly passing beneath and fading out as it does, not just a sliver
                // of fade low in the scroll area.
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Nov 17 2026 merge: nothing sent yet -- the idle "What's
                            // stirring in you today?" headline + (onboarding-only)
                            // topic cards, folded in from the deleted `CaptureView`.
                            // Once the first turn lands (typed, recorded, or a tapped
                            // card via `selectPromptCard`), this screen falls through
                            // to the normal thread below -- same screen, no transition
                            // to a different one.
                            if turns.isEmpty {
                                idlePrelude
                                    .transition(.opacity)
                            }
                            ForEach(turns) { turn in
                                turnBubble(
                                    turn,
                                    isFinal: isConversationComplete && turn.id == turns.last?.id,
                                    isPromptOrigin: openedWithPromptQuestion && turn.id == turns.first?.id
                                )
                                .id(turn.id == turns.last?.id ? "journalPreview" : turn.id.uuidString)
                                .transition(.opacity)
                            }
                            if isWaitingForDwelly {
                                Group {
                                    dwellyBadge
                                    ProgressView()
                                        .tint(Theme.gold)
                                        .padding(.leading, 24)
                                        .id("spinner")
                                }
                                .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, headerHeight)
                        .padding(.bottom, 24)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("conversationScroll")).minY)
                            }
                        )
                    }
                    .coordinateSpace(name: "conversationScroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { _ in
                        isScrollingNow = true
                        scrollSettleWorkItem?.cancel()
                        let workItem = DispatchWorkItem { withAnimation { isScrollingNow = false } }
                        scrollSettleWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
                    }
                    // Nov 17 2026: matched to the same `.easeInOut(duration: 0.3)`
                    // curve `sendUserTurn()`/`requestDwellyResponse()` now wrap their
                    // own state changes in, rather than the implicit default spring
                    // `withAnimation {}` used here before -- two different curves
                    // firing at once (content crossfade vs. scroll position) on the
                    // same send was part of why that moment read as disjointed/a
                    // screen swap rather than one continuous motion.
                    .onChange(of: turns.count) { _ in
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                            proxy.scrollTo(turns.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: isWaitingForDwelly) { waiting in
                        if waiting {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                                proxy.scrollTo("spinner", anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isConversationComplete) { complete in
                        if complete {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                                proxy.scrollTo("journalPreview", anchor: .bottom)
                            }
                            Task { await finishAndSave() }
                        }
                    }
                    // `.safeAreaInset(edge: .bottom)` attached directly to the ScrollView
                    // (not to the outer ZStack, which was the first attempt and still left
                    // the mic/send buttons clipped by the keyboard, Kell caught, Nov 10
                    // 2026) -- this is the pattern Apple's own keyboard-avoidance docs show
                    // for a chat-style input bar: attached straight to the scrollable
                    // content, the system correctly shrinks the ScrollView AND keeps this
                    // inset content above the keyboard automatically. The header is a
                    // separate ZStack sibling below, untouched by any of this, so it never
                    // moves for the keyboard either.
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 12) {
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.error)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 28)
                            }

                            if isConversationComplete {
                                // Kell's direct ask: remove this bottom "Continue" button
                                // entirely -- "Open" on the journal card itself
                                // (`journalPreviewContent` below) is now the sole forward
                                // action out of this screen, onboarding included. Having
                                // both a bottom CTA AND an inline "Open" doing the same
                                // thing read as two separate exits for one real action.
                                // The onboarding hand-off this button used to own (opening
                                // `JournalDetailView`, whose own `onDone` finally calls
                                // `onMomentSaved?()`) is unchanged -- it's reached via the
                                // card's "Open" link instead, and from inside the entry via
                                // its own back chevron (see JournalDetailView).
                            } else {
                                if let warningMessage = audioManager.warningMessage {
                                    Text(warningMessage)
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.gold)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                }

                                // `unifiedComposeSurface` (see its own header comment, Nov 18
                                // 2026 update) now mounts unconditionally and owns EVERY state
                                // of this row by itself -- empty, typing, recording,
                                // transcribing, expanded -- via its own `isVoiceCapturing`
                                // branch, which already doesn't care whether `inputText` is
                                // empty. `recordingBar`/`transcribingBar` were the pre-draft-only
                                // versions of that exact same UI (Figma 648:220 / 649:3850);
                                // keeping both live risked the real double-recording-UI bug Kell
                                // caught Nov 17 2026, where this row and the floating surface
                                // drew two overlapping recording bars in the same spot. This row
                                // is now purely a scroll-clearance spacer matching the floating
                                // card's footprint, same as `composePill` always was for the
                                // non-empty case.
                                composePill
                            }
                        }
                        // Fix #1: revealed only after a prompt card's morph settles
                        // (see `isComposerRevealed`'s declaration) -- `1` from the
                        // start for every other entry path.
                        .opacity(isComposerRevealed ? 1 : 0)
                    }
                }

                VStack(spacing: 0) {
                    HStack {
                        // Onboarding keeps its existing behavior unchanged -- no way
                        // back mid-conversation (there's nothing to go back TO), chevron
                        // only once complete, logo always shown. Post-onboarding now
                        // gets a real way out at any point (Kell's direct ask, Nov 11
                        // 2026, after finding there was literally no way to leave this
                        // screen mid-conversation) -- but Kell's follow-up ask (Nov 16
                        // 2026) is that leaving mid-conversation can't just silently
                        // discard the words someone already spoke: tapping back before
                        // the conversation is complete now asks Save vs. Discard
                        // instead of leaving unconditionally. Once already complete
                        // (the moment is saved, the journal card is showing), there's
                        // nothing left to lose by leaving, so the chevron goes back to
                        // being a plain, unprompted exit -- same as before.
                        if !isOnboarding {
                            // Nov 17 2026 merge: before anything's been said, this is
                            // a plain dismiss (nothing to lose, no confirmation needed)
                            // with the same "X" CaptureView's own idle screen used --
                            // not a "Back" out of a conversation, since no conversation
                            // has started yet. Once the first turn lands, this becomes
                            // the existing chevron-left/leave-confirmation behavior.
                            if turns.isEmpty {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.Capture.textPrimary)
                                        .frame(width: 44, height: 44)
                                }
                                .accessibilityLabel("Close")
                            } else {
                                Button(action: {
                                    if isConversationComplete {
                                        onMomentSaved?()
                                        dismiss()
                                    } else {
                                        showLeaveConfirmation = true
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Theme.Capture.textPrimary)
                                        .frame(width: 44, height: 44)
                                }
                                // T-223 sweep: every other back chevron in the app (onboarding's
                                // 6 step screens) already carries this label -- this one and
                                // JournalDetailView's were the two left missing it.
                                .accessibilityLabel("Back")
                            }
                        } else if isConversationComplete {
                            Button(action: { onMomentSaved?(); dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Theme.Capture.textPrimary)
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Back")
                        }
                        // Onboarding-only (Kell, Nov 11 2026, confirmed explicitly): the
                        // "Response N of 3" counter implies a fixed cap post-onboarding
                        // doesn't have -- showing "of 3" there would be a lie now that
                        // it isn't limited. Every other part of this header row and the
                        // conversation itself stays byte-for-byte identical between the
                        // two flows; this and the logo (below) are the only differences.
                        if isOnboarding && !turns.isEmpty {
                            // Shown from the moment the screen opens, even before a
                            // real response lands — Kell confirmed (Nov 10 2026) the
                            // opening-prompt screen shouldn't be missing it while
                            // waiting for an answer. Counts the slot the user's about
                            // to fill, not just completed responses.
                            Text("Response \(max(dwellyResponseCount, 1)) of \(maxResponses)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Theme.Payment.textSupporting)
                                .opacity(isScrollingNow ? 0 : 1)
                                .animation(.easeInOut(duration: 0.2), value: isScrollingNow)
                        }
                        Spacer()
                        // Post-onboarding never shows the logo at all (Kell: "there
                        // should be no logo") -- a real "Done" sits in that exact slot
                        // instead once there's been at least one real exchange, letting
                        // the user end the conversation on their own terms rather than
                        // being forced through all 3 responses. Onboarding is unchanged
                        // -- the logo stays, no early exit exists there.
                        if !isOnboarding {
                            if dwellyResponseCount >= 1 && !isConversationComplete {
                                Button(action: { manuallyFinished = true }) {
                                    Text("Done")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Theme.gold)
                                        .frame(height: 24)
                                }
                            }
                        } else {
                            Image("DwellyRockIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    // Fixed height regardless of which elements are present -- without
                    // this, the row grew from ~24pt to 44pt the moment the back chevron
                    // (its own 44x44 tap target) appeared post-completion, shifting the
                    // counter/logo down. Kell asked (Nov 10 2026) for the counter/logo
                    // row to sit at a fixed height always.
                    .frame(height: 44)
                    // Tighter inset whenever the chevron's own 44pt tap target is
                    // present -- true for the whole post-onboarding conversation now,
                    // not just once complete, now that the chevron shows from the start.
                    .padding(.horizontal, (!isOnboarding || isConversationComplete) ? 16 : 28)
                    .padding(.top, 14)
                    // Kell (Nov 10 2026, reversing his own earlier call once he saw it live):
                    // "Response N of 3" + the rock icon should ALWAYS stay visible, including
                    // while the compose box is expanded -- it should never hide.

                    Spacer(minLength: 0)
                }
                .frame(height: headerHeight)
                .background(
                    LinearGradient(
                        colors: [Theme.background, Theme.background, Theme.background.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: headerHeight + 40)
                    .offset(y: -40)
                    .ignoresSafeArea(edges: .top)
                )
                .allowsHitTesting(true)

                // Nov 10 2026 rebuild: this used to be `if isComposeExpanded { scrim;
                // expandedComposeOverlay }` -- a scrim plus a SECOND, fully separate
                // full-screen view, cross-faded/slid against the collapsed card
                // elsewhere in the tree. Every round of tuning that shape (scrim
                // opacity, transition timing, `.identity`) fixed one symptom and
                // surfaced another, because the shape itself was two screens
                // replacing each other, not one surface changing size. Replaced with
                // `unifiedComposeSurface`: ONE view, always mounted once there's
                // text, whose own container animates between the collapsed card's
                // geometry and full-screen. It's declared last here for the same
                // reason the old overlay was: so it renders in front of the header
                // and scroll content once it grows past the collapsed card's bounds.
                unifiedComposeSurface

                // Merged in from `CaptureView` (Nov 17 2026) -- declared last so it
                // covers everything else, same as that screen's own placement.
                if isDownloadingModel {
                    modelDownloadOverlay
                }

                // T-271: the morph destination -- declared last so it covers
                // everything else once `showJournalMorph` flips. Shares
                // `journalMorph`'s "journalMorphCard" id with the preview card
                // above, so SwiftUI interpolates its frame from the small card's
                // bounds out to full screen instead of swapping in a plain
                // push/cover. `savedMoment` is guaranteed non-nil here -- the
                // "Open" button that sets `showJournalMorph` only exists once
                // `savedMoment` has already landed (see `journalPreviewContent`).
                if showJournalMorph, let savedMoment {
                    JournalDetailView(
                        moment: savedMoment,
                        syncManager: syncManager,
                        meta: journalMeta.map {
                            JournalDisplayMeta(
                                title: $0.title,
                                body: $0.body,
                                scriptureQuote: $0.scriptureQuote,
                                scriptureReference: $0.scriptureReference
                            )
                        },
                        onDone: isOnboarding ? { onMomentSaved?() } : onFinishedViewingJournal
                    )
                    .matchedGeometryEffect(id: "journalMorphCard", in: journalMorph)
                    .transition(.identity)
                    .zIndex(3)
                }
            }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        // `.navigationBarBackButtonHidden` only hides the back button, not the bar's
        // own background — the system nav bar's default fill was showing through as a
        // visible line/edge at the very top of the screen, caught live by Kell twice
        // (Nov 10 2026: still present after `.toolbar(.hidden, for:)` alone). Belt and
        // suspenders: hide the bar itself, force its background and color scheme too,
        // so there's no residual system chrome to show a seam against this screen's
        // full-bleed dark background.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Kell caught this live (Nov 16 2026): popping back from JournalDetailView
            // (pushed via the journal card's "Open" link) re-triggered this whole
            // block -- `.onAppear` fires again when this screen reappears after a
            // pushed destination is popped, not just on first mount. With no guard,
            // that wiped `turns` back down to just the opening message and kicked off
            // a brand-new `requestDwellyResponse()` call, destroying the just-saved,
            // already-complete conversation the user was simply trying to look back
            // at. Runs this initialization exactly once per screen lifetime now.
            guard !hasInitialized else { return }
            hasInitialized = true

            if let last = UserDefaults.standard.object(forKey: Self.lastReflectionDateKey) as? Date {
                isFirstReflectionTodayLocally = !Calendar.current.isDateInToday(last)
            }
            // Nov 17 2026 merge: empty means no preset opening message was handed in
            // (the plain capture entry point) -- leave `turns` empty and let the idle
            // "What's stirring in you today?" / topic-card state render instead (see
            // `body`'s `turns.isEmpty` branches). A tapped topic card seeds `turns`
            // directly via `selectPromptCard()`, not through this `initialMessage`
            // path at all, now that the card and this screen are the same view.
            if !initialMessage.isEmpty {
                if initialMessageIsPrompt {
                    // Dwelly is asking this one, not the user — show it as the opening
                    // assistant turn and wait for the user's real answer instead of
                    // calling the LLM immediately, which previously made Dwelly answer
                    // its own question (caught live by Kell, Nov 9 2026).
                    turns = [Turn(role: .assistant, text: initialMessage)]
                    openedWithPromptQuestion = true
                } else {
                    turns = [Turn(role: .user, text: initialMessage)]
                    Task { await requestDwellyResponse() }
                }
            }
        }
        // `unifiedComposeSurface` needs the REAL, live keyboard height (see
        // `keyboardHeight` above) because it positions itself by hand instead of
        // through `.safeAreaInset`, which used to track the keyboard for free.
        // Reading the notification's own animation duration/curve (rather than a
        // fixed spring) keeps this in lockstep with the system keyboard's actual
        // motion instead of guessing at one.
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            withAnimation(.easeInOut(duration: duration)) {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            withAnimation(.easeInOut(duration: duration)) {
                keyboardHeight = 0
            }
        }
        // T-300 (keyboard->voice transition): mirrors `audioManager.isRecording`
        // into `isRecordingAnimated`, re-wrapping the change in our own
        // `withAnimation` -- see that `@State` declaration's own comment for why
        // this indirection exists at all (the manager flips the real property on
        // its own detached dispatch, so animating the call site does nothing).
        // Placed alongside the keyboard notification handlers above since this
        // is the same kind of problem: an external system's own timeline (there,
        // UIKit's keyboard; here, AVAudioRecorder's start/stop) that this view
        // has to observe and re-animate, not drive directly.
        .onChange(of: audioManager.isRecording) { isRecording in
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                isRecordingAnimated = isRecording
            }
        }
        // Kell's follow-up ask (Nov 16 2026): drop the interactive swipe-to-dismiss
        // tracking this added -- `keyboardWillShow`/`keyboardWillHide` above
        // already cover opening and closing the keyboard; this extra
        // `keyboardWillChangeFrame` listener only mattered for riding frame-by-
        // frame with an in-progress drag-to-dismiss gesture, which isn't wanted
        // here.
        .alert("Save this reflection?", isPresented: $showLeaveConfirmation) {
            Button("Keep Talking", role: .cancel) {}
            Button("Save") { manuallyFinished = true }
            Button("Discard", role: .destructive) {
                onMomentSaved?()
                dismiss()
            }
        } message: {
            Text("You haven't saved this yet. Save it to your journal, or discard it and start over.")
        }
        // Merged in from `CaptureView` (Nov 17 2026) -- backgrounding mid-recording
        // used to only be handled on the old separate first-capture screen; this
        // applies regardless of whether `turns` is empty or not now that it's one
        // screen for the whole flow.
        .onReceive(
            Just(scenePhase)
                .dropFirst()
                .eraseToAnyPublisher(),
            perform: { phase in
                if phase == .background && audioManager.isRecording {
                    HTMLLogManager.shared.log("App backgrounded during recording — stopping", level: "WARNING")
                    audioManager.stopRecording { transcribeIntoTextField() }
                }
            }
        )
    }

    /// Figma's own reference (Kell's screenshots, Nov 9 2026) shows every numbered
    /// response — 1, 2, and 3 alike — in the same card: a faint, uniform border on all
    /// four sides, not the harsh/asymmetric one Kell flagged, and NOT the full-width
    /// text treatment this had briefly become (that was overcorrecting from "fade the
    /// border" to "remove the card on the last one," which wasn't what the design
    /// showed). Width is no longer capped at a fixed point value either — Kell's
    /// specific complaint was the box eating landscape — so it now just respects the
    /// screen's own horizontal padding like the journal card below it does.
    // `isFinal` folds the journal-entry preview into this same bubble, below the
    // closing message text, inside one shared card/border — Kell caught (Nov 10 2026)
    // that a separate card floating right after the closing text read as broken up,
    // and asked for it to live inside the response bubble itself.
    @ViewBuilder
    private func turnBubble(_ turn: Turn, isFinal: Bool = false, isPromptOrigin: Bool = false) -> some View {
        switch turn.role {
        case .user:
            HStack {
                Spacer(minLength: 56)
                Text(turn.text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Theme.Capture.userBubble)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        case .assistant:
            VStack(alignment: .leading, spacing: 8) {
                dwellyBadge
                VStack(alignment: .leading, spacing: 0) {
                    Text(turn.text)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Capture.textBody)
                    // Hidden once the morph starts (T-271) -- `showJournalMorph`
                    // flips inside the same `withAnimation` block the "Open" tap
                    // uses, so removing the card here and mounting the full-screen
                    // overlay elsewhere happen in the same transaction, which is
                    // what lets `matchedGeometryEffect` interpolate between them
                    // instead of just cross-fading two unrelated views.
                    if isFinal && !showJournalMorph {
                        journalPreviewContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Capture.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Capture.cardBorder.opacity(0.4), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            // Fix #1: only this one bubble -- the opening prompt-question turn, and
            // only when it actually came from a tapped topic card -- shares the
            // tapped card's matched-geometry id, so it's the one thing SwiftUI
            // interpolates continuously across the screen switch. Every other
            // bubble (real generated responses, the journal preview) is unrelated
            // to any card and gets no such effect.
            .modifier(PromptOriginMatch(isActive: isPromptOrigin, namespace: promptTransition))
        case .system:
            EmptyView()
        }
    }

    /// The journal-entry preview shown once the conversation closes (Figma close
    /// screen, confirmed against Kell's own screenshot Nov 9/10 2026) — a titled entry
    /// with a scripture pairing and an "Open" link into the saved moment, nested as its
    /// own distinct box INSIDE the closing message's bubble: Kell first flagged this as
    /// a separate card floating below the text (fixed by folding it into the same
    /// outer bubble), then flagged the opposite problem — once nested, it needs its
    /// own inner background/border to read as a preview card, not just more plain text
    /// inside the bubble ("should be another preview box inside of this"). So this
    /// keeps its own background/border, nested inside `turnBubble`'s outer one.
    /// `journalMeta` is generated once, right after close, by a dedicated LLM call
    /// (`generateJournalMeta`); `savedMoment` comes from the auto-save that fires in
    /// parallel — "Open" is disabled until both land.
    private var journalPreviewContent: some View {
        // Exact Component/Journal-Preview-Card spec (Figma node 650:220, pulled via
        // Figma MCP Nov 10 2026) — fill/border/fonts/sizes/14px gap all match verbatim,
        // not approximated, after Kell flagged the card reading as flat black instead
        // of the design's actual warm tone.
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(Date().formatted(date: .abbreviated, time: .omitted).uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Theme.Payment.textSupporting)
                Spacer()
                if let savedMoment {
                    // Kell's call (Nov 17 2026): a gold-outline ghost button read as a
                    // quiet link, not the one real CTA this card has -- filled solid gold
                    // (same Gold CTA Heuristic every other primary action in the app uses)
                    // instead of just an outline + gold text.
                    Button(action: {
                        // T-271: Kell's call -- the card itself should expand to
                        // BECOME the full entry, not have a new screen pushed on
                        // top of it. Matches the 0.3s-ish easeInOut this screen's
                        // other transitions use, just slightly longer since this
                        // one is covering much more distance (card -> full screen).
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.45)) {
                            showJournalMorph = true
                        }
                    }) {
                        Text("Open")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Payment.backgroundPrimary)
                            .frame(width: 60, height: 24)
                    }
                    .background(Theme.gold)
                    .clipShape(Capsule())
                    // `.matchedGeometryEffect` below (on the card's own clipped
                    // frame) is this button's actual morph source -- the
                    // destination half lives in `body`'s outer `ZStack` as a
                    // full-screen `JournalDetailView` sharing the same
                    // `journalMorph` namespace/id, same `PromptOriginMatch`
                    // pattern this file already uses for the prompt-card handoff.
                } else {
                    ProgressView().tint(Theme.gold)
                }
            }

            if let journalMeta {
                Text(journalMeta.title)
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .lineLimit(1)

                Text(journalMeta.excerpt)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Capture.textBody)
                    .fixedSize(horizontal: false, vertical: true)

                if let quote = journalMeta.scriptureQuote, let reference = journalMeta.scriptureReference {
                    Rectangle()
                        .fill(Theme.gold)
                        .frame(height: 1)

                    Text("\u{201C}\(quote)\u{201D} — \(reference)")
                        .font(.system(size: 11, design: .serif))
                        .italic()
                        .foregroundColor(Theme.gold)
                }
            } else {
                HStack(spacing: 8) {
                    ProgressView().tint(Theme.Payment.textSupporting)
                    Text("Preparing your entry...")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Capture.badgeBackground)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Capture.journalCardBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        // T-271: tags this card's own clipped frame (not the top padding below,
        // which isn't part of the card itself) as the morph source. The matching
        // id is applied to `JournalDetailView`'s full-screen overlay below.
        .matchedGeometryEffect(id: "journalMorphCard", in: journalMorph)
        .padding(.top, 16)
        .padding(.top, 16)
    }

    private var combinedBody: String {
        turns
            .filter { $0.role == .user }
            .map(\.text)
            .joined(separator: "\n\n")
    }

    /// Both sides of the conversation, role-labeled -- used ONLY as synthesis context
    /// (Nov 11 2026, real body-synthesis build), never stored or shown directly.
    /// `combinedBody` (user words only) stays what's saved as `moment.body` and shown
    /// as "In your words"/the pending placeholder; the model needs Dwelly's own
    /// questions too to understand the arc of the conversation well enough to write a
    /// real reframed narrative, not just a concatenation of answers.
    private var fullTranscript: String {
        turns
            .map { "\($0.role == .user ? "Me" : "Dwelly"): \($0.text)" }
            .joined(separator: "\n\n")
    }

    private var dwellyBadge: some View {
        HStack(spacing: 6) {
            Circle().fill(Theme.gold).frame(width: 4, height: 4)
            Text("dwelly")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Theme.gold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Theme.Capture.badgeBackground)
        .overlay(Capsule().stroke(Theme.gold, lineWidth: 1.5))
        .clipShape(Capsule())
    }

    // Nov 10 2026 rebuild: this used to hold a second, fully separate card view,
    // cross-faded against `expandedComposeOverlay` (a THIRD, also-separate
    // full-screen view) -- two independent `TextEditor`s bound to the same
    // `$inputText`, swapped via conditional rendering. No matter how the
    // transition/scrim/opacity was tuned, that shape kept producing some form
    // of "two screens replacing each other" glitch, confirmed repeatedly by
    // recording and frame-extracting our own build. The fix was architectural,
    // not a timing tweak -- one `TextEditor`, never unmounted, whose
    // *container* animates size/position/corner-radius. That single surface
    // lives in `unifiedComposeSurface`, floated as its own top-level sibling in
    // `body`'s outer ZStack (so it can span from the collapsed card's position
    // all the way to full-screen).
    //
    // Nov 18 2026: this used to ALSO hold its own separate `TextField` for the
    // empty state (torn down and replaced by `unifiedComposeSurface`'s
    // `TextEditor` the instant `inputText` went non-empty) plus the mic button.
    // That empty/non-empty seam was the actual cause of Kell's "typing changes
    // composer size/position and brings it down" report on his own phone, not
    // just the Simulator -- the same family of bug the Nov 10 rebuild above
    // already fixed once for expanded/collapsed, just left unaddressed for
    // empty/non-empty. `unifiedComposeSurface` now mounts unconditionally and
    // owns the TextEditor, placeholder, and mic/send row for every state, so
    // this is purely a layout spacer now -- reserves the same footprint so the
    // scrolling thread still clears the floating card, renders nothing visible.
    private var composePill: some View {
        // Nov 18 2026: tracks `composeCollapsedHeight` (same value
        // `unifiedComposeSurface` itself sizes to), not a fixed 120pt -- this
        // spacer's only job is reserving exactly enough scroll clearance for
        // whatever height the floating card is ACTUALLY using right now, so a
        // tall multi-line draft doesn't leave the scroll thread's last bubble
        // tucked underneath it, and a slim empty draft doesn't leave a big
        // dead gap above it either.
        Color.clear
            .frame(height: composeCollapsedHeight)
            .padding(.horizontal, 24)
            .padding(.bottom, Theme.Spacing.xxl)
            .animation(.easeOut(duration: 0.18), value: composeCollapsedHeight)
    }

    // The single persistent compose surface -- ONE `TextEditor`, mounted
    // UNCONDITIONALLY (idle/empty included), regardless of `inputText` or
    // `isComposeExpanded`. Its *container* (this GeometryReader + the
    // `.frame`/`.position` below) is what animates between the collapsed card's
    // geometry and the full screen, not the editor itself being swapped for a
    // different instance. Because the editor is never removed/reinserted,
    // SwiftUI preserves its scroll position and `$inputFocused` state across
    // every transition for free -- no manual coordination needed (Nov 10 2026
    // rebuild, replacing the old two-view `composePill`/`expandedComposeOverlay`
    // split; see the comment on that old branch in `composePill` above for why).
    //
    // Nov 18 2026: this used to only mount `if !inputText.isEmpty`, with a
    // SEPARATE `TextField` in `composePill` covering the empty state. That was
    // exactly the same two-views-trading-places bug the Nov 10 rebuild above
    // already fixed once for expanded/collapsed -- just left one seam
    // unaddressed, between empty and non-empty. Kell caught it on his own
    // phone, not just the Simulator: tapping in sometimes showed the keyboard,
    // but the FIRST character typed tore down the TextField, mounted this
    // TextEditor fresh, and visibly dropped/resized the composer as focus and
    // the keyboard notification both had to re-settle on the new view. Always
    // mounting this one editor, with `composePill` below reduced to a pure
    // layout spacer, removes that swap entirely.
    @ViewBuilder
    private var unifiedComposeSurface: some View {
        if true {
            // No `GeometryReader` here at all, on purpose -- both `proxy.safeAreaInsets`
            // AND `proxy.size` proved unreliable in this specific tree (confirmed
            // empirically, Nov 10 2026, each time via a temporary on-screen debug
            // readout showing real numbers: insets silently zeroed by an
            // ancestor's `.ignoresSafeArea()`, and size undercounted by ~96pt due
            // to a sibling's `.safeAreaInset` usage elsewhere in the same `ZStack`
            // bleeding into this reader's geometry proposal). Reading both
            // straight from the key window sidesteps SwiftUI's safe-area/
            // geometry bookkeeping entirely rather than trying to out-guess it a
            // third time.
            let safeTop = deviceSafeAreaInsets.top
            let safeBottom = deviceSafeAreaInsets.bottom
            let fullWidth = deviceScreenSize.width
            let fullHeight = deviceScreenSize.height
                // Matches the OLD composePill's footprint exactly, so the collapsed
                // end-state of this surface lands pixel-for-pixel where the static
                // reservation spacer above (and the real card before this rebuild)
                // sat: 24pt horizontal padding each side, and `Theme.Spacing.xxl`
                // above the device's own home-indicator safe area.
                let collapsedWidth = fullWidth - 48
                // Nov 18 2026 (Kell's explicit ChatGPT-style spec, superseding
                // the prior fixed-120pt requirement): shared with `composePill`
                // via `composeCollapsedHeight` -- see that property's own header
                // comment for why padding values there must match the real
                // TextEditor's own collapsed padding below exactly.
                let collapsedHeight = composeCollapsedHeight
                // With the keyboard up, float just above IT instead of the static
                // home-indicator inset -- `keyboardHeight` (tracked by hand, see the
                // comment on that `@State` above) already measures from the true
                // bottom of the screen, so it replaces `safeBottom` entirely rather
                // than stacking on top of it.
                let bottomInset = keyboardHeight > 0 ? keyboardHeight : safeBottom
                let collapsedBottomMargin = bottomInset + Theme.Spacing.xxl
                // Content padding (chevron, TextEditor) adds this back in by hand
                // when expanded, so it clears the status bar/notch instead of
                // colliding with it.
                let expandedTopInset = safeTop
                // Nov 10 2026: an outer-wrapper-plus-padding alternative to
                // `.position()` was tried here (to address a separately-confirmed
                // chevron-lag bug) and measured to land the card ~400pt above
                // where it belongs -- a NEW, worse bug, not a fix. Reverted.
                // `.frame(width:height:).position(x:y:)` directly on this card,
                // using `fullWidth`/`fullHeight` now correctly sourced from
                // `deviceScreenSize` (NOT the old, contaminated `proxy.size`), is
                // the one placement approach actually measured pixel-correct
                // across this entire session.
                // Kell's explicit ChatGPT-style spec (Nov 17 2026): tapping mic from
                // inside an existing draft collapses the WHOLE editor -- text and all
                // -- down into the same compact capsule the idle composer's own
                // `recordingBar`/`transcribingBar` use, not just a button row stuck to
                // the bottom of a still-full-size editor (that was the prior, wrong
                // pass -- see the now-removed isRecording/isTranscribingVoice branches
                // below). The draft text itself is never touched by this -- only this
                // card's geometry/contents swap while capturing, so cancel/error simply
                // leaving `inputText` alone (already true -- see `cancelRecording` and
                // `transcribeIntoTextField`'s error branch) is enough to "restore" it;
                // there's nothing to restore, it was never altered.
                // T-300: drives the card's geometry off the animatable mirrors,
                // not `audioManager.isRecording` directly -- see those `@State`
                // declarations above for why. The recording-vs-transcribing
                // CONTENT switch inside the capsule (just below) still reads the
                // live manager value directly, since that's a same-size content
                // crossfade with no frame/position jump to coordinate.
                let isVoiceCapturing = isRecordingAnimated || isTranscribingVoice || isStoppingToTranscribe
                let captureBarHeight: CGFloat = 64
                let cardWidth = isVoiceCapturing ? collapsedWidth : (isComposeExpanded ? fullWidth : collapsedWidth)
                let cardHeight = isVoiceCapturing ? captureBarHeight : (isComposeExpanded ? fullHeight : collapsedHeight)
                let cardCenterY = isVoiceCapturing
                    ? fullHeight - collapsedBottomMargin - captureBarHeight / 2
                    : (isComposeExpanded
                        ? fullHeight / 2
                        : fullHeight - collapsedBottomMargin - collapsedHeight / 2)
                // Giving the chevron its OWN `.position()`, nested INSIDE the same
                // ZStack as the TextEditor/mic/send (which use normal alignment-
                // flow, not `.position()`), measured (via recording + frame
                // capture) as landing hundreds of points off target: mixing a
                // `.position()`-ed child with alignment-flow siblings inside one
                // ZStack resolves that child's coordinate space against the
                // stack's UNCONSTRAINED proposed size (inflated by the
                // TextEditor's own unbounded-height demand when expanded), not
                // the final size the outer `.frame()` clamps it to. Pulling the
                // chevron OUT as a true sibling of the card -- both positioned in
                // the SAME absolute screen coordinates the card's own
                // `.position()` already uses -- sidesteps that entirely: there is
                // no shared local coordinate space to get contaminated.
                let cardTopY = cardCenterY - cardHeight / 2
                let cardRightX = fullWidth / 2 + cardWidth / 2

                ZStack(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    if isVoiceCapturing {
                        // Kell's explicit spec (Nov 17 2026): mic from inside an
                        // existing draft collapses the WHOLE editor into this same
                        // compact capsule -- the TextEditor isn't just covered by a
                        // control row, it's not rendered at all while capturing. The
                        // draft text underneath is never mutated here, so there's
                        // nothing to "restore" on cancel/error -- it reappears as-is
                        // the moment `isVoiceCapturing` goes false and this branch
                        // stops being drawn.
                        if audioManager.isRecording {
                            HStack(spacing: 0) {
                                Button(action: cancelRecording) {
                                    Text("✕")
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.Capture.textMuted)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.Capture.badgeBackground)
                                        .clipShape(Circle())
                                }

                                HStack(spacing: 10) {
                                    liveWaveform
                                    Text(audioManager.formattedDuration(audioManager.recordingDuration))
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.Payment.textSupporting)
                                }
                                .frame(maxWidth: .infinity)

                                Button(action: handleRecordTap) {
                                    Rectangle()
                                        .fill(Theme.Payment.backgroundPrimary)
                                        .frame(width: 10, height: 10)
                                        .cornerRadius(2)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.gold)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 10)
                        } else {
                            HStack(spacing: 10) {
                                Circle().fill(Theme.Payment.textSupporting).frame(width: 5, height: 5)
                                transcribingWaveform
                                Text("Transcribing...")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.Payment.textSupporting)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        }
                    } else {
                    TextEditor(text: $inputText)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textHeading)
                        .tint(Theme.gold)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($inputFocused)
                        .disabled(isWaitingForDwelly)
                        .padding(.leading, isComposeExpanded ? 20 : 16)
                        .padding(.top, isComposeExpanded ? expandedTopInset + 44 : 16)
                        .padding(.trailing, isComposeExpanded ? 20 : 44)
                        .padding(.bottom, isComposeExpanded ? keyboardHeight + 70 : 58)
                        .frame(height: isComposeExpanded ? nil : collapsedHeight)
                        .clipped()
                        // Nov 18 2026, SECOND reinspection: removed the
                        // `.contentShape(Rectangle()).onTapGesture { inputFocused =
                        // true }` that used to sit right here. It was added under
                        // the (wrong) "dead hit target" theory, before the real
                        // cause -- the TextField/TextEditor identity swap just
                        // above -- was found and fixed. `TextEditor` is natively
                        // focusable on tap; it never needed a synthetic tap
                        // gesture to become first responder. Layering a
                        // `UITapGestureRecognizer` (what `.onTapGesture` compiles
                        // to) directly on top of a `TextEditor`'s own `UITextView`
                        // is a documented SwiftUI/UIKit interop hazard: the two
                        // gesture recognizers can compete for the same touch, and
                        // on some iOS versions that competition is exactly what
                        // produces "tap shows the keyboard, then it dismisses and
                        // reopens while typing" -- matching Kell's exact report.
                        // With the real swap bug gone, this hack was pure
                        // remaining risk with no upside left to justify it.
                        // This TextEditor is now the ONE persistent composer for
                        // every state (idle/typing/expanded) -- see this surface's
                        // own header comment, and `composePill` below, for why the
                        // OLD empty-state TextField (torn down and replaced by THIS
                        // view the instant `inputText` flipped non-empty) was the
                        // real cause of Kell's "typing changes composer size/
                        // position and brings it down" report (Nov 18 2026): that
                        // was never one editor animating, it was two different
                        // UIKit text views trading places mid-keystroke, each with
                        // its own first-responder transition and its own keyboard
                        // show/hide notification. `TextEditor` has no native
                        // placeholder, so this overlay stands in for the old
                        // TextField's `prompt:`.
                        .overlay(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("Share what's on your mind...")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.Capture.textMuted)
                                    .padding(.leading, isComposeExpanded ? 25 : 21)
                                    .padding(.top, isComposeExpanded ? expandedTopInset + 52 : 24)
                                    .allowsHitTesting(false)
                            }
                        }

                    // Kell's follow-up ask (Nov 16 2026): a long transcript's collapsed
                    // preview just stopped dead at the 120pt clip -- no signal that
                    // there's more, just an abrupt cut mid-line. A thin gradient strip
                    // sitting on top of (not masking) the TextEditor, fading from
                    // transparent to the card's own background right where the
                    // controls row starts, reads as "this trails off" instead of "this
                    // got cut off." Non-interactive and collapsed-only -- expanded mode
                    // already shows the full text with nothing to fade.
                    if !isComposeExpanded {
                        LinearGradient(
                            colors: [Theme.Capture.cardBackground.opacity(0), Theme.Capture.cardBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 28)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 58)
                        .allowsHitTesting(false)
                    }

                    // REGRESSION FIX: the previous pass wrapped this in a VStack with
                    // `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment:
                    // .bottom)` to add an expanded-only divider row -- `.bottom`
                    // centers horizontally, and the collapsed HStack (no leading
                    // Spacer) has no width of its own to push against, so the
                    // mic/send buttons silently landed dead-center instead of at the
                    // far-right/trailing edge they've always had (ChatGPT-style,
                    // ticket/Kell's explicit call). Collapsed is back to a plain
                    // trailing-aligned HStack, same as every point before this
                    // regression.
                    //
                    // Nov 18 2026: the divider `Rectangle` the expanded branch used to
                    // draw above this row is gone -- Kell flagged a stray thin gray
                    // seam sitting directly above the send button, and this hairline
                    // was the only literal divider anywhere in this card's bottom
                    // area. ChatGPT's own composer has no such line either; the
                    // trailing-aligned send button on its own already reads clearly
                    // as the row's action without a rule drawn above it.
                    let hasDraft = !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    Group {
                        if isComposeExpanded {
                            HStack(spacing: 10) {
                                Spacer()
                                Button(action: sendUserTurn) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.goldDark)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.gold)
                                        .clipShape(Circle())
                                }
                                .disabled(isWaitingForDwelly || isOverCharacterLimit || !hasDraft)
                                .opacity(isOverCharacterLimit || !hasDraft ? 0.4 : 1.0)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        } else {
                            HStack(spacing: 10) {
                                // Mic only ever shows collapsed -- Kell's own correction
                                // after seeing it live (Nov 10 2026): "remove the mic
                                // because it creates a different experience... the only
                                // time you can use the mic is if it's in a collapsed view."
                                // Tapping it collapses this whole card into the capture
                                // capsule above instead of living inline here (Nov 17 2026).
                                Button(action: handleRecordTap) {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.gold)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.Capture.cardBorder)
                                        .clipShape(Circle())
                                }
                                .disabled(isWaitingForDwelly)
                                .transition(.opacity)

                                Button(action: sendUserTurn) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.goldDark)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.gold)
                                        .clipShape(Circle())
                                }
                                // Nov 18 2026: this row is now shown in the empty state too
                                // (unifiedComposeSurface mounts unconditionally -- see its
                                // own header comment), so Send needs its own empty-draft
                                // guard; sendUserTurn() already no-ops on empty text, this
                                // just makes that visible instead of showing a live-looking
                                // button that does nothing.
                                .disabled(isWaitingForDwelly || isOverCharacterLimit || !hasDraft)
                                .opacity(isOverCharacterLimit || !hasDraft ? 0.4 : 1.0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(.trailing, 10)
                        }
                    }
                    // Send button needs to clear the keyboard in the expanded case
                    // too -- `.safeAreaInset(edge: .bottom)` used to do this for
                    // free on the old `expandedComposeOverlay`; this floating
                    // surface has to track it by hand via `keyboardHeight`.
                    .padding(.bottom, isComposeExpanded ? keyboardHeight + 16 : 10)
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(Theme.Capture.cardBackground)
                // A capsule is just a rounded rect whose radius is half its own
                // height -- using that instead of a real `Capsule()` shape means no
                // `AnyShape` (iOS 17+) is needed to pick between the two at runtime,
                // and this target sits on iOS 16.
                .clipShape(RoundedRectangle(cornerRadius: isVoiceCapturing ? captureBarHeight / 2 : (isComposeExpanded ? 0 : 20)))
                .position(x: fullWidth / 2, y: cardCenterY + composeDragOffset)
                .ignoresSafeArea()

                // Sibling of the card (not nested inside it) -- see the comment
                // above on why that matters. Same absolute screen coordinates the
                // card's own `.position()` uses, so there is exactly one shared
                // coordinate system for both, and nothing for them to disagree on
                // mid-animation. Hidden while capturing -- there's nothing to
                // expand/collapse mid-recording, and `recordingBar`/`transcribingBar`
                // (the idle-composer equivalents this capsule now matches) have no
                // chevron either.
                if !isVoiceCapturing {
                    Button(action: toggleComposeExpanded) {
                        Image(systemName: isComposeExpanded ? "chevron.down.circle" : "chevron.up.circle")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.Payment.textSupporting)
                            .frame(width: 32, height: 32)
                    }
                    // Nov 18 2026 (Kell's explicit ask, and his own direct code
                    // review flagged this ordering as a real risk): `.contentShape`
                    // + `.simultaneousGesture` are attached HERE, to the plain
                    // 32x32-framed button, BEFORE `.position()`/`.ignoresSafeArea()`
                    // run -- not after. `.ignoresSafeArea()` wraps its input in a
                    // safe-area-ignoring container; attaching the gesture to THAT
                    // wrapper instead of the small button underneath it risks the
                    // gesture's (and the tap's) hit-testing region silently
                    // inheriting that wrapper's larger proposed size rather than
                    // staying pinned to the visible 32x32 circle, which could
                    // intercept touches meant for the TextEditor/keyboard beneath
                    // it. Pinning `.contentShape(Rectangle())` to the exact frame
                    // before either modifier runs removes that ambiguity entirely.
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 8)
                            .onChanged { value in
                                // Downward only, clamped -- dragging UP here isn't a
                                // gesture this control owns (that's the chevron's own
                                // tap, i.e. the explicit expand action).
                                composeDragOffset = min(max(0, value.translation.height), 220)
                            }
                            .onEnded { value in
                                // Distance OR velocity commits -- a short, fast flick
                                // should collapse/dismiss just as reliably as a slow
                                // drag past the distance threshold, matching the
                                // "fluid" feel Kell asked for rather than a hard stop.
                                let committed = value.translation.height > 70 || value.predictedEndTranslation.height > 160
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    if committed {
                                        if isComposeExpanded {
                                            // Collapse the expanded editor back to the
                                            // compact card -- draft text (`inputText`)
                                            // is never touched by any of this.
                                            isComposeExpanded = false
                                        } else {
                                            // Already compact -- nothing left to
                                            // collapse, so this dismisses the keyboard
                                            // instead, same "swipe down to put it away"
                                            // gesture ChatGPT's own composer supports.
                                            // Draft stays exactly as typed; tapping the
                                            // field again (see its own tap-to-focus
                                            // handling) refocuses and reopens it.
                                            inputFocused = false
                                        }
                                    }
                                    composeDragOffset = 0
                                }
                            }
                    )
                    .position(
                        x: cardRightX - (isComposeExpanded ? 20 : 14) - 16,
                        y: cardTopY + (isComposeExpanded ? expandedTopInset : 0) + 14 + 16 + composeDragOffset
                    )
                    .ignoresSafeArea()
                }

                // T-272 over-length caption -- Figma E9 ("Message Too Long"),
                // same placement/style as E6's "Reached 10 min — saved." caption:
                // plain muted text below the card, not inside the pill (see the
                // comment on `isOverCharacterLimit` above for why E2/E3's
                // replace-the-pill pattern doesn't apply here). Collapsed state
                // only -- expanded fills the screen under the keyboard, no room
                // for it there, but Send stays disabled either way.
                if !isComposeExpanded && !isVoiceCapturing && isOverCharacterLimit {
                    Text("That's a lot — trim it down to send.")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .position(x: fullWidth / 2, y: fullHeight - collapsedBottomMargin + 14)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .transition(.identity)
            // This surface is now always mounted (see the property's own header
            // comment), including during the prompt-card morph that used to hide
            // just `composePill`'s TextField via this same flag -- carry the fade
            // over here too so that reveal timing is unchanged.
            .opacity(isComposerRevealed ? 1 : 0)
            // Nov 18 2026: `collapsedHeight` now changes on every keystroke
            // (grows/shrinks with the real wrapped text) instead of being a
            // constant -- an explicit, narrowly-scoped implicit animation on
            // exactly that value is what makes the card's resulting
            // `.frame`/`.position` changes read as smooth growth/shrink
            // instead of a hard snap on each character, WITHOUT touching
            // `$inputFocused` or re-triggering any transition -- this is a
            // size/position animation on the container, never a remount.
            .animation(.easeOut(duration: 0.18), value: collapsedHeight)
        }
    }

    private func toggleComposeExpanded() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            isComposeExpanded.toggle()
        }
    }

    // Nov 18 2026: `recordingBar`/`transcribingBar` (Figma 648:220 / 649:3850)
    // used to live here as the pre-draft-only versions of this exact UI --
    // removed now that `unifiedComposeSurface` mounts unconditionally and
    // handles recording/transcribing for every state (empty included) via its
    // own `isVoiceCapturing` branch. Keeping both meant two separate
    // call sites could draw two overlapping recording bars in the same spot
    // (the exact bug Kell caught Nov 17 2026 for the draft case); removing the
    // duplicate removes that risk entirely rather than re-guarding it.

    // Reacts to AudioRecordingManager.audioLevel (real metering, sampled every
    // 0.1s) -- Kell's follow-up ask (Nov 16 2026): the old version scaled every
    // bar off that one instantaneous value, so the whole thing moved as a single
    // synchronized block. Each bar here instead renders its OWN slot in
    // `waveformHistory` -- a real past sample, oldest at the left, newest at the
    // right -- so speech actually travels across the bar as it's spoken, the way
    // Voice Memos' own waveform does, rather than the entire shape pulsing
    // together.
    private var liveWaveform: some View {
        HStack(spacing: 3) {
            ForEach(Array(waveformHistory.enumerated()), id: \.offset) { _, level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.gold)
                    .frame(width: 2.5, height: 4 + level * 20)
            }
        }
        .frame(height: 24)
        .animation(.easeOut(duration: 0.12), value: waveformHistory)
        .onChange(of: audioManager.audioLevel) { level in
            waveformHistory.removeFirst()
            waveformHistory.append(level)
        }
    }

    // No real audio signal exists once recording has stopped, so this is a plain
    // self-looping sine wave via TimelineView — still visibly "alive," per Kell's
    // ask that both states animate, just not voice-reactive (nothing to react to).
    // Distinct, continuous processing animation (not a copy of the live-recording
    // waveform's look) -- a traveling sine ripple rather than every bar pulsing in
    // place, so "processing" reads visibly different from "listening." Bar count
    // is generous (28, up from 12) specifically so it reads as a continuous wave
    // once stretched across `.frame(maxWidth: .infinity)` in `transcribingBar`,
    // rather than a few fat, sparse bars.
    private var transcribingWaveform: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<28, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Payment.textSupporting)
                        .frame(width: 2.5, height: 4 + 10 * abs(sin(phase * 2.2 - Double(index) * 0.4)))
                }
            }
            .frame(height: 24)
            // Kell's follow-up ask (Nov 16 2026): keep it wide and continuous,
            // but soften the hard rectangular cutoff at each end -- a plain
            // opacity-gradient mask over the whole strip, not a change to the
            // bars themselves, fades the first/last few bars toward transparent
            // instead of ending abruptly.
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.08),
                        .init(color: .black, location: 0.92),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }

    // Discards the in-progress recording entirely — no transcription, nothing lands
    // in the compose field. Distinct from Stop, which hands the audio off to
    // transcribeIntoTextField().
    private func cancelRecording() {
        audioManager.stopRecording {
            if let url = audioManager.audioURL {
                try? FileManager.default.removeItem(at: url)
            }
            audioManager.audioURL = nil
        }
    }



    private func sendUserTurn() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isWaitingForDwelly, !isOverCharacterLimit else { return }
        // Kell's direct ask (Nov 17 2026, after watching the real send): the idle
        // "What's stirring in you today?" headline and the first user bubble used
        // to swap in one unanimated frame -- `turns.append` flipping `turns.isEmpty`
        // with no `withAnimation` around it at all, so SwiftUI had no transaction to
        // animate even though `idlePrelude`/`turnBubble` both get a plain `.opacity`
        // transition by default. Wrapping the actual state change is what was
        // missing; the scroll-to-bottom animation a few lines below (`onChange(of:
        // turns)`) was already smooth on its own; only this entry point wasn't.
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            inputText = ""
            // Found live Nov 17 2026 (Kell: box stayed oversized on a 2nd recording):
            // isComposeExpanded was never reset on send, so if it was ever left `true`,
            // the NEXT time content appeared it rendered straight into the fullscreen/
            // expanded layout instead of the normal 120pt collapsed box. Every send now
            // returns the compose surface to its slim empty state, every time.
            isComposeExpanded = false
            inputFocused = false
            turns.append(Turn(role: .user, text: text))
        }
        Task { await requestDwellyResponse() }
    }

    private func handleRecordTap() {
        if audioManager.isRecording {
            // T-300: bridges the gap between `audioManager.isRecording` going
            // false (near-instant) and `isTranscribingVoice` actually becoming
            // true (only once the recorder's delegate confirms the file
            // finished writing -- a separate, later async hop). Set inside
            // `withAnimation` since -- unlike `audioManager.isRecording` -- this
            // is our own state, mutated directly in our own code, so there's no
            // detached-dispatch problem to work around here.
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                isStoppingToTranscribe = true
            }
            // Fallback only: if the recorder's delegate never calls back at all
            // (a genuine write failure -- pre-existing, unhandled even before
            // this fix), don't leave the capsule stuck in transcribing mode
            // forever. Harmless no-op once `transcribeIntoTextField` has already
            // cleared this flag the normal way.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if isStoppingToTranscribe && !isTranscribingVoice {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                        isStoppingToTranscribe = false
                    }
                }
            }
            audioManager.stopRecording { transcribeIntoTextField() }
        } else {
            // Clear a stale error from a previous take (Kell caught this, Nov 10
            // 2026: an empty/failed recording's error message was staying on screen
            // through every re-record attempt after it instead of resetting).
            errorMessage = nil
            // T-300: dismiss the keyboard synchronously, right at tap time --
            // previously nothing explicitly did this, so dismissal only began
            // incidentally once the TextEditor was removed from the tree a beat
            // later (once `audioManager.isRecording` actually flipped true).
            // That left the capsule's Y-position -- which reads live
            // `keyboardHeight` -- computing against the still-full keyboard
            // height for that whole gap, landing it mid-screen instead of at
            // the bottom. Starting the dismiss here means the keyboard is
            // already animating down by the time the capsule appears, so its
            // position formula tracks the keyboard's real, current height the
            // entire way instead of jumping once `keyboardHeight` catches up.
            inputFocused = false
            // Model-ready check merged in from `CaptureView` (Nov 17 2026) -- this
            // used to only live on the old standalone first-capture screen, since by
            // the time a user reached what's now this screen's "turns already exist"
            // state, the model had already been downloaded during that earlier
            // first recording. Now that there's one screen, the very first recording
            // of this capture (whether turns is empty or not) still needs this check.
            guard TranscriptionManager.shared.isModelReady || UserDefaults.standard.bool(forKey: "whisperModelReady") else {
                startModelDownload()
                return
            }
            // Fresh timeline for this take -- otherwise the first few bars would
            // briefly show the previous recording's trailing samples.
            waveformHistory = Array(repeating: 0, count: Self.waveformBarCount)
            audioManager.onRecordingLimitReached = { transcribeIntoTextField() }
            audioManager.startRecording()
        }
    }

    // MARK: - Model Download (merged in from CaptureView, Nov 17 2026)

    private func startModelDownload() {
        isDownloadingModel = true
        downloadFailed = false
        downloadProgress = 0.0
        HTMLLogManager.shared.log("First capture — downloading WhisperKit model", level: "INFO")

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let target = 0.92 * (1 - exp(-downloadProgress / 0.85))
            DispatchQueue.main.async { downloadProgress += 0.001 }
            _ = target // suppress warning
        }

        Task {
            await TranscriptionManager.shared.setupWhisperKit()

            progressTimer?.invalidate()
            progressTimer = nil

            await MainActor.run {
                if TranscriptionManager.shared.isModelReady {
                    HTMLLogManager.shared.log("Model ready — starting first recording", level: "SUCCESS")
                    downloadProgress = 1.0
                    UserDefaults.standard.set(true, forKey: "whisperModelReady")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isDownloadingModel = false
                        waveformHistory = Array(repeating: 0, count: Self.waveformBarCount)
                        audioManager.onRecordingLimitReached = { transcribeIntoTextField() }
                        audioManager.startRecording()
                    }
                } else {
                    HTMLLogManager.shared.log("Model download failed", level: "ERROR")
                    downloadFailed = true
                }
            }
        }
    }

    private var modelDownloadOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if downloadFailed {
                VStack(spacing: 20) {
                    ZStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.orange)
                    }
                    .frame(width: 280, height: 80)

                    Text("Download failed.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.orange)

                    ZStack {
                        VStack(spacing: 8) {
                            Text("Check your connection and try again.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.tertiaryText)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 12) {
                                Button("Try Again") {
                                    startModelDownload()
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.background)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Theme.gold)
                                .cornerRadius(8)

                                Button("Cancel") {
                                    isDownloadingModel = false
                                    downloadFailed = false
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.tertiaryText)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(width: 280, height: 90)
                }
            } else {
                VStack(spacing: 16) {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(Theme.gold, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(spinnerRotation))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                spinnerRotation = 360
                            }
                        }
                        .frame(width: 280, height: 80)

                    Text("Setting up voice capture...")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.text)

                    ZStack {
                        VStack(spacing: 12) {
                            Text("This only happens once.\nYour recording is safe.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.tertiaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 3)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.gold)
                                        .frame(width: geo.size.width * CGFloat(min(downloadProgress, 1.0)), height: 3)
                                        .animation(.linear(duration: 0.05), value: downloadProgress)
                                }
                            }
                            .frame(height: 3)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(width: 280, height: 90)
                }
            }
        }
    }

    // MARK: - Idle state (merged in from CaptureView, Nov 17 2026)

    // Intent-tailored prompts apply ONLY to the mandatory onboarding first-capture
    // (isOnboarding == true) -- confirmed with Kell (Nov 11 2026): intent can't even
    // be changed until a user is subscribed (well past onboarding), and by that point
    // the one-time personalization moment has already happened. Every capture after
    // onboarding uses the generic set below, unconditionally.
    private var topicCards: [(title: String, category: String)] {
        let generic: [(title: String, category: String)] = [
            ("Did God show up in a connection today?", "Relationships"),
            ("Any stillness stand out to you?", "Quiet moments"),
            ("Anything you're wrestling with?", "Doubts"),
        ]
        let intent = ProfileManager.shared.localProfile(userId: userId).spiritualIntent
        switch intent {
        case "I want to journal my encounters with God":
            return [("What's a moment with God you want to remember from today?", "Encounter")]
        case "A place to process my thoughts and feelings":
            return [("What's weighing on your mind right now?", "Weighing on you")]
        case "I want to work through my doubts":
            return [("What's a doubt you've been sitting with?", "Doubts")]
        case "I want to see my patterns in my spiritual journey":
            return [("What's something you keep coming back to lately?", "Patterns")]
        case "I want to remember what God's done for me":
            return [("What's something God's done that you don't want to forget?", "Remembering")]
        default:
            return generic
        }
    }

    // Idle headline + (onboarding-only) topic cards, shown while `turns.isEmpty` --
    // folded in from `CaptureView`'s own `entryScreen` (Nov 17 2026 merge).
    private var idlePrelude: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's stirring in you today?")
                .font(.system(size: 38, design: .serif))
                .foregroundColor(Theme.Capture.textPrimary)

            // Kell's direct ask (Nov 17 2026, after watching a recording of a
            // real second/third-clip session): this line used to swap to
            // "Listening…" while `audioManager.isRecording` and back the instant
            // it flips false -- including mid-transcribe, so it visibly snapped
            // back to "Just start talking." while audio was still being
            // processed, which read as the headline itself flickering/resetting.
            // The capture capsule below already carries the real recording/
            // transcribing state (waveform+timer, then "Transcribing..."), so
            // this headline has nothing useful left to add by also changing —
            // it now stays put through every recording, no matter how many
            // clips go into the same draft.
            Text(isOnboarding ? "Tap one, or just start talking." : "Just start talking.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)

            if isOnboarding {
                VStack(spacing: 12) {
                    ForEach(topicCards, id: \.title) { card in
                        Button(action: { selectPromptCard(card.title) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.Capture.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(card.category)
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.Payment.textSupporting)
                                }
                                .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.gold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.Capture.cardBackground)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.Capture.cardBorder, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .matchedGeometryEffect(id: "promptCard", in: promptTransition, isSource: selectedPromptTitle == card.title)
                        .opacity(selectedPromptTitle == nil || selectedPromptTitle == card.title ? 1 : 0)
                        .disabled(selectedPromptTitle != nil)
                    }
                }
                .padding(.top, 26)
            }
        }
        // Found auditing Kell's "feels like switching screens" report (Nov 17 2026):
        // this whole block -- headline AND subtitle -- used to fade to invisible
        // while `isTranscribingVoice`, inherited faithfully from the original
        // `CaptureView`'s own `isIntroHidden` ("the headline/hint pairing has
        // nothing left to say" once transcribing starts). That rationale held back
        // when a recording could only ever happen once, from a screen with nothing
        // else on it. It stopped holding the moment repeat recording into an
        // existing draft became a real, supported flow: fading the ENTIRE headline
        // out and back on every single clip, even the 2nd/3rd into an already-
        // started draft, is exactly the "switching screens" sensation Kell flagged
        // on review -- confirmed against his screen recording, where the headline
        // visibly blinks out each time a clip stops. Kell's explicit current
        // instruction overrides that old rationale: this headline now stays fully
        // present, same opacity, same position, through every stage -- idle,
        // recording, transcribing, draft populated -- right up until Send actually
        // moves `turns` past empty and this view stops being rendered at all.
    }

    // Sequenced two-phase handoff for a tapped topic card: first fade the OTHER
    // (untapped) cards and hold the selected one in place, then -- a beat later --
    // seed `turns` with it as the opening assistant question, same as
    // `initialMessageIsPrompt`'s own `onAppear` handling, just triggered directly
    // here now that the card and the resulting bubble live in the same screen.
    private func selectPromptCard(_ title: String) {
        guard selectedPromptTitle == nil else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
            selectedPromptTitle = title
        }
        let delay = reduceMotion ? 0 : 0.22
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                turns = [Turn(role: .assistant, text: title)]
                openedWithPromptQuestion = true
            }
            isComposerRevealed = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.25)) { isComposerRevealed = true }
            }
        }
    }

    // Lands the transcript in the compose field for the user to read, edit, or
    // discard — does NOT send it. Kell caught this sending straight to the
    // conversation (Nov 10 2026): the design's own flow is record → transcribe →
    // review/edit in the text box → the user decides when to actually send, same as
    // every other message here, not a voice-specific shortcut that skips review.
    // Appends to any text already there rather than overwriting it — recording again
    // is meant to add more, same as picking a conversation back up, not starting over.
    // Lands the transcript in the compose field for the user to read, edit, or
    // discard — does NOT send it. Kell caught this sending straight to the
    // conversation (Nov 10 2026): the design's own flow is record → transcribe →
    // review/edit in the text box → the user decides when to actually send, same as
    // every other message here, not a voice-specific shortcut that skips review.
    // Appends to any text already there rather than overwriting it — recording again
    // is meant to add more, same as picking a conversation back up, not starting over.
    // Re-verified Nov 17 2026 after the CaptureView merge, with real mic audio on
    // both the first AND second recording in the same session -- both landed here
    // correctly, neither auto-sent nor opened a different screen.
    private func transcribeIntoTextField() {
        guard let audioURL = audioManager.audioURL else { return }
        // T-300: both of this function's own mutations are wrapped directly --
        // `isTranscribingVoice` is this view's own state, mutated right here in
        // our own code, so (unlike `audioManager.isRecording`) there's no
        // detached-dispatch problem to work around with a mirror/`.onChange`.
        // Clearing `isStoppingToTranscribe` in the same transaction hands the
        // capsule's driving condition off cleanly, with no gap between the two.
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            isTranscribingVoice = true
            isStoppingToTranscribe = false
        }
        TranscriptionManager.shared.transcribeAudio(from: audioURL) { transcript in
            DispatchQueue.main.async {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    isTranscribingVoice = false
                    guard let transcript, !transcript.isEmpty else {
                        errorMessage = TranscriptionManager.shared.errorMessage ?? "Couldn't make that out — try again, or type it instead."
                        return
                    }
                    // Keep the keyboard dismissed on initial delivery -- Kell's ask: the
                    // transcript should land for silent review first, not yank the
                    // keyboard open the instant it's ready. The user taps in to edit
                    // (or expand) when they're ready; this used to force-focus here.
                    inputText = inputText.isEmpty ? transcript : inputText + " " + transcript
                }
            }
        }
    }

    private func requestDwellyResponse() async {
        guard !isConversationComplete else { return }
        // Found auditing Kell's "still feels like changing screens" follow-up
        // (Nov 17 2026): the PREVIOUS pass only wrapped `sendUserTurn()`'s own
        // mutation in `withAnimation` -- it never touched this function at all,
        // even though this is the other half of "send, then see Dwelly respond."
        // Every state change below (badge+spinner appearing, then being replaced
        // by the real reply) was flipping with zero animation, so even a perfectly
        // smooth send crossfade still led into a hard, instant spinner-to-response
        // swap right after -- which reads as a second screen replacement, not a
        // continuation of the first. All three mutation points below now animate.
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            isWaitingForDwelly = true
            errorMessage = nil
        }

        // The 3rd/final response doesn't need its own LLM call followed by a separate
        // fixed hand-off bubble — Kell caught (Nov 10 2026) that showing both a real
        // generated reply AND the closing message back to back reads as Dwelly
        // responding twice, and spends tokens on a reply nobody reads before the
        // hand-off. The fixed closingMessage IS response 3. Onboarding-only (Nov 11
        // 2026) -- post-onboarding has no fixed 3rd response to special-case; every
        // reply there is a real generated one, all the way until the user taps Done.
        if isOnboarding && dwellyResponseCount == maxResponses - 1 {
            await MainActor.run {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    turns.append(Turn(role: .assistant, text: closingMessage))
                    isWaitingForDwelly = false
                }
            }
            return
        }

        var messages = [
            LLMMessage(role: .system, content: systemPrompt),
            LLMMessage(role: .system, content: timeAwareContext),
        ]
        messages.append(contentsOf: turns.map { LLMMessage(role: $0.role, content: $0.text) })

        do {
            let response = try await apiClient.callLLM(messages: messages, feature: "capture_conversation")
            await MainActor.run {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    turns.append(Turn(role: .assistant, text: response.content))
                    isWaitingForDwelly = false
                }
            }
        } catch {
            await MainActor.run {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    isWaitingForDwelly = false
                }
                errorMessage = "Dwelly couldn't respond just now. You can keep writing, or save what you have."
            }
            HTMLLogManager.shared.log("llm-proxy call failed: \(error.localizedDescription)", level: "ERROR")
        }
    }

    /// Fires automatically once the conversation closes — the Figma close screen has no
    /// manual "Save Your Moment" button, it's already saved by the time the journal card
    /// appears. Deliberately does NOT call `onMomentSaved?()` here: every call site
    /// (MainTabView, OnboardingCoordinatorView, MomentsListView) uses that callback to
    /// dismiss this whole screen, which would hide the journal card the instant it
    /// appeared. Outside onboarding, that callback fires from the back chevron instead;
    /// onboarding has no chevron (nothing to go back to), so it gets its own explicit
    /// "Continue" button in the footer instead — a timed auto-advance was tried first
    /// and rejected by Kell (Nov 10 2026) for pushing him past the card before he'd
    /// even gotten to look at it.
    private func finishAndSave() async {
        isSaving = true
        errorMessage = nil
        UserDefaults.standard.set(Date(), forKey: Self.lastReflectionDateKey)

        async let metaTask: Void = generateJournalMeta()

        let moment = Moment(userId: userId, body: combinedBody, createdAt: Date())

        do {
            _ = try await apiClient.saveMoment(moment)
            UsageTracker.shared.logMomentCreated(userId: userId, userEmail: userEmail, type: "text")
            Task { try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient) }
            await MainActor.run {
                isSaving = false
                savedMoment = moment
            }
        } catch {
            syncManager.markMomentAsPending(moment)
            UsageTracker.shared.logMomentCreated(userId: userId, userEmail: userEmail, type: "text")
            Task { try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient) }
            await MainActor.run {
                isSyncPending = true
                isSaving = false
                savedMoment = moment
            }
        }

        await metaTask

        // T-152/T-159: persist the title/scripture this view already generates, instead
        // of letting it vanish once this screen closes. Moods aren't generated here at
        // all yet (journalMeta has no moods field), so this entry starts with an empty
        // moods array; JournalDetailView's mood editor is what actually fills it in.
        // Only a REAL synthesis success is ever written as "approved" -- a failure
        // writes "pending" (no title/scripture) instead of the local display-only
        // fallback, so the background retry sweep (SyncManager.retryPendingJournalEntries,
        // the BGTaskScheduler job) has an honest signal to actually retry, rather than a
        // fake title masquerading as finished synthesis forever. Best-effort either way:
        // if this fails, the capture itself already succeeded above, so don't block or
        // surface an error over a metadata save.
        let entry: JournalEntry
        if journalSynthesisSucceeded, let journalMeta {
            entry = JournalEntry(
                momentId: moment.id,
                userId: userId,
                status: "approved",
                title: journalMeta.title,
                body: journalMeta.body,
                moods: journalMeta.moods,
                scriptureQuote: journalMeta.scriptureQuote,
                scriptureReference: journalMeta.scriptureReference,
                formationEligible: journalMeta.formationEligible,
                extractedFacts: journalMeta.extractedFacts
            )
        } else {
            entry = JournalEntry(momentId: moment.id, userId: userId, status: "pending")
        }
        _ = try? await apiClient.saveJournalEntry(entry)

        // T-274/T-127 (rebuilt Nov 17 2026): gated on formationEligible specifically,
        // not on "did synthesis not error" -- a genuinely illegible capture (a mic
        // test, keyboard noise) must never reach the running profile summary just
        // because nothing technically failed. Confirmed live before this fix: a real
        // "testing testing testing" capture had already been woven into this user's
        // actual DwellerProfile summary ("Your playful 'testing testing' note shows
        // you're present and moving forward..."). Feeds extractedFacts (the supported-
        // only content), never the full body, so a mixed entry's filler portions can't
        // leak in even when the real portion qualifies.
        if journalSynthesisSucceeded, let journalMeta, journalMeta.formationEligible, let facts = journalMeta.extractedFacts {
            Task { await DwellerProfileManager.updateRunningSummary(newEntryBody: facts, userId: userId, apiClient: apiClient) }
        }

        // T-159 fast path: a new capture is exactly the kind of sync-triggering event
        // the locked decision means by "piggyback on new-capture sync" -- attempt any
        // other pending entries' synthesis too, not just this one. Fire-and-forget;
        // doesn't block finishing this screen.
        Task { await syncManager.retryPendingJournalEntries() }
    }

    /// One extra LLM call, fired in parallel with the save itself — asks for strict JSON
    /// so a title/excerpt/scripture pairing can show up on the journal card right away
    /// instead of a plain dump of the typed turns. Best-effort: if the model doesn't
    /// return parseable JSON, the card falls back to a plain title/excerpt built locally
    /// and just skips the scripture line, rather than blocking or erroring the save.
    private func generateJournalMeta() async {
        // Genuinely empty input (shouldn't happen in practice -- the composer requires
        // at least one sent message -- but defensive rather than sending a blank prompt
        // to the model for nothing): no LLM call needed to know there's nothing here.
        guard !combinedBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                journalMeta = JournalMeta(
                    title: "A Moment Captured",
                    excerpt: "",
                    body: combinedBody,
                    scriptureQuote: nil,
                    scriptureReference: nil,
                    moods: [],
                    formationEligible: false,
                    extractedFacts: nil
                )
                journalSynthesisSucceeded = true
            }
            return
        }
        do {
            // Shares the exact same synthesis call the retry sweep uses (T-159) --
            // a pending entry retried later is decided identically to how it would
            // have been the first time. T-127 (rebuilt Nov 17 2026): one call decides
            // everything now -- preserve-vs-synthesize, title, formation eligibility,
            // extracted facts, and scripture/moods -- no deterministic pre-check runs
            // before it.
            let result = try await JournalSynthesisManager.synthesize(transcript: fullTranscript, userOnlyText: combinedBody, apiClient: apiClient)
            let meta = JournalMeta(
                title: result.title,
                excerpt: String(result.body.prefix(140)),
                body: result.body,
                scriptureQuote: result.scriptureQuote,
                scriptureReference: result.scriptureReference,
                moods: result.moods,
                formationEligible: result.formationEligible,
                extractedFacts: result.extractedFacts
            )
            await MainActor.run {
                journalMeta = meta
                journalSynthesisSucceeded = true
            }
        } catch {
            HTMLLogManager.shared.log("journal meta generation failed, using fallback: \(error.localizedDescription)", level: "WARNING")
            await MainActor.run {
                // Even the hard-failure fallback keeps a verse -- Kell confirmed (Nov 10
                // 2026) the card should never show without one, matching the Figma
                // reference, which always pairs an entry with scripture.
                journalMeta = JournalMeta(
                    title: "A Moment With God",
                    excerpt: String(combinedBody.prefix(140)),
                    body: nil,
                    scriptureQuote: "Be still, and know that I am God.",
                    scriptureReference: "Psalm 46:10",
                    moods: []
                )
            }
        }
    }
}

// `matchedGeometryEffect` needs a non-optional `Namespace.ID` -- this just guards
// applying it at all when there's no shared namespace (every entry path besides a
// tapped topic card) or this isn't the one bubble that should carry it.
private struct PromptOriginMatch: ViewModifier {
    let isActive: Bool
    let namespace: Namespace.ID?
    func body(content: Content) -> some View {
        if isActive, let namespace {
            content.matchedGeometryEffect(id: "promptCard", in: namespace)
        } else {
            content
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        CaptureConversationView(
            userId: "preview-user",
            userEmail: "preview@example.com",
            syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"),
            initialMessage: "I felt God's presence today in a quiet moment.",
            onMomentSaved: nil
        )
    }
    .environment(\.apiClient, apiClient)
}
