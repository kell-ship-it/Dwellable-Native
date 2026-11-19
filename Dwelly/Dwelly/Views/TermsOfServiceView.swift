import SwiftUI

/// T-134, revised T-309: real Terms of Service content. The original 4 blocks (pulled
/// from Figma node 709:505) were accurate but incomplete for a pilot that includes a
/// crisis/misuse safety layer (T-125) -- added the sections that layer actually
/// requires: what Dwelly is/isn't, the pilot's real safety limits, and a liability
/// section that doesn't overclaim. Grounded in what T-302/T-303/T-304/T-308 actually
/// do, not aspirational language -- e.g. "no live monitoring" is true because nothing
/// in this codebase monitors conversations live; it isn't a legal-sufficiency claim.
struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss

    private let blocks: [(title: String, body: String)] = [
        ("Acceptance of Terms", "By using Dwelly, you agree to these Terms of Service. If you don't agree, please don't use the app."),
        ("What Dwelly Is", "Dwelly is a tool for personal, faith-centered reflection — a space to process your life with God. It is not therapy, not crisis counseling, and not a medical or mental-health service. It doesn't replace a doctor, counselor, pastor, or emergency services."),
        ("Your Content", "You own everything you capture — your moments, journals, and reflections. We never claim ownership of your content."),
        ("Safety Limits, Honestly Stated", "Dwelly tries to respond with care if something you share suggests real danger, and may point you to resources like a crisis line. But during this pilot: no one reviews your conversations live, nothing is automatically reported to police or any outside party, and Dwelly cannot promise to catch everything. If a conversation reflects a genuine, current concern for your safety or someone else's, Dwelly won't turn that conversation into a journal entry or use it to update your profile — it stays focused on getting you to real support instead. If you or someone else may be in danger, please contact a trusted person, a crisis line, or emergency services directly — don't rely on Dwelly to notice or respond in time."),
        ("Acceptable Use", "Dwelly is a tool for personal spiritual reflection. Don't use it to harm others or violate the law. We may decline to generate a response to a specific request that asks for help carrying out harm to yourself or someone else; declining a specific request is not the same as ending your access to the app."),
        ("Liability", "To the fullest extent the law allows, Dwelly and its creator aren't liable for how you use the app or decisions you make based on it — but this limitation doesn't override any duty the law doesn't let us waive (for example, protections that can't be contracted away). Nothing here is a promise of insurance, legal privilege, or guaranteed confidentiality."),
        ("Termination", "You can delete your account at any time from Account Profile. We may suspend accounts that violate these terms."),
        ("Changes to These Terms", "If these Terms change in a way that affects your rights, we'll show you the updated version and ask you to acknowledge it again before you continue using Dwelly."),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 72)

                    Text("Last updated: November 19, 2026")
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
