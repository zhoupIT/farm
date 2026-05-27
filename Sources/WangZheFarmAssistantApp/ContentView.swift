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
        .background(AppTheme.background)
        .onAppear {
            selectedCrop = FarmPlanner.recommendedCrop(now: Date(), crops: cropCatalog, playerLevel: playerLevel)
        }
    }

    /// 左侧：时间选择、推荐作物、作物列表。
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            appTitle

            DatePicker(
                "种植时间",
                selection: $plantTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .padding(12)
            .background(AppTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Stepper(value: $playerLevel, in: 1...99) {
                HStack {
                    Label("我的农场等级", systemImage: "person.crop.circle.badge.checkmark")
                    Spacer()
                    Text("\(playerLevel) 级")
                        .font(.headline.monospacedDigit())
                }
            }
            .padding(12)
            .background(AppTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                plantTime = Date()
                selectedCrop = FarmPlanner.recommendedCrop(now: Date(), crops: cropCatalog, playerLevel: playerLevel)
            } label: {
                Label("用当前时间并推荐", systemImage: "clock.arrow.circlepath")
                    .font(.headline.weight(.semibold))
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.accent)

            recommendationCard

            Text("作物图鉴")
                .font(.headline)
                .padding(.top, 4)

            ScrollView {
                LazyVStack(spacing: 8) {
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
        .padding(20)
        .background(AppTheme.sidebar)
        .navigationSplitViewColumnWidth(min: 330, ideal: 370)
    }

    /// 标题区。
    private var appTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("王者农场小助手")
                        .font(.largeTitle.weight(.bold))
                    Text("种菜、浇水、收菜，一眼安排好")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// 当前推荐卡片。
    private var recommendationCard: some View {
        HStack(spacing: 12) {
            CropImage(crop: recommendedCrop, size: 76)

            VStack(alignment: .leading, spacing: 5) {
                Label("当前推荐", systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                Text(recommendedCrop.name)
                    .font(.title3.weight(.bold))
                Text(recommendedCrop.tier.note)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("按 \(playerLevel) 级已解锁作物推荐")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                selectedCrop = recommendedCrop
            } label: {
                Image(systemName: "checkmark.circle.fill")
            }
            .buttonStyle(.borderless)
            .font(.title2)
            .help("选择推荐作物")
        }
        .padding(14)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        HStack(alignment: .center, spacing: 26) {
            CropImage(crop: plan.crop, size: 190)

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.crop.name)
                        .font(.system(size: 42, weight: .bold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text(plan.crop.tier.rawValue)
                        .font(.callout.weight(.semibold))
                        .fixedSize()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.accent.opacity(0.14))
                        .foregroundStyle(AppTheme.accent)
                        .clipShape(Capsule())
                }

                Text(plan.summary)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 205), spacing: 12)
                ], alignment: .leading, spacing: 12) {
                    metric(title: "自然成熟", value: FarmPlanner.friendlyTime(plan.naturalHarvestTime), icon: "leaf")
                    metric(title: "完美成熟", value: FarmPlanner.friendlyTime(plan.perfectHarvestTime), icon: "drop.fill")
                    metric(title: "预计收益", value: plan.crop.priceText, icon: "bitcoinsign.circle")
                }

                Label(plan.weekendBonusHint, systemImage: FarmPlanner.isInWeekendBonusWindow(plan.perfectHarvestTime) ? "gift.fill" : "calendar.badge.clock")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(FarmPlanner.isInWeekendBonusWindow(plan.perfectHarvestTime) ? .green : .orange)
            }
        }
        .padding(24)
        .background(AppTheme.hero)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// 一个小指标块。
    private func metric(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout.weight(.semibold).monospacedDigit())
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(minHeight: 78, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// 浇水与收菜时间线。
    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("浇水与收菜时间")
                    .font(.title2.weight(.semibold))
                Spacer()
                Text("还需 \(FarmPlanner.relativeDuration(from: plantTime, to: plan.perfectHarvestTime))")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
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
            }
            .buttonStyle(.borderedProminent)

            Button {
                NotificationManager.shared.clearPending()
                notificationMessage = "已清除本 App 待触发提醒"
            } label: {
                Label("清除提醒", systemImage: "bell.slash")
            }
            .buttonStyle(.bordered)

            Text(notificationMessage)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(16)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// 资料与假设说明。
    private var dataNotes: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("数据说明")
                .font(.title2.weight(.semibold))
            Text("内置数据根据网上玩家攻略整理：作物按 1 小时、8 小时、16 小时、32 小时档位计算；完美浇水成熟时间按约 44 分钟、5:52、11:44、23:28；周五 18:00 到周日 24:00 视为双倍窗口。由于活动可能调整，游戏内显示优先。")
                .foregroundStyle(.secondary)
                Text("图鉴里有一部分作物来自补充资料页，只能确认名称和大致等级段，价格暂时显示为待补价格，不参与高收益优先推荐。图片为本地 PNG 素材；以后替换同名图片即可变成官方图。")
                .foregroundStyle(.secondary)
        }
        .font(.callout)
        .padding(16)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isLocked ? .secondary : .primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                Text("\(crop.tier.rawValue) · \(crop.coinHint)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("解锁 \(crop.unlockLevel) 级 · \(crop.priceText)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if isLocked {
                Text("未解锁")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Capsule())
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(10)
        .background(isSelected ? AppTheme.selectedCrop : isLocked ? Color.white.opacity(0.24) : Color.white.opacity(0.48))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? AppTheme.accent.opacity(0.45) : Color.white.opacity(0.65), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 时间线的一行。
struct TimelineRow: View {
    let event: FarmEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: event.kind == .watering ? "drop.fill" : "basket.fill")
                .foregroundStyle(event.kind == .watering ? .blue : .green)
                .frame(width: 34, height: 34)
                .background((event.kind == .watering ? Color.blue : Color.green).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(event.title)
                        .font(.headline)
                    Spacer()
                    Text(FarmPlanner.friendlyTime(event.time))
                        .font(.headline.monospacedDigit())
                }

                Text(event.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(15)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    .foregroundStyle(.green)
                    .padding(size * 0.24)
            }
        }
        .frame(width: size, height: size)
        .background(.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
    static let background = Color(red: 0.95, green: 0.98, blue: 0.94)
    static let sidebar = Color(red: 0.91, green: 0.96, blue: 0.90)
    static let panel = Color.white.opacity(0.82)
    static let hero = LinearGradient(
        colors: [
            Color(red: 0.91, green: 0.98, blue: 0.86),
            Color(red: 1.00, green: 0.96, blue: 0.82)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accent = Color(red: 0.14, green: 0.48, blue: 0.25)
    static let selectedCrop = Color(red: 0.84, green: 0.94, blue: 0.78)
}
