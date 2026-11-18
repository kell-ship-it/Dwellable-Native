import Foundation

/// T-134: the real app version/build, replacing the hardcoded "1.0.0" strings in
/// SettingsView and the new Legal & About screens.
enum AppInfo {
    static var versionString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (Build \(build))"
    }
}
