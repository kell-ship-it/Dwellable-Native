import SwiftUI

/// T-078: the real Entries tab, replacing the Phase-1 `MomentsListView`. Locked design
/// (`docs/PILLAR_5_SEARCH_STRATEGY.md`, Aug 27 2026, "Screen 1 — Calendar + Entries
/// List") — Untold-style month calendar at top, that month's entries listed below,
/// tap a day to filter. Header uses the same `TabScreenHeader` every other tab-landing
/// screen already shares (Today/Growth/Profile) -- the Aug 27 doc's own "merged pill +
/// profile icon" header description predates the Oct 15 2026 nav redesign that
/// replaced it app-wide (see `TabScreenHeader`'s own comment); that later decision
/// wins here too, for the same reason Profile already dropped out of the header
/// entirely once it became its own tab (T-253).
///
/// Reads real `JournalEntry` rows (title/moods/status), not raw `Moment.body` the way
/// the old list did -- joined against `Moment` by `momentId` since `JournalEntry` has
/// no body of its own to fall back on for a moment with no entry row at all (shouldn't
/// happen post-T-152, but every capture still goes through `Moment` first).
struct EntriesView: View {
    @Environment(\.apiClient) private var apiClient
    let userId: String
    @ObservedObject var syncManager: SyncManager
    var onSearch: () -> Void
    var onCapture: () -> Void

    private struct Entry: Identifiable {
        let moment: Moment
        let journalEntry: JournalEntry?
        var id: String { moment.id }
        var createdAt: Date { moment.createdAt }
        // Absence of a `JournalEntry` row at all is treated the same as an explicit
        // "pending" status -- defensively, since every real capture goes through
        // T-152's save path, but nothing guarantees it landed yet.
        var isPending: Bool { journalEntry == nil || journalEntry?.status == "pending" }
        var displayTitle: String {
            if let title = journalEntry?.title, !title.isEmpty { return title }
            return isPending ? "Your Reflection" : "A Moment With God"
        }
    }

    @State private var entries: [Entry] = []
    @State private var isLoading = true
    @State private var loadError: String?

    // Untold-style: anchored to the first of the month currently shown. `selectedDay`
    // is nil by default (shows the whole month's entries below the calendar); tapping
    // a day filters the list to just that day, per the locked spec.
    @State private var displayedMonth: Date = Calendar.current.startOfDay(for: Date())
    @State private var selectedDay: Date?

    private var calendar: Calendar { Calendar.current }

    private var entriesInDisplayedMonth: [Entry] {
        entries.filter { calendar.isDate($0.createdAt, equalTo: displayedMonth, toGranularity: .month) }
    }

    private var visibleEntries: [Entry] {
        guard let selectedDay else { return entriesInDisplayedMonth }
        return entriesInDisplayedMonth.filter { calendar.isDate($0.createdAt, inSameDayAs: selectedDay) }
    }

    // Days in the displayed month that have at least one entry -- drives the
    // calendar's dot indicators.
    private var daysWithEntries: Set<DateComponents> {
        Set(entriesInDisplayedMonth.map { calendar.dateComponents([.year, .month, .day], from: $0.createdAt) })
    }

    var body: some View {
        VStack(spacing: 0) {
            TabScreenHeader(title: "Entries", onSearch: onSearch, onCapture: onCapture)

            if isLoading {
                Spacer()
                ProgressView().tint(Theme.gold)
                Spacer()
            } else if let loadError {
                Spacer()
                VStack(spacing: 12) {
                    Text(loadError)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .multilineTextAlignment(.center)
                    Button("Try Again") { Task { await loadEntries() } }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.gold)
                }
                .padding(.horizontal, 32)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        monthCalendar
                        entryList
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // Kell caught this live (Nov 16 2026): a just-saved entry didn't show up
        // here at all -- `TabView` keeps every tab's view alive across switches,
        // so once this screen loaded once (even with zero entries), nothing ever
        // told it to look again. Re-fetching on every appearance (not just the
        // first) is what `MomentsListView` already did before this screen
        // replaced it; this screen had dropped that behavior entirely.
        //
        // REGRESSION FIX (Nov 16 2026, later same day): that first fix paired
        // `.task(id: refreshTrigger)` with `.onAppear { refreshTrigger = UUID() }`
        // -- on first appearance both fired, the second immediately invalidating
        // the first's `id` mid-flight. SwiftUI cancels a `.task(id:)`'s in-flight
        // work the instant its `id` changes, so that first load's network calls
        // threw `CancellationError`, which `loadEntries()`'s `catch` treated as a
        // real failure -- "Couldn't load your entries," every single time, with
        // "Try Again" only ever working because by then nothing was left to
        // cancel it. Same shape also explains a deleted entry still showing: the
        // view never actually re-fetched after popping back, so you were
        // sometimes looking at the stale success state before this race ran at
        // all. Collapsed to one plain trigger -- no `id` to race, nothing to
        // cancel.
        .onAppear { Task { await loadEntries() } }
    }

    // MARK: - Calendar

    private var monthCalendar: some View {
        VStack(spacing: 16) {
            HStack {
                // Kell's rule (Nov 16 2026): can't browse back past the account's
                // own earliest real data either -- see `earliestAllowedMonth`'s
                // comment for why that's the honest proxy used here instead of a
                // real account-creation timestamp, which isn't wired client-side.
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isAtEarliestMonth ? Theme.Capture.textMuted : Theme.Payment.textSupporting)
                        .frame(width: 44, height: 44)
                }
                .disabled(isAtEarliestMonth)

                Spacer()

                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.Payment.textHeading)

                Spacer()

                // Locked Oct 15 2026 (T-218): the forward arrow is disabled once the
                // displayed month is the current month -- there's nothing ahead of
                // "now" to browse to.
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isCurrentMonthDisplayed ? Theme.Capture.textMuted : Theme.Payment.textSupporting)
                        .frame(width: 44, height: 44)
                }
                .disabled(isCurrentMonthDisplayed)
            }
            .padding(.horizontal, 12)

            let weekdaySymbols = calendar.veryShortWeekdaySymbols
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .frame(maxWidth: .infinity)
                }
            }

            calendarGrid
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var isCurrentMonthDisplayed: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    // Kell's rule (Nov 16 2026): "only today and days prior, all the way back since
    // I created my account" -- the lower bound this app can actually honor right
    // now. There's no account-creation timestamp wired into the client at all
    // (`AuthUser`/`AuthManager` don't carry one), so fabricating a date here would
    // be worse than being honest about the limit: this uses the earliest month
    // with any real data (moment OR journal entry, whichever is older) as the
    // floor instead. For an account with zero captures yet, that floor is simply
    // the current month -- there's nothing before "now" to browse to for a brand
    // new account anyway, which happens to match the real rule exactly in that
    // case. Flagged for Kell: if a precise account-creation date ever gets wired
    // client-side, swap this proxy for the real thing.
    private var earliestAllowedMonth: Date {
        guard let earliest = entries.map(\.createdAt).min() else {
            return calendar.startOfDay(for: Date())
        }
        return earliest
    }

    private var isAtEarliestMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: earliestAllowedMonth, toGranularity: .month)
    }

    private func changeMonth(by delta: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) else { return }
        // Never browse past the current month (T-218's own forward-arrow lock, applied
        // here too so a stale/queued tap can't sneak past the disabled state), and
        // never before the earliest real data either (this session's own new rule).
        if delta > 0 && isCurrentMonthDisplayed { return }
        if delta < 0 && isAtEarliestMonth { return }
        withAnimation(.easeOut(duration: 0.2)) {
            displayedMonth = newMonth
            selectedDay = nil
        }
    }

    private var calendarGrid: some View {
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30
        // `firstWeekday` is locale-aware (1 = Sunday in most US locales); leading
        // blanks pad the grid so day 1 lands under its real weekday column.
        let leadingBlanks = (calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday + 7) % 7
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<leadingBlanks, id: \.self) { _ in
                Color.clear.frame(height: 36)
            }
            ForEach(1...daysInMonth, id: \.self) { day in
                let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
                dayCell(date: date)
            }
        }
    }

    // Kell's rule (Nov 16 2026): the calendar can only ever show today and days
    // before it -- there's nothing real to show on a day that hasn't happened yet,
    // so a future day isn't just visually de-emphasized, it's genuinely
    // unselectable. `> today` (not `>=`) so today itself stays fully selectable.
    private func isFutureDay(_ date: Date) -> Bool {
        date > calendar.startOfDay(for: Date())
    }

    private func dayCell(date: Date) -> some View {
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let isToday = calendar.isDateInToday(date)
        let hasEntry = daysWithEntries.contains(calendar.dateComponents([.year, .month, .day], from: date))
        let isFuture = isFutureDay(date)

        return Button(action: {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedDay = isSelected ? nil : date
            }
        }) {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? Theme.Payment.backgroundPrimary : (isFuture ? Theme.Capture.textMuted : Theme.Payment.textHeading))
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Theme.gold : Color.clear)
                    .overlay(
                        Circle().stroke(Theme.gold, lineWidth: isToday && !isSelected ? 1 : 0)
                    )
                    .clipShape(Circle())

                Circle()
                    .fill(hasEntry ? Theme.gold : .clear)
                    .frame(width: 4, height: 4)
            }
            // 44pt tap target (T-217's own expanded-tap-target precedent) even though
            // the visible day number is a smaller 32pt circle.
            .frame(width: 44, height: 44)
        }
        .disabled(isFuture)
        .opacity(isFuture ? 0.35 : 1)
    }

    // MARK: - Entry list

    private var entryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let selectedDay {
                HStack {
                    Text(selectedDay.formatted(date: .complete, time: .omitted))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Payment.textSupporting)
                    Spacer()
                    Button(action: { withAnimation { self.selectedDay = nil } }) {
                        Text("Show all")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.gold)
                    }
                }
                .padding(.horizontal, 20)
            }

            if visibleEntries.isEmpty {
                VStack(spacing: 8) {
                    Text(selectedDay == nil ? "No entries this month yet." : "Nothing captured this day.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(visibleEntries) { entry in
                        NavigationLink(destination: JournalDetailView(moment: entry.moment, syncManager: syncManager)) {
                            entryRow(entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }

    private func entryRow(_ entry: Entry) -> some View {
        // Kell caught this live (Nov 16 2026): `.top` pinned the chevron to the
        // row's top edge instead of centering it against the title+date block --
        // every other chevron in the app (the calendar's month-nav arrows
        // included) is vertically centered, and this was the one exception.
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.displayTitle)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)
                        .lineLimit(1)

                    // Pending gets a small pulsing tag; approved entries carry no
                    // status label at all -- absence *is* the approved state (Kell's
                    // explicit correction in the locked spec, don't invent a badge
                    // to mirror this one).
                    if entry.isPending {
                        pendingTag
                    }
                }

                Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11))
                    .foregroundColor(Theme.Payment.textSupporting)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Theme.Capture.cardBackground)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Capture.cardBorder.opacity(0.4), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @State private var pendingPulse = false
    private var pendingTag: some View {
        Text("Pending")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(Theme.gold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay(Capsule().stroke(Theme.gold, lineWidth: 1))
            .clipShape(Capsule())
            .opacity(pendingPulse ? 0.5 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pendingPulse = true
                }
            }
    }

    // MARK: - Data

    private func loadEntries() async {
        isLoading = true
        loadError = nil
        do {
            async let moments = apiClient.fetchMoments(userId: userId)
            async let pending = apiClient.fetchPendingJournalEntries(userId: userId)
            async let approved = apiClient.fetchApprovedJournalEntries(userId: userId)

            let (fetchedMoments, pendingEntries, approvedEntries) = try await (moments, pending, approved)
            let entriesByMomentId = Dictionary(
                (pendingEntries + approvedEntries).map { ($0.momentId, $0) },
                uniquingKeysWith: { first, _ in first }
            )

            let merged = fetchedMoments
                .map { Entry(moment: $0, journalEntry: entriesByMomentId[$0.id]) }
                .sorted { $0.createdAt > $1.createdAt }

            await MainActor.run {
                entries = merged
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                loadError = "Couldn't load your entries. Check your connection and try again."
            }
            HTMLLogManager.shared.log("EntriesView load failed: \(error.localizedDescription)", level: "ERROR")
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        EntriesView(userId: "preview-user", syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"), onSearch: {}, onCapture: {})
    }
    .environment(\.apiClient, apiClient)
}
