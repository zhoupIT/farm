# AGENTS.md - 王者农场小助手 AI 维护指南

本文档给后续接手本项目的 AI / 代码助手使用。目标是让 AI 在较少上下文下，也能快速理解项目用途、代码边界、常见修改入口和验证方式。

请优先阅读本文件，再根据任务读取相关源码。不要只凭记忆改动项目，尤其不要猜测游戏数据。

## 1. 项目定位

“王者农场小助手”是一个本地运行的 macOS 小工具，使用 Swift + SwiftUI 编写。它根据用户的农场等级、种植时间和内置作物表，计算：

- 自然成熟时间
- 完美浇水成熟时间
- 4 次浇水提醒时间
- 收菜时间
- 周末双倍收益窗口提示
- 当前时间和等级下的种植推荐

项目偏实用工具，不是营销页面，也不是联网服务。当前实现不访问网络，不上传数据，通知也只使用 macOS 本机通知。

## 2. 技术栈和运行环境

- 语言：Swift 5.10
- UI：SwiftUI + 少量 AppKit，用于读取 `NSImage`
- 平台：macOS 14+
- 构建方式：
  - Swift Package Manager：`swift build`
  - 手动打包 `.app`：`zsh scripts/build_app.sh`
- 资源管理：SwiftPM `.process("Resources")` + 手动打包脚本复制资源
- 通知能力：`UserNotifications`

注意：项目目录名包含空格，执行命令时要确保工作目录正确，路径需要加引号或使用工具的 `workdir`。

## 3. 当前目录结构

```text
wangzhe/
├── AGENTS.md
├── AppBundle/
│   └── Info.plist
├── Package.swift
├── README.md
├── Sources/
│   └── WangZheFarmAssistantApp/
│       ├── ContentView.swift
│       ├── FarmPlanner.swift
│       ├── Models.swift
│       ├── NotificationManager.swift
│       ├── WangZheFarmAssistantApp.swift
│       └── Resources/
│           └── CropImages/
│               └── *.png
├── scripts/
│   ├── build_app.sh
│   └── generate_crop_images.swift
└── 王者农场小助手.app/
```

当前仓库中没有 `PROJECT_DOCUMENTATION.md`。如果后续新建项目文档，请同步更新本节。

## 4. 重要文件职责

### `Package.swift`

Swift Package 配置文件。它定义包名、目标平台、可执行产物和资源目录。

关键点：

- package 名称：`WangZheFarmAssistant`
- executable 名称：`WangZheFarmAssistant`
- target 名称：`WangZheFarmAssistantApp`
- 源码路径：`Sources/WangZheFarmAssistantApp`
- 资源路径：`Resources`

如果新增资源目录，要同步检查这里的 `.process("Resources")` 是否仍然覆盖资源。

### `Sources/WangZheFarmAssistantApp/WangZheFarmAssistantApp.swift`

App 入口。

主要职责：

- 使用 `@main` 启动 SwiftUI App
- 创建窗口标题“王者农场小助手”
- 加载 `ContentView`
- 设置最小窗口尺寸 `980 x 680`
- 使用 `.windowResizability(.contentMinSize)` 防止窗口缩到内容放不下

通常不需要频繁修改。只有调整窗口策略、App 入口或全局 scene 时才改这里。

### `Sources/WangZheFarmAssistantApp/Models.swift`

数据模型和作物表，是最重要的数据维护入口。

包含：

- `GrowthTier`：成熟档位
- `Crop`：作物模型
- `cropCatalog`：内置作物数据
- `FarmEvent`：单个浇水 / 收菜事件
- `EventKind`：事件类型
- `FarmPlan`：一次完整种植计划

修改作物名称、等级、价格、图片名、备注，优先改这里。不要把作物数据散落到 UI 或算法文件里。

### `Sources/WangZheFarmAssistantApp/FarmPlanner.swift`

计算中心。所有时间规则、推荐规则和格式化逻辑都集中在这里。

包含：

- `makePlan(crop:plantTime:)`：生成完整种植计划
- `makeWateringEvents(crop:plantTime:)`：生成 4 个均匀浇水提醒点
- `isInWeekendBonusWindow(_:)`：判断是否在周末双倍窗口
- `weekendBonusHint(for:)`：生成周末收益提示
- `recommendedCrop(now:crops:playerLevel:)`：推荐作物
- `friendlyTime(_:now:)`：显示“今天 / 明天 / 后天 + 星期 + 时间”
- `relativeDuration(from:to:)`：显示相对时长
- `Crop.recommendationScore`：推荐排序分数
- `Crop.priceText`：收益展示文字

修改算法时，优先在这里动手，保持 `ContentView` 只负责展示和交互。

### `Sources/WangZheFarmAssistantApp/ContentView.swift`

主界面和交互。当前使用 `NavigationSplitView` 分为左侧控制区和右侧详情区。

主要区域：

- `sidebar`：左侧时间选择、等级设置、推荐卡、作物图鉴
- `recommendationCard`：当前推荐作物
- `detail`：右侧详情容器
- `hero`：作物大卡片
- `timeline`：浇水与收菜时间线
- `actionBar`：本机提醒按钮
- `dataNotes`：数据说明
- `CropRow`：作物列表行
- `TimelineRow`：时间线行
- `CropImage`：作物图片加载和兜底
- `AppTheme`：统一颜色

UI 修改尽量保持分块，不要把大段逻辑直接塞进 `body`。

### `Sources/WangZheFarmAssistantApp/NotificationManager.swift`

macOS 本机通知管理。

主要职责：

- 请求通知权限
- 过滤过去的事件
- 使用 `UNTimeIntervalNotificationTrigger` 安排未来提醒
- 清除待触发提醒

当前通知 identifier 使用事件 UUID：`wangzhe-farm-<uuid>`。清除提醒目前调用 `removeAllPendingNotificationRequests()`，会清除当前 App 的所有待触发通知。

### `scripts/generate_crop_images.swift`

本地 PNG 作物图生成脚本。使用 macOS 彩色 emoji 字体生成 360 x 360 图片。

使用方式：

```bash
swift scripts/generate_crop_images.swift
```

脚本默认从项目根目录运行，输出到：

```text
Sources/WangZheFarmAssistantApp/Resources/CropImages
```

新增作物图片时，需要在 `icons` 数组中增加一条 `CropIcon`，并确保文件名和 `Crop.imageName + ".png"` 对应。

### `scripts/build_app.sh`

手动打包 `.app` 的脚本。

使用方式：

```bash
zsh scripts/build_app.sh
```

脚本会：

- 清理 `.build/direct-release`
- 用 `swiftc` 直接编译 Swift 文件
- 创建 `王者农场小助手.app`
- 复制 `AppBundle/Info.plist`
- 复制可执行文件
- 复制 `Resources` 下的图片资源

注意：脚本当前固定使用 `-target arm64-apple-macosx14.0`，主要面向 Apple Silicon Mac。如果要兼容 Intel Mac，需要调整打包策略。

### `AppBundle/Info.plist`

手动打包 `.app` 时使用的应用信息配置。

包含：

- Bundle 名称
- Bundle Identifier
- 可执行文件名
- 最低 macOS 版本
- 通知展示相关配置

如果改 `scripts/build_app.sh` 里的可执行文件名，必须同步改 `CFBundleExecutable`。

## 5. 核心数据模型

### 成熟档位 `GrowthTier`

当前有四档：

| 枚举 | 展示名 | 自然成熟 | 完美浇水成熟 |
| --- | --- | --- | --- |
| `.oneHour` | `1 小时菜` | 1 小时 | 44 分钟 |
| `.eightHours` | `8 小时菜` | 8 小时 | 5 小时 52 分钟 |
| `.sixteenHours` | `16 小时菜` | 16 小时 | 11 小时 44 分钟 |
| `.thirtyTwoHours` | `32 小时菜` | 32 小时 | 23 小时 28 分钟 |

`wateringCount` 当前统一返回 `4`。如果游戏规则变化，优先从这里改。

### 作物 `Crop`

字段含义：

- `name`：作物中文名
- `tier`：成熟档位
- `unlockLevel`：解锁等级
- `normalPrice`：普通收益，未知填 `nil`
- `maxLevelPrice`：满级收益，未知填 `nil`
- `imageName`：图片名，不包含 `.png`
- `coinHint`：给用户看的收益 / 用途提示
- `isSupplemental`：是否为补充资料作物

维护原则：

- 数据不确定时，价格用 `nil`，不要编造数字。
- `imageName` 必须和 `Resources/CropImages/<imageName>.png` 对应。
- 价格未知的作物会显示“待补价格”，推荐分数会很低，不会优先推荐。
- `id` 当前为 `UUID()`，适合运行时列表展示。如果未来要做持久化、收藏或历史记录，需要改成稳定 id。

## 6. 核心算法规则

### 时间计算

`FarmPlanner.makePlan` 根据作物和种植时间计算：

- `naturalHarvestTime = plantTime + baseDuration`
- `perfectHarvestTime = plantTime + perfectDuration`
- 4 个浇水提醒
- 1 个收菜提醒
- 摘要文案
- 周末双倍提示

### 浇水提醒

当前不是官方逐次冷却模型，而是“均匀提醒法”：

```text
step = perfectDuration / (wateringCount + 1)
第 1 次浇水 = plantTime + step
第 2 次浇水 = plantTime + step * 2
第 3 次浇水 = plantTime + step * 3
第 4 次浇水 = plantTime + step * 4
```

原因：公开攻略通常只稳定给出浇满水后的总成熟时间，缺少可靠的逐次浇水冷却表。

### 周末双倍窗口

当前规则按中国时间 `Asia/Shanghai` 计算：

- 周五 18:00 后
- 周六全天
- 周日全天

Swift `Calendar.component(.weekday)` 中，周日是 `1`，周五是 `6`，周六是 `7`。改这里时要特别小心，不要按中文习惯误判 weekday。

### 推荐策略

`recommendedCrop(now:crops:playerLevel:)` 的当前逻辑：

1. 先按玩家等级过滤已解锁作物。
2. 如果没有已解锁作物，则兜底使用全量作物。
3. 优先选择完美成熟时间落入周末双倍窗口的作物。
4. 多个候选时，用 `recommendationScore` 比较。
5. 如果不落入双倍窗口：
   - 晚上 22:00 到次日 8:00：偏向 16 小时 / 32 小时作物
   - 白天 8:00 到 16:00：偏向 8 小时 / 16 小时作物
   - 其他时间：按收益分数选择

`recommendationScore = normalPrice / 完美成熟小时数`。价格未知的作物分数为 `0`。

## 7. UI 维护规则

当前界面是工具型应用，应保持清晰、紧凑、可扫描。

建议：

- 继续使用 `NavigationSplitView` 的左右结构。
- 左侧负责输入和列表，右侧负责当前计划详情。
- 卡片圆角保持 8 左右，和当前风格一致。
- 作物名可能很长，例如“辣椒（安琪拉椒）”，必须保留换行和缩放处理。
- 作物列表里未解锁作物要可见但不可选择。
- 时间和价格应使用 `monospacedDigit()`，避免数字跳动明显。
- 图标优先使用 SF Symbols。
- 不要把数据计算写进视图组件里，视图只调用 `FarmPlanner`。
- 新增界面状态时，优先考虑是否需要 `@State`、`@AppStorage` 或未来的持久化模型。

当前颜色集中在 `AppTheme`。改主题时优先改那里，不要在多个组件里散写颜色。

## 8. 图片资源规则

图片目录：

```text
Sources/WangZheFarmAssistantApp/Resources/CropImages
```

读取顺序在 `CropImage.loadImage(named:)` 中：

1. SwiftPM 资源 `Bundle.module` 的 `CropImages` 子目录
2. SwiftPM 资源根目录
3. 手动打包 App 的 `Bundle.main` / `CropImages`
4. 手动打包 App 的资源根目录
5. 系统命名图片兜底

替换官方图片时：

- 保持 PNG 格式。
- 文件名和 `Crop.imageName` 对齐。
- 不需要改 UI。
- 替换后运行 `swift build`，必要时再运行 `zsh scripts/build_app.sh`。

新增作物时：

1. 在 `Models.swift` 的 `cropCatalog` 增加 `Crop`。
2. 确认 `imageName`。
3. 放入同名 PNG，或更新 `generate_crop_images.swift` 生成占位图。
4. 运行构建验证。

## 9. 通知功能注意事项

通知代码只在本机工作，不需要网络。

修改时注意：

- `schedule(events:completion:)` 是异步回调，更新 SwiftUI 状态必须回到主线程。
- 当前只安排未来事件，过去事件会被过滤。
- 触发器使用相对时间 `UNTimeIntervalNotificationTrigger`，不是日历触发器。
- 如果未来要支持重复提醒、多计划、多地块，建议先设计稳定的 notification identifier，避免清除时误删全部提醒。
- macOS 通知权限被拒绝时，当前 UI 会显示“没有获得通知权限，或没有未来提醒”。

## 10. 常见任务入口

### 修改默认玩家等级

文件：

```text
Sources/WangZheFarmAssistantApp/ContentView.swift
```

位置：

```swift
@AppStorage("playerLevel") private var playerLevel = 53
```

### 修改作物数据

文件：

```text
Sources/WangZheFarmAssistantApp/Models.swift
```

位置：

```swift
let cropCatalog: [Crop] = [
    ...
]
```

### 修改成熟时间或浇水次数

文件：

```text
Sources/WangZheFarmAssistantApp/Models.swift
```

位置：

```swift
var baseDuration: TimeInterval
var perfectDuration: TimeInterval
var wateringCount: Int
```

### 修改浇水时间分布

文件：

```text
Sources/WangZheFarmAssistantApp/FarmPlanner.swift
```

位置：

```swift
private static func makeWateringEvents(crop:plantTime:) -> [FarmEvent]
```

### 修改推荐逻辑

文件：

```text
Sources/WangZheFarmAssistantApp/FarmPlanner.swift
```

位置：

```swift
static func recommendedCrop(now:crops:playerLevel:) -> Crop
```

### 修改时间显示

文件：

```text
Sources/WangZheFarmAssistantApp/FarmPlanner.swift
```

位置：

```swift
static func friendlyTime(_ date: Date, now: Date = Date()) -> String
```

### 修改界面布局

文件：

```text
Sources/WangZheFarmAssistantApp/ContentView.swift
```

优先查找：

- `sidebar`
- `recommendationCard`
- `detail`
- `hero`
- `timeline`
- `actionBar`
- `dataNotes`
- `CropRow`
- `TimelineRow`

### 修改主题颜色

文件：

```text
Sources/WangZheFarmAssistantApp/ContentView.swift
```

位置：

```swift
enum AppTheme
```

### 修改 App 打包信息

文件：

```text
AppBundle/Info.plist
scripts/build_app.sh
```

如果改 bundle id、App 名称、可执行文件名，要同时检查这两个文件。

## 11. 构建和验证

常用验证命令：

```bash
swift build
```

手动生成 App：

```bash
zsh scripts/build_app.sh
```

重新生成作物占位图：

```bash
swift scripts/generate_crop_images.swift
```

建议验证顺序：

1. 只改文档：检查 Markdown 结构即可。
2. 改 Swift 代码：至少运行 `swift build`。
3. 改资源或打包脚本：运行 `zsh scripts/build_app.sh`。
4. 改图片生成脚本：运行 `swift scripts/generate_crop_images.swift` 后确认 PNG 文件存在。
5. 改 UI：如果条件允许，打开 App 人工检查长作物名、未解锁状态、时间线、按钮文案。

当前目录不是 Git 仓库，无法依赖 `git diff` 查看改动。编辑时要更谨慎，尽量只改任务相关文件。

## 12. 数据来源和可信度

README 中记录了当前数据参考来源：

- `https://www.youxiabc.com/p/31979.html`
- `https://www.youxiabc.com/p/28375.html`
- `https://www.18183.com/gonglue/202605/hkvbkhgv.html`

维护原则：

- 游戏活动规则可能变化，游戏内显示优先。
- 不确定的价格填 `nil`，不要为了“完整”而猜。
- `isSupplemental: true` 表示补充资料作物，通常名称或等级大致可用，但价格不完整。
- 如果从网页更新数据，要记录来源和日期。
- 如果来源互相冲突，保守处理，并在 `coinHint` 或说明文案中体现不确定性。

## 13. 后续扩展方向

这些方向适合继续开发，但不要在无明确需求时一次性大改：

- 补齐官方作物表和准确收益
- 替换官方作物图片
- 更精确的浇水模型
- 多地块管理
- 种植历史记录
- 收益最大化推荐
- 用户自定义作物数据
- 菜单栏常驻小组件
- iCloud 同步
- 数据导入 / 导出 JSON

建议优先级：

1. 数据准确性
2. 推荐逻辑可解释性
3. 多地块和提醒体验
4. 数据编辑和持久化
5. 跨设备同步

## 14. AI 修改守则

后续 AI 在本项目中工作时，请遵守：

- 先读本文件，再读相关源码。
- 优先使用 `rg` / `rg --files` 查找文件和符号。
- 只改与任务直接相关的文件。
- 不要把计算逻辑写进 SwiftUI 视图。
- 不要把 UI 状态写进数据模型。
- 不要编造作物价格、等级或游戏规则。
- 不要删除现有 `.app`、图片资源或脚本，除非用户明确要求。
- 不要随意重命名 `target`、可执行文件、bundle 文件名；这些会影响打包。
- 修改 `Crop.imageName` 时必须同步检查图片文件。
- 修改通知逻辑时要考虑权限拒绝、过去事件、异步回调和主线程更新。
- 修改时间逻辑时必须使用中国时区 `Asia/Shanghai`。
- 修改周末窗口时要注意 Swift weekday 编号。
- 改完 Swift 代码后运行 `swift build`。
- 如果构建失败，先读报错，不要盲目大范围重构。

## 15. 快速心智模型

可以把项目记成四句话：

- `Models.swift` 管数据：作物、档位、计划结构。
- `FarmPlanner.swift` 管算法：成熟、浇水、双倍、推荐、时间格式。
- `ContentView.swift` 管界面：左侧输入列表，右侧详情时间线。
- `NotificationManager.swift` 管提醒：请求权限、安排通知、清除通知。

如果用户说“数据不对”，先看 `Models.swift`。
如果用户说“时间算错”，先看 `FarmPlanner.swift`。
如果用户说“界面显示不好”，先看 `ContentView.swift`。
如果用户说“提醒不好用”，先看 `NotificationManager.swift`。
