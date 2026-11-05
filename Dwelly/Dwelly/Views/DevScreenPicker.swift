#if DEBUG
import SwiftUI

/// Debug-only: a floating button that jumps straight to any built screen, skipping the
/// lock screen / tap-through flow needed to reach it normally. Exists purely to make
/// screen-by-screen Figma verification fast — never compiled into Release builds.
///
/// Backed by a shared singleton rather than a plain @State/@Binding pair so the button can
/// be embedded in screens presented via .fullScreenCover (Login, Paywall, Account Creation,
/// …), not just the root WindowGroup — a `@Binding` can't reach across that presentation
/// boundary, but every view can see `DevNavigator.shared`.
final class DevNavigator: ObservableObject {
    static let shared = DevNavigator()
    @Published var screen: DevScreenPicker.Screen?
    private init() {
        // Lets a launch script jump straight to a screen (SIMCTL_CHILD_DWELLY_DEV_SCREEN=...)
        // for scripted/manual verification without needing a working tap on whatever
        // screen is first in the normal flow.
        if let raw = ProcessInfo.processInfo.environment["DWELLY_DEV_SCREEN"] {
            screen = DevScreenPicker.Screen(rawValue: raw)
        }
    }
}

struct DevScreenPicker: View {
    enum Screen: String, CaseIterable, Identifiable {
        case appLoading = "App Loading"
        case welcome = "Welcome"
        case introVideo = "Intro Video"
        case accountCreation = "Account Creation"
        case nameEntry = "Onboarding — Name Entry"
        case intentSelection = "Onboarding — Intent Selection"
        case notificationPermission = "Onboarding — Notification Permission"
        case preparingSpace = "Onboarding — Preparing Space"
        case paywallOnboarding = "Paywall — Onboarding"
        case paywallSecondCapture = "Paywall — Second Capture Gate"
        case paywallTrialUsed = "Paywall — Trial Already Used"
        case login = "Login"
        case forgotPassword = "Forgot Password"
        case newPassword = "New Password"

        var id: String { rawValue }
    }

    @ObservedObject private var navigator = DevNavigator.shared
    @State private var showMenu = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showMenu = true }) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Circle())
                }
                .padding(.trailing, 12)
                .padding(.bottom, 24)
            }
        }
        .confirmationDialog("Jump to screen", isPresented: $showMenu, titleVisibility: .visible) {
            ForEach(Screen.allCases) { screen in
                Button(screen.rawValue) { navigator.screen = screen }
            }
            if navigator.screen != nil {
                Button("Back to normal flow", role: .destructive) { navigator.screen = nil }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    static func render(_ screen: Screen) -> some View {
        switch screen {
        case .appLoading:
            AppLoadingView(onComplete: {})
        case .welcome:
            WelcomeView()
        case .introVideo:
            IntroVideoView(onContinue: {})
        case .accountCreation:
            AccountCreationView(onContinue: {}, onSignIn: {})
        case .nameEntry:
            NameEntryView(userId: "dev-preview-user", onContinue: {}, onBack: {})
        case .intentSelection:
            IntentSelectionView(userId: "dev-preview-user", onContinue: {}, onBack: {})
        case .notificationPermission:
            NotificationPermissionView(userId: "dev-preview-user", onContinue: {}, onBack: {})
        case .preparingSpace:
            PreparingSpaceView(name: "Kell", onComplete: {})
        case .paywallOnboarding:
            PaywallView(context: .onboardingSkippable)
        case .paywallSecondCapture:
            PaywallView(context: .secondCaptureGate)
        case .paywallTrialUsed:
            PaywallView(context: .trialAlreadyUsed)
        case .login:
            LoginView()
        case .forgotPassword:
            ForgotPasswordView()
        case .newPassword:
            NewPasswordView(accessToken: "", refreshToken: "", onDone: {})
        }
    }
}

/// Drop this on any screen (besides the root WindowGroup, which hosts the full picker) so its
/// wrench button and jump-to-screen menu still work even when presented via .fullScreenCover.
struct DevPickerOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(DevScreenPicker())
    }
}

extension View {
    func devPickerOverlay() -> some View { modifier(DevPickerOverlay()) }
}
#endif
