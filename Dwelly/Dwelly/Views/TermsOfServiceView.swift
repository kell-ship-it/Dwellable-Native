import SwiftUI

/// T-134: real Terms of Service content, pulled directly from the locked Figma design
/// (node 709:505, "Terms of Service") rather than invented — pushed from LegalAboutView.
struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss

    private let blocks: [(title: String, body: String)] = [
        ("Acceptance of Terms", "By using Dwelly, you agree to these Terms of Service. If you don't agree, please don't use the app."),
        ("Your Content", "You own everything you capture — your moments, journals, and reflections. We never claim ownership of your content."),
        ("Acceptable Use", "Dwelly is a tool for personal spiritual reflection. Don't use it to harm others or violate the law."),
        ("Termination", "You can delete your account at any time from Account Profile. We may suspend accounts that violate these terms.")
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

            Text("Terms of Service")
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
        TermsOfServiceView()
    }
}
