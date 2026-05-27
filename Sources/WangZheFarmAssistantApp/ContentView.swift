import AppKit
import SwiftUI

/// 主界面。
///
/// 这里尽量把“界面组件”拆成小块：作物图片、推荐区、时间线、数据说明分别写。
/// 不懂代码时也可以顺着标题看，想改哪一块就找对应的 `private var` 或 `private func`。
struct ContentView: View {
    @State private var plantTime = Date()
    @State private var selectedCrop = cropCatalog[0]
    @State private var notificationMessage = "还没有安排提醒"
    @AppStorage("playerLevel") private var playerLevel = 53

    private var recommendedCrop: Crop {
        FarmPlanner.recommendedCrop(now: plantTime, crops: cropCatalog, playerLevel: playerLevel)
    }

    private var plan: FarmPlan {
        FarmPlanner.makePlan(crop: selectedCrop, plantTime: plantTime)
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .font(AppTheme.textFont)
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear {
            selectedCrop = FarmPlanner.recommendedCrop(now: Date(), crops: cropCatalog, playerLevel: playerLevel)
        }
    }

    /// 左侧：时间选择、推荐作物、作物列表。
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            appTitle

            DatePicker(
                "种植时间",
                selection: $plantTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .font(.system(size: 14, weight: .regular))
            .padding(16)
            .background(AppTheme.surface)
            .foregroundStyle(AppTheme.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))
            .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.radius))

            Stepper(value: $playerLevel, in: 1...99) {
                HStack {
                    Label("我的农场等级", systemImage: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text("\(playerLevel) 级")
                        .font(.system(size: 14, weight: .medium).monospacedDigit())
                        .foregroundStyle(AppTheme.leaf)
                }
            }
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))
            .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.radius))

            Button {
                plantTime = Date()
                selectedCrop = FarmPlanner.recommendedCrop(now: Date(), crops: cropCatalog, playerLevel: playerLevel)
            } label: {
                Label("用当前时间并推荐", systemImage: "clock.arrow.circlepath")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.leaf)

            recommendationCard

            Text("作物图鉴")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.primaryText)
                .padding(.top, 8)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(cropCatalog) { crop in
                        CropRow(crop: crop, isSelected: crop == selectedCrop, isLocked: crop.unlockLevel > playerLevel)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if crop.unlockLevel <= playerLevel {
                                    selectedCrop = crop
                                }
                            }
                    }
                }
                .padding(.vertical, 4)
            }

            Spacer()
        }
        .padding(24)
        .background(AppTheme.sidebar)
        .navigationSplitViewColumnWidth(min: 340, ideal: 380)
    }

    /// 标题区。
    private var appTitle: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("WF")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.badgeGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))
                    .shadow(color: AppTheme.leaf.opacity(0.22), radius: 12, y: 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text("王者农场小助手")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.titleGradient)
                    Text("种菜、浇水、收菜，一眼安排好")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
    }

    /// 当前推荐卡片。
    private var recommendationCard: some View {
        HStack(spacing: 14) {
            CropImage(crop: recommendedCrop, size: 78)

            VStack(alignment: .leading, spacing: 5) {
                Label("当前推荐", systemImage: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.orange)
                Text(recommendedCrop.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(recommendedCrop.tier.note)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.secondaryText)
                Text("按 \(playerLevel) 级已解锁作物推荐")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.tertiaryText)
            }

            Spacer()

            Button {
                selectedCrop = recommendedCrop
            } label: {
                Image(systemName: "checkmark.circle.fill")
            }
            .buttonStyle(.borderless)
            .font(.system(size: 24, weight: .medium))
            .foregroundStyle(AppTheme.leaf)
            .help("选择推荐作物")
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeRadius, style: .continuous))
        .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.largeRadius))
        .shadow(color: AppTheme.leaf.opacity(0.16), radius: 16, y: 8)
    }

    /// 右侧详情区。
    private var detail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                timeline
                actionBar
                dataNotes
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.background)
    }

    /// 右侧顶部作物卡。
    private var hero: some View {
        HStack(alignment: .center, spacing: 30) {
            CropImage(crop: plan.crop, size: 180)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(plan.crop.name)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text(plan.crop.tier.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .fixedSize()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.chip)
                        .foregroundStyle(AppTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))
                }

                Text(plan.summary)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(2)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 210), spacing: 12)
                ], alignment: .leading, spacing: 12) {
                    metric(title: "自然成熟", value: FarmPlanner.friendlyTime(plan.naturalHarvestTime), icon: "leaf")
                    metric(title: "完美成熟", value: FarmPlanner.friendlyTime(plan.perfectHarvestTime), icon: "drop.fill")
                    metric(title: "预计收益", value: plan.crop.priceText, icon: "bitcoinsign.circle")
                }

                Label(plan.weekendBonusHint, systemImage: FarmPlanner.isInWeekendBonusWindow(plan.perfectHarvestTime) ? "gift.fill" : "calendar.badge.clock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.orange)
            }
        }
        .padding(28)
        .background(AppTheme.hero)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.xlRadius, style: .continuous))
        .overlay(AppTheme.glowBorder(cornerRadius: AppTheme.xlRadius))
        .shadow(color: AppTheme.leaf.opacity(0.20), radius: 22, y: 10)
    }

    /// 一个小指标块。
    private func metric(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.tertiaryText)
            Text(value)
                .font(.system(size: 14, weight: .medium).monospacedDigit())
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(minHeight: 78, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.metric)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))
    }

    /// 浇水与收菜时间线。
    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("浇水与收菜时间")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Text("还需 \(FarmPlanner.relativeDuration(from: plantTime, to: plan.perfectHarvestTime))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.leaf)
            }

            ForEach(plan.events) { event in
                TimelineRow(event: event)
            }
        }
    }

    /// 提醒按钮。
    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                NotificationManager.shared.schedule(events: plan.events) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let count):
                            notificationMessage = count > 0 ? "已安排 \(count) 个本机提醒" : "没有获得通知权限，或没有未来提醒"
                        case .failure(let error):
                            notificationMessage = "提醒安排失败：\(error.localizedDescription)"
                        }
                    }
                }
            } label: {
                Label("安排本机提醒", systemImage: "bell.badge")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.leaf)

            Button {
                NotificationManager.shared.clearPending()
                notificationMessage = "已清除本 App 待触发提醒"
            } label: {
                Label("清除提醒", systemImage: "bell.slash")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.bordered)

            Text(notificationMessage)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.secondaryText)

            Spacer()
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeRadius, style: .continuous))
        .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.largeRadius))
    }

    /// 资料与假设说明。
    private var dataNotes: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("数据说明")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)
            Text("内置数据根据网上玩家攻略整理：作物按 1 小时、8 小时、16 小时、32 小时档位计算；完美浇水成熟时间按约 44 分钟、5:52、11:44、23:28；周五 18:00 到周日 24:00 视为双倍窗口。由于活动可能调整，游戏内显示优先。")
                .foregroundStyle(AppTheme.secondaryText)
                Text("图鉴里有一部分作物来自补充资料页，只能确认名称和大致等级段，价格暂时显示为待补价格，不参与高收益优先推荐。图片为本地 PNG 素材；以后替换同名图片即可变成官方图。")
                .foregroundStyle(AppTheme.secondaryText)
        }
        .font(.system(size: 14, weight: .regular))
        .lineSpacing(2)
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeRadius, style: .continuous))
        .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.largeRadius))
    }
}

/// 作物列表行。
struct CropRow: View {
    let crop: Crop
    let isSelected: Bool
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 12) {
            CropImage(crop: crop, size: 48)
                .opacity(isLocked ? 0.45 : 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(crop.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isLocked ? AppTheme.tertiaryText : AppTheme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                Text("\(crop.tier.rawValue) · \(crop.coinHint)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)
                Text("解锁 \(crop.unlockLevel) 级 · \(crop.priceText)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(AppTheme.tertiaryText)
                    .lineLimit(2)
            }

            Spacer()

            if isLocked {
                Text("未解锁")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.tertiaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.chip)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.leaf)
            }
        }
        .padding(12)
        .background(isSelected ? AppTheme.selectedRow : AppTheme.surface)
        .opacity(isLocked ? 0.68 : 1)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeRadius, style: .continuous))
        .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.largeRadius))
    }
}

/// 时间线的一行。
struct TimelineRow: View {
    let event: FarmEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: event.kind == .watering ? "drop.fill" : "basket.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(event.kind == .watering ? AppTheme.water : AppTheme.orange)
                .frame(width: 34, height: 34)
                .background(AppTheme.chip)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text(FarmPlanner.friendlyTime(event.time))
                        .font(.system(size: 14, weight: .medium).monospacedDigit())
                        .foregroundStyle(AppTheme.primaryText)
                }

                Text(event.detail)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeRadius, style: .continuous))
        .overlay(AppTheme.glassBorder(cornerRadius: AppTheme.largeRadius))
    }
}

/// 作物图片。
///
/// Swift Package 中的资源用 `Bundle.module` 读取；打包脚本也会把资源复制到
/// App Bundle，所以如果以后不用 Swift Package 打包，也能从 `Bundle.main` 读取。
struct CropImage: View {
    let crop: Crop
    let size: CGFloat

    var body: some View {
        Group {
            if let image = loadImage(named: crop.imageName) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppTheme.leaf)
                    .padding(size * 0.24)
            }
        }
        .frame(width: size, height: size)
        .padding(size * 0.08)
        .background(AppTheme.imagePlate)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.xlRadius, style: .continuous))
        .shadow(color: AppTheme.leaf.opacity(0.14), radius: 14, y: 6)
    }

    private func loadImage(named name: String) -> NSImage? {
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "CropImages"),
           let image = NSImage(contentsOf: url) {
            return image
        }

        if let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        #endif

        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "CropImages"),
           let image = NSImage(contentsOf: url) {
            return image
        }

        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }

        return NSImage(named: name)
    }
}

/// 统一放颜色，避免界面颜色散在各处不好维护。
enum AppTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.93, green: 0.99, blue: 0.94),
            Color(red: 0.88, green: 0.96, blue: 1.00),
            Color(red: 0.96, green: 0.91, blue: 1.00)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let sidebar = LinearGradient(
        colors: [
            Color(red: 0.96, green: 1.00, blue: 0.96),
            Color(red: 0.90, green: 0.98, blue: 0.94),
            Color(red: 0.91, green: 0.95, blue: 1.00)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    static let hero = LinearGradient(
        colors: [
            Color(red: 0.86, green: 1.00, blue: 0.78),
            Color(red: 0.73, green: 0.96, blue: 1.00),
            Color(red: 0.91, green: 0.84, blue: 1.00)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let badgeGradient = LinearGradient(
        colors: [
            Color(red: 0.16, green: 0.76, blue: 0.42),
            Color(red: 0.15, green: 0.62, blue: 0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let titleGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.17, blue: 0.24),
            Color(red: 0.10, green: 0.52, blue: 0.35)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let surface = Color.white.opacity(0.72)
    static let selectedRow = Color(red: 0.78, green: 0.96, blue: 0.82).opacity(0.82)
    static let chip = Color.white.opacity(0.55)
    static let metric = Color.white.opacity(0.62)
    static let imagePlate = Color.white.opacity(0.38)
    static let primaryText = Color(red: 0.07, green: 0.14, blue: 0.20)
    static let secondaryText = Color(red: 0.25, green: 0.34, blue: 0.40)
    static let tertiaryText = Color(red: 0.45, green: 0.53, blue: 0.58)
    static let leaf = Color(red: 0.10, green: 0.66, blue: 0.38)
    static let water = Color(red: 0.10, green: 0.58, blue: 0.92)
    static let orange = Color(red: 0.95, green: 0.48, blue: 0.13)
    static let lavender = Color(red: 0.58, green: 0.43, blue: 0.95)
    static let radius: CGFloat = 10
    static let largeRadius: CGFloat = 16
    static let xlRadius: CGFloat = 22
    static let textFont = Font.system(size: 14, weight: .regular)

    static func glassBorder(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(Color.white.opacity(0.78), lineWidth: 1)
    }

    static func glowBorder(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        leaf.opacity(0.48),
                        water.opacity(0.42),
                        lavender.opacity(0.35),
                        orange.opacity(0.30)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.2
            )
    }
}
