import SwiftUI

/// T-306/T-308: lets a user declare their own country (never GPS/precise location --
/// a plain picker, defaulting to "not set" so an unknown country never silently renders
/// US resources) and re-view the support resources / pilot notice outside a flagged
/// conversation.
struct SafetySettingsView: View {
    @State private var declaredCountry: SafetyResourceCenter.SupportedCountry = SafetyResourceCenter.declaredCountry
    @State private var showSupportSheet = false
    @State private var showNoticeSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Country for help resources")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.tertiaryText)

                    Text("Used only to show the right local crisis/support numbers if they're ever needed — never your precise location.")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.tertiaryText)

                    Picker("Country", selection: $declaredCountry) {
                        ForEach(SafetyResourceCenter.SupportedCountry.allCases) { country in
                            Text(country.displayName).tag(country)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: declaredCountry) { newValue in
                        SafetyResourceCenter.declaredCountry = newValue
                    }
                    .padding(.vertical, 4)
                }
                .padding(Theme.Spacing.lg)
                .background(Theme.surfaceBackground)
                .cornerRadius(10)

                Button(action: { showSupportSheet = true }) {
                    HStack {
                        Text("View Support Resources")
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

                Button(action: { showNoticeSheet = true }) {
                    HStack {
                        Text("Safety Notice")
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
            .padding(Theme.Spacing.lg)
        }
        .navigationTitle("Safety")
        .sheet(isPresented: $showSupportSheet) { SafetySupportSheet() }
        .sheet(isPresented: $showNoticeSheet) { SafetyNoticeSheet() }
    }
}

#Preview {
    NavigationStack { SafetySettingsView() }
}
