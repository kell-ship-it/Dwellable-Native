import SwiftUI

/// T-131's "Encryption Learn More" — rewritten to describe what T-062 actually shipped
/// (server-side encryption-at-rest for moment content, via a Supabase Edge Function
/// holding `MOMENT_ENCRYPTION_KEY`), not the zero-knowledge / client-side-key-derivation
/// architecture `docs/PILLAR_2_SECURITY_STRATEGY.md` originally specified but was never
/// built. Overstating this as end-to-end/zero-knowledge would be a real, user-facing
/// honesty problem, not just a documentation nitpick.
struct EncryptionInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 72)

                    Text("Your reflections are encrypted at rest. When you capture a moment, its content is encrypted before it's stored in our database — it isn't kept as plain, readable text.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("This protects your data from exposure if the database itself were ever compromised. It is not end-to-end encryption — Dwelly's servers hold the key needed to decrypt it, which is what lets features like Growth and search work on your reflections.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("A journal entry's title, moods, and scripture tags are stored unencrypted, so they can be searched and browsed quickly.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .fixedSize(horizontal: false, vertical: true)

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

            Text("How Your Data Is Protected")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Theme.Payment.background)
    }
}

#Preview {
    NavigationStack {
        EncryptionInfoView()
    }
}
