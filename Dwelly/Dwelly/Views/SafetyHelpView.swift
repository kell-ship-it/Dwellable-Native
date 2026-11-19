import SwiftUI

/// Account Profile > Support & Feedback > "Crisis & Safety Help". A plain, always-available
/// page for someone who is thinking about hurting themselves, or who knows someone who is.
/// All numbers and wording come from SafetyResourceCenter (country-aware, never a US
/// default), so this page can't drift from what the Capture screen shows.
struct SafetyHelpView: View {
    @Environment(\.dismiss) var dismiss

    private var country: SafetyResourceCenter.SupportedCountry { SafetyResourceCenter.declaredCountry }

    var body: some View {
        ZStack {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        section(
                            title: "If you're thinking about hurting yourself",
                            intro: "You don't have to carry this alone, and you don't have to wait until it feels bad enough. Please reach out right now — to a crisis line, a trusted person, or emergency services.",
                            lines: SafetyResourceCenter.selfRiskLines(for: country)
                        )

                        section(
                            title: "If someone you know may hurt themselves or someone else",
                            intro: "Take it seriously, even if you're not sure. If you can do so safely, stay with them and encourage them to talk to a crisis line or someone they trust. Crisis lines also take calls from people who are worried about someone else.",
                            lines: SafetyResourceCenter.thirdPartyRiskLines(for: country)
                        )

                        aboutCard

                        NavigationLink(destination: SafetySettingsView()) {
                            HStack {
                                Text(country == .notSet ? "Choose your country for local help" : "Showing help for \(country.displayName) — change")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Theme.gold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.Payment.textSupporting)
                            }
                            .padding(16)
                            .background(Theme.Payment.surfaceCard)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
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

            Text("Crisis & Safety Help")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func section(title: String, intro: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.Payment.textHeading)
            Text(intro)
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .fixedSize(horizontal: false, vertical: true)
            Text(lines.map { "• \($0)" }.joined(separator: "\n"))
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textHeading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What Dwelly does")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.Payment.textHeading)
            Text("Dwelly isn’t staffed or monitored live, and nothing is reported to anyone automatically. If a conversation shows a serious concern, Dwelly points you to real help and won’t turn that conversation into a journal entry. It can’t promise to notice everything, so please don’t wait on the app.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
