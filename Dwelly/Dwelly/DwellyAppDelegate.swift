import UIKit
import UserNotifications

/// T-083: UIKit AppDelegate hook SwiftUI's own App protocol doesn't provide --
/// Firebase's APNs token hand-off and silent (content-available) notifications
/// both need didRegisterForRemoteNotifications / didReceiveRemoteNotification,
/// which only exist on UIApplicationDelegate. Wired into DwellyApp via
/// @UIApplicationDelegateAdaptor.
final class DwellyAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        PushNotificationManager.shared.configureFirebase()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationManager.shared.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushNotificationManager.shared.didFailToRegisterForRemoteNotifications(withError: error)
    }

    /// Silent push entry point. `content-available: 1` with no `alert` key lands
    /// here instead of showing a banner -- the UIBackgroundModes `remote-notification`
    /// entitlement (see T-083's manual-steps note) is what makes iOS wake the app
    /// for this at all when it isn't foregrounded.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        PushNotificationManager.shared.handleSilentNotification(userInfo: userInfo, completion: completionHandler)
    }

    /// A visible push arriving while the app is in the foreground -- still show
    /// it, same as if the app were backgrounded (no visible-push UI exists yet
    /// to suppress it; T-087/T-089 own the actual copy and device testing).
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
