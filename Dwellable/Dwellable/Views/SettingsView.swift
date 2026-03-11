import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var analytics: [String: Any] = [:]
    @State private var recentEvents: [UsageTracker.UsageEvent] = []
    @State private var lastUpdated = Date()

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

                        // Analytics section
                        VStack(spacing: Theme.Spacing.md) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Text("Analytics")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Theme.tertiaryText)
                                Spacer()
                                Button(action: { loadAnalytics() }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Theme.gold)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: Theme.Spacing.sm) {
                                // Moments stat
                                HStack(spacing: Theme.Spacing.lg) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Moments Created")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.tertiaryText)
                                        HStack(spacing: 8) {
                                            Text("\(analytics["total_moments_created"] as? Int ?? 0)")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(Theme.text)
                                            Text("(\(analytics["voice_moments"] as? Int ?? 0) voice, \(analytics["text_moments"] as? Int ?? 0) text)")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(Theme.secondaryText)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(Theme.Spacing.lg)
                                .background(Theme.surfaceBackground)
                                .cornerRadius(10)

                                // Sessions stat
                                HStack(spacing: Theme.Spacing.lg) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("App Sessions")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.tertiaryText)
                                        Text("\(analytics["total_sessions"] as? Int ?? 0)")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Theme.text)
                                    }
                                    Spacer()
                                }
                                .padding(Theme.Spacing.lg)
                                .background(Theme.surfaceBackground)
                                .cornerRadius(10)

                                // Events pending sync
                                HStack(spacing: Theme.Spacing.lg) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Events Pending Sync")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.tertiaryText)
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(recentEvents.isEmpty ? Theme.gold : Theme.secondaryText)
                                                .frame(width: 6, height: 6)
                                            Text(recentEvents.isEmpty ? "All synced" : "\(recentEvents.count) pending")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(recentEvents.isEmpty ? Theme.gold : Theme.secondaryText)
                                        }
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
        .onAppear {
            loadAnalytics()
        }
    }

    private func loadAnalytics() {
        if let userId = authManager.currentUser?.id {
            let summary = UsageTracker.shared.getAnalyticsSummary(userId: userId)
            analytics = summary
            recentEvents = UsageTracker.shared.getEvents(userId: userId)
            lastUpdated = Date()
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        SettingsView()
            .environmentObject(AuthManager(apiClient: apiClient))
    }
}
