import SwiftUI

/// The real App Loading / splash screen (Figma `dwelly-redesign` node `941:510`,
/// "00 — App Loading"): centered rock mascot + "dwelly" wordmark on the dark brand
/// background. Shown briefly on cold launch before branching to Welcome (logged out)
/// or the tab app (logged in) — auth state itself resolves synchronously from Keychain
/// (see AuthManager.init), so this delay is purely the brand moment the design calls
/// for, not a real loading wait.
struct AppLoadingView: View {
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255).ignoresSafeArea()

            VStack(spacing: 16) {
                Image("DwellyRockIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                Text("dwelly")
                    .font(.system(size: 32, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            onComplete()
        }
    }
}
