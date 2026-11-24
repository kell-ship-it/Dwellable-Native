import SwiftUI

/// T-134, revised T-309: real Privacy Policy content, re-grounded in what the
/// codebase actually does (verified directly, not assumed, before writing this):
/// moment/journal body text is AES-256-GCM encrypted at rest (supabase/functions/
/// _shared/encryption.ts) and only decrypted transiently inside save-moment/
/// fetch-moments; journal title/moods/scripture are stored unencrypted
/// (journal_entries table) since they're spec'd as non-sensitive; conversation text
/// is sent to OpenAI for processing (llm-proxy; Groq was removed Nov 2026); the T-125 safety layer
/// (T-302/T-303) runs an OpenAI moderation check + a classification pass on every
/// capture-conversation message, and logs only non-identifiable category/failure
/// counts (safety_diagnostics/safety_event_aggregate), never message content or a
/// persistent per-user label. "No human reviews your conversations" means no routine
/// review process exists -- it does NOT mean no one technically could (the operator
/// holds the encryption key and database access, same as any operator of a
/// server-side-encrypted system); this policy says that plainly rather than
/// claiming a stronger guarantee than is true.
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    private let blocks: [(title: String, body: String)] = [
        ("What We Collect", "Your moments, journal entries, and basic account info (name, email). A saved moment includes the back-and-forth of the conversation \u{2014} Dwelly's prompts as well as your own words \u{2014} so you can look back at what you were answering. A conversation that shows a serious safety concern is not saved at all. See the Encryption screen for how this is protected."),
        ("How We Use It", "Solely to power your reflection experience — generating prompts, prayers, and journal synthesis. Never sold or shared with advertisers."),
        ("Third Parties", "Moment and conversation content is sent to our AI provider (OpenAI) to generate Dwelly's responses, prayers, and journal synthesis, and to OpenAI's moderation service as part of our safety check (see \"Safety Checks\" below). It is not stored by OpenAI as part of a permanent profile of you."),
        ("Safety Checks", "Every message you send in a Dwelly conversation (the back-and-forth reflection screen) is checked for signs of real danger (to you or someone else) before and after Dwelly responds — this is automated, not reviewed by a person in the moment. This specific check does not currently run on your synthesized journal entry (the title/body Dwelly writes afterward) or on your Growth tab's \"Your Narrative\" summary — those are generated from reflection content you already sent through the checked conversation, but aren't independently re-checked themselves. If a conversation reflects a genuine, current safety concern, we don't create a journal entry or feed that conversation into your profile at all — the whole conversation is excluded, not just the flagged part. We log only a non-identifying count of how often the conversation check fires (by category and day) and short-lived technical failure logs — never your message content, and never a permanent label tied to your account. Whether and how long the conversation text itself is retained by our processing providers during this is still being finalized — we aren't stating a retention period here until that's settled, rather than guess."),
        ("Human Access", "No one at Dwelly routinely reviews your conversations. We don't promise your content is something no one could ever technically access — like any service that processes your data to work, the people who operate it have the technical means to access it if truly necessary (for example, fixing a serious bug), but there is no staffed review process watching your conversations."),
        ("Lawful Disclosure", "We do not sell or share your content with advertisers. We may be legally required to disclose information in response to a valid legal process (such as a subpoena or court order) — we don't promise your data is never disclosed under any circumstance, because that wouldn't be true."),
        ("Retention & Deletion", "You can delete your account at any time from Account Profile, which permanently removes your moments, journal entries, and related data. Safety-check logs are either non-identifying aggregate counts or short-lived technical diagnostics not tied to your account."),
        ("This Isn't a Liability Waiver", "This Privacy Policy describes what we actually do with your data. It does not limit our legal responsibility — that's covered separately in the Terms of Service, and only to the extent the law allows."),
        ("Your Rights", "Export your data (Post-MVP) or delete your account entirely, anytime, from Account Profile.")
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
