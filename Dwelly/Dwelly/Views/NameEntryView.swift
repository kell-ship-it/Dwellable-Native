import SwiftUI

/// Onboarding "Name Entry" screen (T-110, T-238 Screen 4 — after Account Creation/Intro
/// Video/Paywall, before Intent Selection). Reused screen-chrome conventions from
/// `AccountCreationView`: serif heading, `Theme.Payment` palette, `.safeAreaInset(edge:
/// .bottom)` footer so the CTA never scrolls and still avoids the keyboard correctly.
struct NameEntryView: View {
    let userId: String
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var name: String = ""
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 130)

                Text("What's your name?")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)

                Spacer().frame(height: 16)

                Text("So Dwelly can speak to you personally.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 40)

                TextField("", text: $name, prompt: Text("Your first name").foregroundColor(Theme.Payment.textPlaceholder))
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Payment.textHeading)
                    .tint(Theme.gold)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .submitLabel(.continue)
                    .onSubmit { if isValid { continueTapped() } }
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .background(Theme.Payment.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .accessibilityLabel("Your first name")

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 28)

            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) { footer }
        .onAppear { isFocused = true }
    }

    private var footer: some View {
        Button(action: continueTapped) {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Payment.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
        }
        .background(Theme.gold)
        .clipShape(Capsule())
        .disabled(!isValid)
        .opacity(isValid ? 1 : 0.5)
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    private func continueTapped() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        ProfileManager.shared.setName(trimmed, userId: userId)
        onContinue()
    }
}

#Preview {
    NameEntryView(userId: "preview-user", onContinue: {}, onBack: {})
}
