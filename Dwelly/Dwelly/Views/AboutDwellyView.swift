import SwiftUI

/// T-134: the "About Dwelly" screen the ticket flagged as missing entirely. Built from
/// the locked Figma design (node 708:493, "About Dwellable") — copy and layout pulled
/// directly from there rather than invented, using the real bundle version instead of
/// Figma's static "Version 1.0.0 (Build 107)" placeholder.
struct AboutDwellyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 112)

                    Image("DwellyRockIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)

                    Text("Dwelly")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)

                    Text("A keeper of sacred moments.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)

                    Spacer().frame(height: 8)

                    Text("Dwelly exists to help you notice and dwell on God's presence across your entire life — in the extraordinary and the mundane — so you can see how God is forming you through every moment.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)

                    Text("Version \(AppInfo.versionString)")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
                .padding(.horizontal, 28)
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

            Text("About")
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
        AboutDwellyView()
    }
}
