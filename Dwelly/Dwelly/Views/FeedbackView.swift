import SwiftUI

/// T-133: the real Support & Feedback screen, pushed from Account Profile's Settings
/// Card (Figma node 711:5025 -- only the row existed there, no detail frame, same gap
/// Security & Privacy and Recently Deleted had before T-131/T-176). Matches the locked
/// design at node 689:329 ("iphone-frame — Support & Feedback"), four cards:
///
/// - Send Feedback / Report a Bug: both real -- push to `SendFeedbackView`, which writes
///   a row to `feedback_submissions` via `APIClient.submitFeedback`. A Resend email alert
///   and Notion mirror fire best-effort after that write (see
///   `SupabaseAPIClient.submitFeedback` and the `feedback-notify` Edge Function) but are
///   currently stubbed pending real ops credentials -- see that function's header
///   comment for exactly what's real vs. stubbed.
/// - Contact Support: a real `mailto:` link to hello@dwelly.one (opens the device's Mail
///   app, same as the design's own caption describes). Inbound delivery (hello@dwelly.one
///   -> kells@kellgolden.com) is confirmed working -- Kell verified a real test email
///   landed in his inbox. Outbound send-as for that alias (SPF/DKIM, actually sending
///   mail FROM hello@dwelly.one) is NOT configured or tested -- not this link's problem,
///   since a mailto: only addresses a new message TO the alias; any reply Kell sends goes
///   out from whatever his Mail client sends as, not from the alias itself.
/// - FAQ & Help Center: no FAQ content exists anywhere yet (not in this ticket, not
///   elsewhere in the app) -- shown disabled with "Coming soon" rather than linking
///   somewhere fake, same honest-disabled-state pattern `SecurityPrivacyView` already
///   uses for Data Export.
struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showMailUnavailableAlert = false

    var body: some View {
        ZStack {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header

                    VStack(spacing: 12) {
                        NavigationLink(destination: SendFeedbackView(type: .feedback)) {
                            card(
                                icon: "square.and.pencil",
                                title: "Send Feedback",
                                body: "Help us improve Dwelly. Goes straight to our team.",
                                buttonTitle: "Send Feedback"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: SendFeedbackView(type: .bug)) {
                            card(
                                icon: "ladybug",
                                title: "Report a Bug",
                                body: "Something not working? Tell us what happened and what you expected instead.",
                                buttonTitle: "Report Bug"
                            )
                        }
                        .buttonStyle(.plain)

                        contactSupportCard
                        faqCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("No Mail Account", isPresented: $showMailUnavailableAlert) {
            Button("OK") {}
        } message: {
            Text("Set up a Mail account on this device to email hello@dwelly.one, or reach out from another device.")
        }
    }

    private var header: some View {
        HStack(spacing: 4) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")

            Text("Support & Feedback")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func card(icon: String, title: String, body: String, buttonTitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Theme.gold)
                    .frame(width: 32, height: 32)
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
            }
            Text(body)
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
            Text(buttonTitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.gold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.Payment.background)
                .clipShape(Capsule())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // Contact Support isn't a NavigationLink -- it opens Mail directly, same as the
    // design's own "Opens your device's native Mail app" caption describes.
    private var contactSupportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "envelope")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.gold)
                    .frame(width: 32, height: 32)
                Text("Contact Support")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
            }
            Text("Questions or issues? Reach us directly.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)

            Button(action: openMail) {
                HStack {
                    Text("hello@dwelly.one")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.gold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Theme.Payment.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Text("Opens your device's native Mail app — stays on-platform, no in-app browser.")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func openMail() {
        guard let url = URL(string: "mailto:hello@dwelly.one") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showMailUnavailableAlert = true
        }
    }

    // No FAQ content exists yet anywhere in the app or this ticket -- honest disabled
    // state rather than a dead or fake link, same pattern as SecurityPrivacyView's own
    // "Data Export: Coming soon" row.
    private var faqCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 18))
                .foregroundColor(Theme.Payment.textSupporting)
                .frame(width: 32, height: 32)
            Text("FAQ & Help Center")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)
            Spacer()
            Text("Coming soon")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(16)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
