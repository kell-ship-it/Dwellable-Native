import SwiftUI

/// T-134: real Privacy Policy content, pulled directly from the locked Figma design
/// (node 709:543, "Privacy Policy") rather than invented — pushed from LegalAboutView.
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    private let blocks: [(title: String, body: String)] = [
        ("What We Collect", "Your moments, journal entries, and basic account info (name, email). See the Encryption screen for how this is protected."),
        ("How We Use It", "Solely to power your reflection experience — generating prompts, prayers, and journal synthesis. Never sold or shared with advertisers."),
        ("Third Parties", "Moment content is briefly sent to a cloud LLM provider for processing (Dwelly conversations, prayer, journal synthesis) — never stored by them as plaintext."),
        ("Your Rights", "Export your data (Post-MVP) or delete your account entirely, anytime, from Account Profile.")
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 72)

                    Text("Last updated: October 2026")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textSupporting)

                    ForEach(blocks, id: \.title) { block in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(block.title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Theme.Payment.textHeading)
                            Text(block.body)
                                .font(.system(size: 15))
                                .foregroundColor(Theme.Payment.textSupporting)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer().frame(height: 4)
                }
                .padding(.horizontal, 20)
            }

            header
        }
        .navigationBarBackButtonHidden(true)
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

            Text("Privacy Policy")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Theme.Payment.background)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
