import Foundation
import UserNotifications

/// macOS 本地通知管理。
///
/// App 不会联网，也不会上传任何信息；通知只在你的电脑本地排程。
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// 请求通知权限并安排一组提醒。
    ///
    /// `completion` 用来把成功或失败结果告诉界面，方便显示给用户。
    func schedule(events: [FarmEvent], completion: @escaping (Result<Int, Error>) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard granted else {
                completion(.success(0))
                return
            }

            let futureEvents = events.filter { $0.time > Date() }

            for event in futureEvents {
                let content = UNMutableNotificationContent()
                content.title = "王者农场：\(event.title)"
                content.body = event.detail
                content.sound = .default

                let interval = max(1, event.time.timeIntervalSinceNow)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "wangzhe-farm-\(event.id.uuidString)",
                    content: content,
                    trigger: trigger
                )

                center.add(request)
            }

            completion(.success(futureEvents.count))
        }
    }

    /// 清除本 App 安排过但还没触发的提醒。
    func clearPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
