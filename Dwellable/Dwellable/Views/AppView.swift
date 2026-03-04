import SwiftUI

struct AppView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            MomentsListView()
        }
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    AppView()
        .environmentObject(AuthManager())
}
