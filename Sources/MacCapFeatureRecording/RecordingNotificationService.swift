import Foundation
import AppKit
import UserNotifications

@MainActor
final class RecordingNotificationService: NSObject, RecordingUserNotifying, UNUserNotificationCenterDelegate {
    private var center: UNUserNotificationCenter?
    private var hasRequestedAuthorization = false
    private var canUseUserNotifications: Bool {
        Bundle.main.bundleIdentifier != nil
    }

    func prepare() {
        guard canUseUserNotifications else {
            return
        }

        let center = UNUserNotificationCenter.current()
        self.center = center
        center.delegate = self

        guard !hasRequestedAuthorization else {
            return
        }

        hasRequestedAuthorization = true
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notifyRecordingSaved(at url: URL) {
        guard let center else {
            NSSound.beep()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "녹화본이 저장되었어요"
        content.body = "\(url.path)에 저장되었습니다."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "maccap.recording.saved.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
