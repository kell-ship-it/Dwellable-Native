import SwiftUI

struct DebugDiagnosticsView: View {
    @StateObject private var diagnostics = DiagnosticsManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 3) {
                            Text("‹")
                                .font(.system(size: 20))
                            Text("Settings")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                    Text("🐛 Debug Logs")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.text)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider()
                    .background(Theme.borderLight)

                // Controls
                HStack(spacing: 12) {
                    Button(action: { diagnostics.clearLogs() }) {
                        Text("Clear Logs")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Theme.error)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.error.opacity(0.1))
                            .cornerRadius(6)
                    }

                    Spacer()

                    Text("\(diagnostics.logs.count) logs")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider()
                    .background(Theme.borderLight)

                // Log list
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if diagnostics.logs.isEmpty {
                            VStack(spacing: 12) {
                                Text("No logs yet")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Theme.tertiaryText)
                                Text("Record a moment to see diagnostic logs")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Theme.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(diagnostics.logs, id: \.timestamp) { log in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(log.formatted)
                                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                                        .foregroundColor(logColor(for: log.level))
                                        .lineLimit(nil)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Theme.subtleOverlay)
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func logColor(for level: DiagnosticLog.LogLevel) -> Color {
        switch level {
        case .info:
            return Color(UIColor.systemBlue)
        case .success:
            return Color(UIColor.systemGreen)
        case .warning:
            return Color(UIColor.systemOrange)
        case .error:
            return Color(UIColor.systemRed)
        }
    }
}

#Preview {
    NavigationStack {
        DebugDiagnosticsView()
    }
}
