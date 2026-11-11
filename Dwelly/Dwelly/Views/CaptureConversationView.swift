import SwiftUI
import UIKit

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
    let initialMessage: String
    // When the conversation is opened from one of CaptureView's suggested prompt cards,
    // `initialMessage` is a question Dwelly is posing TO the user ("Any stillness stand
    // out to you?"), not something the user is saying to Dwelly — sending it as a user
    // turn made the model answer its own question in the first person instead of
    // inviting a real answer (caught by Kell live, Nov 9 2026). Defaults to false for
    // the free-typed-text path, which is unchanged.
    var initialMessageIsPrompt: Bool = false
    // The mandatory onboarding first-capture (OnboardingCoordinatorView, presented
    // with .interactiveDismissDisabled()) has nowhere to go "back" TO — there's no
    // prior screen in onboarding for this chevron to return to, confirmed by Kell
    // (Nov 10 2026) as the one thing still wrong after everything else in this
    // screen. Defaults to false for every other CaptureView call site, where the
    // back chevron is correct.
    var isOnboarding: Bool = false
    var onMomentSaved: (() -> Void)?

    @Environment(\.apiClient) private var apiClient
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

    @State private var turns: [Turn] = []
    @State private var inputText = ""
    @State private var isWaitingForDwelly = false
    @State private var isTranscribingVoice = false
    // Component/Typed-Text-Box (node 651:3966) has its own Collapsed/Expanded states
    // once there's typed/transcribed content — Kell caught this missing entirely
    // (Nov 10 2026): no way to grow the compose box for a long reflection. Collapsed
    // is 120pt, Expanded is 524pt -- both FIXED, per the Figma component spec (pulled
    // directly, Nov 10 2026), not computed from screen/keyboard height. Several
    // intermediate attempts at a "fill the screen, keyboard draws in front of it"
    // ChatGPT-style behavior caused repeated real-device bugs and were a departure
    // from this locked spec -- reverted back to it entirely.
    @State private var isComposeExpanded = false
    // One random "character" per waveform bar, generated once per recording session
    // so bars don't all pulse in perfect lockstep — real voice waveforms (Wispr Flow,
    // Voice Memos) have per-bar variation, not a single uniform pulse.
    @State private var waveformSeeds: [CGFloat] = (0..<24).map { _ in CGFloat.random(in: 0.4...1.0) }
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
    @State private var showMomentDetail = false

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
    private var isConversationComplete: Bool { dwellyResponseCount >= maxResponses }

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
    private struct JournalMeta: Decodable {
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

        enum CodingKeys: String, CodingKey {
            case title, excerpt, body, moods
            case scriptureQuote = "scripture_quote"
            case scriptureReference = "scripture_reference"
        }
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
                            ForEach(turns) { turn in
                                turnBubble(turn, isFinal: isConversationComplete && turn.id == turns.last?.id)
                                    .id(turn.id == turns.last?.id ? "journalPreview" : turn.id.uuidString)
                            }
                            if isWaitingForDwelly {
                                dwellyBadge
                                ProgressView()
                                    .tint(Theme.gold)
                                    .padding(.leading, 24)
                                    .id("spinner")
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
                    .onChange(of: turns.count) { _ in
                        withAnimation { proxy.scrollTo(turns.last?.id, anchor: .bottom) }
                    }
                    .onChange(of: isWaitingForDwelly) { waiting in
                        if waiting { withAnimation { proxy.scrollTo("spinner", anchor: .bottom) } }
                    }
                    .onChange(of: isConversationComplete) { complete in
                        if complete {
                            withAnimation { proxy.scrollTo("journalPreview", anchor: .bottom) }
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
                                // Onboarding has no back chevron (nothing to go back to), but a
                                // silent timed auto-advance turned out worse — Kell caught it
                                // pushing him into the next screen before he'd even gotten to
                                // look at the journal card (Nov 10 2026). A real "Continue" the
                                // user taps once they're ready replaces that timer.
                                //
                                // Nov 10 2026 (continued): this used to call `onMomentSaved?()`
                                // directly, which skipped straight past the journal into the
                                // main app -- a brand-new user's very first journal, the thing
                                // meant to hook them, was entirely skippable. Now it opens the
                                // real `JournalDetailView` first; THAT screen's own `onDone`
                                // (set only in this onboarding case) is what finally calls
                                // `onMomentSaved?()`, once the user has actually read it.
                                if isOnboarding {
                                    Button(action: { showMomentDetail = true }) {
                                        Text("Continue")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Theme.Payment.backgroundPrimary)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 60)
                                    }
                                    .background(Theme.gold)
                                    .clipShape(Capsule())
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, Theme.Spacing.xxl)
                                    .disabled(savedMoment == nil)
                                    .opacity(savedMoment == nil ? 0.5 : 1.0)
                                    // Single shared `.navigationDestination(isPresented:
                                    // $showMomentDetail)` lives on the inline "Open" link in
                                    // `journalPreviewContent` below -- two destinations bound
                                    // to the same trigger state is undefined behavior, so this
                                    // button only sets the flag, same as "Open" does.
                                }
                            } else {
                                if let warningMessage = audioManager.warningMessage {
                                    Text(warningMessage)
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.gold)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                }

                                // Component/Recording-Bar (Figma node 648:220) / Component/Transcribing-Bar
                                // (649:3850), pulled exactly rather than approximated — Kell flagged the
                                // missing stages (Nov 10 2026): record → live waveform/timer with
                                // Cancel+Stop → transcribing → transcript lands in the compose field for
                                // review, not sent automatically.
                                if audioManager.isRecording {
                                    recordingBar
                                } else if isTranscribingVoice {
                                    transcribingBar
                                } else {
                                    composePill
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 0) {
                    HStack {
                        // Only once the entry is saved — mid-conversation, leaving
                        // loses it with nothing to come back to, so there's nothing to
                        // navigate back TO yet. Never during onboarding, which has no
                        // prior screen for this to return to at all.
                        if isConversationComplete && !isOnboarding {
                            Button(action: { onMomentSaved?(); dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Theme.Capture.textPrimary)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        if !turns.isEmpty {
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
                        Image("DwellyRockIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    // Fixed height regardless of which elements are present -- without
                    // this, the row grew from ~24pt to 44pt the moment the back chevron
                    // (its own 44x44 tap target) appeared post-completion, shifting the
                    // counter/logo down. Kell asked (Nov 10 2026) for the counter/logo
                    // row to sit at a fixed height always.
                    .frame(height: 44)
                    .padding(.horizontal, isConversationComplete ? 16 : 28)
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
    private func turnBubble(_ turn: Turn, isFinal: Bool = false) -> some View {
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
                    if isFinal {
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
                    Button(action: { showMomentDetail = true }) {
                        Text("Open")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Capture.goldBright)
                            .frame(width: 60, height: 24)
                    }
                    .overlay(Capsule().stroke(Theme.gold, lineWidth: 1))
                    // Shared by both the inline "Open" link here and the onboarding
                    // "Continue" button above -- they're the same destination either
                    // way, just reached differently. `onDone` is non-nil only for
                    // onboarding's mandatory first capture: that's the one case
                    // where finishing this screen needs to actually continue
                    // onward into the main app, not just dismiss back to the chat.
                    .navigationDestination(isPresented: $showMomentDetail) {
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
                            onDone: isOnboarding ? { onMomentSaved?() } : nil
                        )
                    }
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

    // Component/Compose-Text-Pill (647:221) when empty; once there's content this
    // becomes Component/Typed-Text-Box (651:3966) instead — a card with its own
    // Collapsed (120pt)/Expanded (grows to fit more text) states via the expand/
    // collapse icon, missing entirely before (Kell, Nov 10 2026).
    private var composePill: some View {
        Group {
            if inputText.isEmpty {
                HStack(spacing: 8) {
                    TextField("", text: $inputText, prompt: Text("Share what's on your mind...").foregroundColor(Theme.Capture.textMuted), axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .tint(Theme.gold)
                        .focused($inputFocused)
                        .submitLabel(.done)
                        .onSubmit { sendUserTurn() }
                        .disabled(isWaitingForDwelly)

                    Button(action: handleRecordTap) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.gold)
                            .frame(width: 44, height: 44)
                            .background(Theme.Capture.cardBorder)
                            .clipShape(Circle())
                    }
                    .disabled(isWaitingForDwelly)
                }
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .frame(height: 60)
                .background(Theme.Capture.cardBackground)
                .clipShape(Capsule())
            } else {
                // Nov 10 2026 rebuild: this used to be a second, fully separate card
                // view here, cross-faded against `expandedComposeOverlay` (a THIRD,
                // also-separate full-screen view) -- two independent `TextEditor`s
                // bound to the same `$inputText`, swapped via conditional rendering.
                // No matter how the transition/scrim/opacity was tuned, that shape
                // kept producing some form of "two screens replacing each other"
                // glitch, confirmed repeatedly by recording and frame-extracting our
                // own build. Kell's own diagnosis, and a second model's independent
                // read of the same handoff, agreed: the fix is architectural, not a
                // timing tweak -- one `TextEditor`, never unmounted, whose
                // *container* animates size/position/corner-radius. That single
                // surface now lives in `unifiedComposeSurface`, floated as its own
                // top-level sibling in `body`'s outer ZStack (so it can span from the
                // collapsed card's position all the way to full-screen). This branch
                // only reserves the same footprint the collapsed card occupies, so
                // the scrolling thread still clears it -- it renders nothing visible.
                Color.clear.frame(height: 120)
            }
        }
        .animation(.easeOut(duration: 0.15), value: inputText.isEmpty)
        .padding(.horizontal, 24)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // The single persistent compose surface -- ONE `TextEditor`, mounted for as
    // long as `inputText` is non-empty, regardless of `isComposeExpanded`. Its
    // *container* (this GeometryReader + the `.frame`/`.position` below) is what
    // animates between the collapsed card's geometry and the full screen, not the
    // editor itself being swapped for a different instance. Because the editor is
    // never removed/reinserted, SwiftUI preserves its scroll position and
    // `$inputFocused` state across the transition for free -- no manual
    // coordination needed (Nov 10 2026 rebuild, replacing the old two-view
    // `composePill`/`expandedComposeOverlay` split; see the comment on that old
    // branch in `composePill` above for why).
    @ViewBuilder
    private var unifiedComposeSurface: some View {
        if !inputText.isEmpty {
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
                let collapsedHeight: CGFloat = 120
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
                let cardWidth = isComposeExpanded ? fullWidth : collapsedWidth
                let cardHeight = isComposeExpanded ? fullHeight : collapsedHeight
                let cardCenterY = isComposeExpanded
                    ? fullHeight / 2
                    : fullHeight - collapsedBottomMargin - collapsedHeight / 2
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
                        .frame(height: isComposeExpanded ? nil : 120)
                        .clipped()

                    HStack(spacing: 10) {
                        // Mic only ever shows collapsed -- Kell's own correction
                        // after seeing it live (Nov 10 2026): "remove the mic
                        // because it creates a different experience... the only
                        // time you can use the mic is if it's in a collapsed view."
                        // A plain `if` here (not a separate view) because this
                        // button was never the thing causing the ghosting -- it's a
                        // small icon, not a second copy of the user's text.
                        if !isComposeExpanded {
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
                        }

                        Button(action: sendUserTurn) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.goldDark)
                                .frame(width: 44, height: 44)
                                .background(Theme.gold)
                                .clipShape(Circle())
                        }
                        .disabled(isWaitingForDwelly || isOverCharacterLimit)
                        .opacity(isOverCharacterLimit ? 0.4 : 1.0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, isComposeExpanded ? 20 : 10)
                    // Send button needs to clear the keyboard in the expanded case
                    // too -- `.safeAreaInset(edge: .bottom)` used to do this for
                    // free on the old `expandedComposeOverlay`; this floating
                    // surface has to track it by hand via `keyboardHeight`.
                    .padding(.bottom, isComposeExpanded ? keyboardHeight + 16 : 10)
                }
                .frame(
                    width: isComposeExpanded ? fullWidth : collapsedWidth,
                    height: isComposeExpanded ? fullHeight : collapsedHeight
                )
                .background(Theme.Capture.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: isComposeExpanded ? 0 : 20))
                .position(x: fullWidth / 2, y: cardCenterY)
                .ignoresSafeArea()

                // Sibling of the card (not nested inside it) -- see the comment
                // above on why that matters. Same absolute screen coordinates the
                // card's own `.position()` uses, so there is exactly one shared
                // coordinate system for both, and nothing for them to disagree on
                // mid-animation.
                Button(action: toggleComposeExpanded) {
                    Image(systemName: isComposeExpanded ? "chevron.down.circle" : "chevron.up.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .frame(width: 32, height: 32)
                }
                .position(
                    x: cardRightX - (isComposeExpanded ? 20 : 14) - 16,
                    y: cardTopY + (isComposeExpanded ? expandedTopInset : 0) + 14 + 16
                )
                .ignoresSafeArea()

                // T-272 over-length caption -- Figma E9 ("Message Too Long"),
                // same placement/style as E6's "Reached 10 min — saved." caption:
                // plain muted text below the card, not inside the pill (see the
                // comment on `isOverCharacterLimit` above for why E2/E3's
                // replace-the-pill pattern doesn't apply here). Collapsed state
                // only -- expanded fills the screen under the keyboard, no room
                // for it there, but Send stays disabled either way.
                if !isComposeExpanded && isOverCharacterLimit {
                    Text("That's a lot — trim it down to send.")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .position(x: fullWidth / 2, y: fullHeight - collapsedBottomMargin + 14)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .transition(.identity)
        }
    }

    private func toggleComposeExpanded() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            isComposeExpanded.toggle()
        }
    }

    // Component/Recording-Bar (node 648:220) — Cancel (✕) + a live, voice-reactive
    // waveform + timer + Stop (circled gold, the "commits right now" action per this
    // design system's own Icon-Circle rule).
    private var recordingBar: some View {
        HStack(spacing: 0) {
            Button(action: cancelRecording) {
                Text("✕")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Capture.textMuted)
                    .frame(width: 44, height: 44)
                    // Kell's direct ask (Nov 11 2026) after testing live: a bare ✕ with
                    // no circle didn't read clearly enough as a tappable cancel action,
                    // especially next to Stop's gold circle. Figma's own component has
                    // no fill here either, so this is a deliberate addition beyond the
                    // locked design, not a correction to it -- muted/soft (not gold),
                    // so Cancel still reads as the secondary action next to Stop's
                    // primary gold circle.
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
        .frame(height: 64)
        .background(Theme.Capture.cardBackground)
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // Component/Transcribing-Bar (node 649:3850) — a continuously animated wave (no
    // live audio exists anymore at this point, so this is a self-driven loop, not
    // audio-reactive) plus a status label, shown while speech-to-text runs.
    private var transcribingBar: some View {
        HStack(spacing: 8) {
            Circle().fill(Theme.Payment.textSupporting).frame(width: 6, height: 6)
            transcribingWaveform
            Spacer()
            Text("Transcribing...")
                .font(.system(size: 14))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
        .background(Theme.Capture.cardBackground)
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // Reacts to AudioRecordingManager.audioLevel (real metering, sampled every 0.1s)
    // — Kell: "it's supposed to be a wave that is dynamic with my voice... the same
    // way Wispr Flow is," not the static fixed-height bars this had before (Nov 10
    // 2026). Each bar has its own random "character" (waveformSeeds) so they don't
    // all move in unison like one uniform pulse.
    private var liveWaveform: some View {
        HStack(spacing: 3) {
            ForEach(Array(waveformSeeds.enumerated()), id: \.offset) { _, seed in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.gold)
                    .frame(width: 2.5, height: 4 + seed * audioManager.audioLevel * 20)
                    .animation(.easeOut(duration: 0.1), value: audioManager.audioLevel)
            }
        }
        .frame(height: 24)
    }

    // No real audio signal exists once recording has stopped, so this is a plain
    // self-looping sine wave via TimelineView — still visibly "alive," per Kell's
    // ask that both states animate, just not voice-reactive (nothing to react to).
    private var transcribingWaveform: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<12, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Payment.textSupporting)
                        .frame(width: 2.5, height: 4 + 10 * abs(sin(phase * 3 + Double(index) * 0.5)))
                }
            }
            .frame(height: 24)
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
        inputText = ""
        turns.append(Turn(role: .user, text: text))
        Task { await requestDwellyResponse() }
    }

    private func handleRecordTap() {
        if audioManager.isRecording {
            audioManager.stopRecording { transcribeIntoTextField() }
        } else {
            // Clear a stale error from a previous take (Kell caught this, Nov 10
            // 2026: an empty/failed recording's error message was staying on screen
            // through every re-record attempt after it instead of resetting).
            errorMessage = nil
            audioManager.onRecordingLimitReached = { transcribeIntoTextField() }
            audioManager.startRecording()
        }
    }

    // Lands the transcript in the compose field for the user to read, edit, or
    // discard — does NOT send it. Kell caught this sending straight to the
    // conversation (Nov 10 2026): the design's own flow is record → transcribe →
    // review/edit in the text box → the user decides when to actually send, same as
    // every other message here, not a voice-specific shortcut that skips review.
    // Appends to any text already there rather than overwriting it — recording again
    // is meant to add more, same as picking a conversation back up, not starting over.
    private func transcribeIntoTextField() {
        guard let audioURL = audioManager.audioURL else { return }
        isTranscribingVoice = true
        TranscriptionManager.shared.transcribeAudio(from: audioURL) { transcript in
            DispatchQueue.main.async {
                isTranscribingVoice = false
                guard let transcript, !transcript.isEmpty else {
                    errorMessage = TranscriptionManager.shared.errorMessage ?? "Couldn't make that out — try again, or type it instead."
                    return
                }
                inputText = inputText.isEmpty ? transcript : inputText + " " + transcript
                inputFocused = true
            }
        }
    }

    private func requestDwellyResponse() async {
        guard !isConversationComplete else { return }
        isWaitingForDwelly = true
        errorMessage = nil

        // The 3rd/final response doesn't need its own LLM call followed by a separate
        // fixed hand-off bubble — Kell caught (Nov 10 2026) that showing both a real
        // generated reply AND the closing message back to back reads as Dwelly
        // responding twice, and spends tokens on a reply nobody reads before the
        // hand-off. The fixed closingMessage IS response 3.
        if dwellyResponseCount == maxResponses - 1 {
            await MainActor.run {
                turns.append(Turn(role: .assistant, text: closingMessage))
                isWaitingForDwelly = false
            }
            return
        }

        var messages = [LLMMessage(role: .system, content: systemPrompt)]
        messages.append(contentsOf: turns.map { LLMMessage(role: $0.role, content: $0.text) })

        do {
            let response = try await apiClient.callLLM(messages: messages, feature: "capture_conversation")
            await MainActor.run {
                turns.append(Turn(role: .assistant, text: response.content))
                isWaitingForDwelly = false
            }
        } catch {
            await MainActor.run {
                isWaitingForDwelly = false
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
                scriptureReference: journalMeta.scriptureReference
            )
        } else {
            entry = JournalEntry(momentId: moment.id, userId: userId, status: "pending")
        }
        _ = try? await apiClient.saveJournalEntry(entry)

        // T-274: keep the running summary current, store-and-show only -- fire-and-forget,
        // never blocks this screen, and only runs on a real synthesized entry (a pending
        // one has no body yet to summarize).
        if journalSynthesisSucceeded, let body = entry.body {
            Task { await DwellerProfileManager.updateRunningSummary(newEntryBody: body, userId: userId, apiClient: apiClient) }
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
        do {
            // Shares the exact same synthesis call the retry sweep uses (T-159) --
            // a pending entry retried later is synthesized identically to how it
            // would have been the first time.
            let userWordCount = combinedBody.split(whereSeparator: { $0.isWhitespace }).count
            let result = try await JournalSynthesisManager.synthesize(transcript: fullTranscript, userWordCount: userWordCount, apiClient: apiClient)
            let meta = JournalMeta(
                title: result.title,
                excerpt: result.excerpt,
                body: result.body,
                scriptureQuote: result.scriptureQuote,
                scriptureReference: result.scriptureReference,
                moods: result.moods
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
