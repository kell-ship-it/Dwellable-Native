import SwiftUI

/// T-134: the real Legal & About screen, pushed from Account Profile's Settings Card
/// (Figma node 711:5036 — only the row existed there, no destination, same gap as
/// Security & Privacy before T-131). Matches the locked detail frame at node 708:437.
struct LegalAboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.Payment.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                VStack(spacing: 0) {
                    NavigationLink(destination: TermsOfServiceView()) {
                        row(icon: "doc.text", title: "Terms of Service")
                    }
                    .buttonStyle(.plain)

                    Divider().background(Theme.Payment.timelineRail)

                    NavigationLink(destination: PrivacyPolicyView()) {
                        row(icon: "doc.text", title: "Privacy Policy")
                    }
                    .buttonStyle(.plain)

                    Divider().background(Theme.Payment.timelineRail)

                    NavigationLink(destination: AboutDwellyView()) {
                        row(icon: "doc.text", title: "About Dwelly")
                    }
                    .buttonStyle(.plain)
                }
                .background(Theme.Payment.pillBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Text("Dwelly v\(AppInfo.versionString)")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.top, 20)

                Spacer()
            }
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

            Text("Legal & About")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func row(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Theme.gold)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Theme.Payment.textHeading)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        LegalAboutView()
    }
}
