import SwiftUI

/// The real 4-tab shell (T-076): Today | Entries | Growth | Profile, standard native
/// iOS tab bar (material blur), always visible on these 4 screens, never hides on
/// scroll (locked Nov 2, 2026 — persistent chrome, not feed-style hide/reveal).
/// Capture is a persistent gold circle in each screen's own header, not a 5th tab
/// item (pulled out Aug 20, 2026 per Kell's review of the Journey app) — tapping it
/// launches CaptureView full-screen from any tab via a single shared presentation
/// state here. The Container Transform (.zoom) launch animation locked alongside
/// this decision is a later polish pass, not implemented yet — this is a plain
/// `fullScreenCover` for now.
struct MainTabView: View {
    let userId: String
    let userEmail: String?
    let syncManager: SyncManager

    @State private var showCapture = false

    var body: some View {
        TabView {
            NavigationStack {
                TodayPlaceholderView(onSearch: {}, onCapture: { showCapture = true })
            }
            .tabItem { Label("Today", systemImage: "sun.max") }

            NavigationStack {
                MomentsListView(userId: userId, syncManager: syncManager)
            }
            .tabItem { Label("Entries", systemImage: "book") }

            NavigationStack {
                GrowthPlaceholderView(onSearch: {}, onCapture: { showCapture = true })
            }
            .tabItem { Label("Growth", systemImage: "leaf") }

            NavigationStack {
                AccountProfileView(onSearch: {}, onCapture: { showCapture = true })
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(Theme.gold)
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(userId: userId, userEmail: userEmail, syncManager: syncManager, onMomentSaved: {
                showCapture = false
            })
        }
    }
}
