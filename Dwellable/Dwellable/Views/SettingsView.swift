import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack(spacing: 4) {
                    Button(action: { dismiss() }) {
                        Text("‹")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Button(action: { dismiss() }) {
                        Text("Settings")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)

                // Scrollable content
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Profile section
                        VStack(spacing: Theme.Spacing.md) {
                            Text("Profile")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.tertiaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: Theme.Spacing.md) {
                                if let user = authManager.currentUser {
                                    HStack(spacing: Theme.Spacing.lg) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Email")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(Theme.tertiaryText)
                                            Text(user.email)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Theme.text)
                                        }
                                        Spacer()
                                    }
                                    .padding(Theme.Spacing.lg)
                                    .background(Theme.surfaceBackground)
                                    .cornerRadius(10)
                                }
                            }
                        }

                        // App section
                        VStack(spacing: Theme.Spacing.md) {
                            Text("App")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.tertiaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: Theme.Spacing.md) {
                                HStack(spacing: Theme.Spacing.lg) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Version")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.tertiaryText)
                                        Text("1.0.0")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(Theme.text)
                                    }
                                    Spacer()
                                }
                                .padding(Theme.Spacing.lg)
                                .background(Theme.surfaceBackground)
                                .cornerRadius(10)
                            }
                        }

                        // Legal section
                        VStack(spacing: Theme.Spacing.md) {
                            Text("Legal")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.tertiaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: Theme.Spacing.sm) {
                                Button(action: {}) {
                                    HStack {
                                        Text("Terms of Service")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(Theme.text)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.tertiaryText)
                                    }
                                    .padding(Theme.Spacing.lg)
                                    .background(Theme.surfaceBackground)
                                    .cornerRadius(10)
                                }

                                Button(action: {}) {
                                    HStack {
                                        Text("Privacy Policy")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(Theme.text)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.tertiaryText)
                                    }
                                    .padding(Theme.Spacing.lg)
                                    .background(Theme.surfaceBackground)
                                    .cornerRadius(10)
                                }
                            }
                        }

                        Spacer()
                            .frame(height: Theme.Spacing.xl)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.lg)
                }

                // Sign out button
                Button(action: {
                    Task {
                        await authManager.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.error)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Button.primaryPadding)
                        .background(Theme.error.opacity(0.1))
                        .border(Theme.error.opacity(0.3), width: 1)
                        .cornerRadius(Theme.Button.primaryCornerRadius)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        SettingsView()
            .environmentObject(AuthManager(apiClient: apiClient))
    }
}
