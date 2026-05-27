import SwiftUI

/// App 的入口。
///
/// `@main` 表示程序从这里启动。SwiftUI 会自动创建窗口，并把 `ContentView`
/// 放进窗口里显示。
@main
struct WangZheFarmAssistantApp: App {
    var body: some Scene {
        WindowGroup("王者农场小助手") {
            ContentView()
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowResizability(.contentMinSize)
    }
}
