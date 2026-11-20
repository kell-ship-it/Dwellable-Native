import Foundation
import UIKit
import UserNotifications
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

/// T-083: owns the FCM token lifecycle (request → register → sync to server →
/// refresh) and silent (content-available) notification handling. Everything
/// here is guarded so the app still runs before Kell drops in the real
/// GoogleService-Info.plist and APNs key -- see docs/MEMORY.md T-083 entry for
/// exactly which manual Firebase/Apple console steps remain.
final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()

    private(set) var fcmToken: String?
    private var apiClient: APIClient?
    private var userId: String?

    private override init() {}

    /// Call once a user is authenticated (AppView.onAppear, alongside
    /// SyncManager.updateUserId), so a token that arrived before login can
    /// still be synced once the user is known.
    func configure(apiClient: APIClient, userId: String) {
        self.apiClient = apiClient
        self.userId = userId
        if let token = fcmToken {
            syncTokenToServer(token)
        }
    }

    /// FirebaseApp.configure() needs GoogleService-Info.plist in the bundle --
    /// without it this just logs and no-ops, so a dev build with no Firebase
    /// project yet still launches normally.
    func configureFirebase() {
        #if canImport(FirebaseCore)
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            HTMLLogManager.shared.log("[PUSH] GoogleService-Info.plist not found -- skipping FirebaseApp.configure(). See T-083.", level: "WARNING")
            return
        }
        FirebaseApp.configure()
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif
        HTMLLogManager.shared.log("[PUSH] FirebaseApp configured", level: "INFO")
        #else
        HTMLLogManager.shared.log("[PUSH] FirebaseCore not linked -- Firebase SPM package not resolved yet. See T-083.", level: "WARNING")
        #endif
    }

    /// Requests notification permission, then registers for remote notifications
    /// so APNs hands this device a token Firebase can map to an FCM token.
    func requestAuthorizationAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                HTMLLogManager.shared.log("[PUSH] Authorization request failed: \(error.localizedDescription)", level: "ERROR")
                return
            }
            HTMLLogManager.shared.log("[PUSH] Authorization granted: \(granted)", level: "INFO")
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    /// AppDelegate forwards the raw APNs device token here so Firebase can map
    /// it to an FCM token (Messaging needs this on iOS even though FCM has its
    /// own token system).
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #else
        HTMLLogManager.shared.log("[PUSH] Got APNs device token but FirebaseMessaging isn't linked yet.", level: "WARNING")
        #endif
    }

    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        HTMLLogManager.shared.log("[PUSH] Failed to register for remote notifications: \(error.localizedDescription)", level: "ERROR")
    }

    /// Silent (content-available: 1) notification entry point -- AppDelegate's
    /// didReceiveRemoteNotification forwards here. No UI; this is for
    /// background data refresh triggered by a push (e.g. a server-side
    /// notification event wanting the client to resync).
    func handleSilentNotification(userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        HTMLLogManager.shared.log("[PUSH] Silent notification received: \(userInfo)", level: "INFO")
        // T-088 will log delivery here once analytics wiring for notification
        // events lands; T-084's scheduler is what actually sends these.
        completion(.newData)
    }

    private func syncTokenToServer(_ token: String) {
        guard let apiClient = apiClient, let userId = userId else {
            HTMLLogManager.shared.log("[PUSH] FCM token received before configure(apiClient:userId:) was called -- will sync once it is.", level: "WARNING")
            return
        }
        Task {
            do {
                try await apiClient.updateFCMToken(userId: userId, token: token)
                HTMLLogManager.shared.log("[PUSH] FCM token synced to server", level: "SUCCESS")
            } catch {
                HTMLLogManager.shared.log("[PUSH] Failed to sync FCM token: \(error.localizedDescription)", level: "ERROR")
            }
        }
    }
}

#if canImport(FirebaseMessaging)
extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        self.fcmToken = token
        HTMLLogManager.shared.log("[PUSH] FCM registration token: \(token)", level: "INFO")
        syncTokenToServer(token)
    }
}
#endif
