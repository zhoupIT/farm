import Foundation

/// 作物的基础成熟档位。
///
/// 目前网上能查到的“王者农场 / 菜狗农场”经验资料，多把作物分成
/// 1 小时、8 小时、16 小时、32 小时四类。浇满水后的成熟时间约为：
/// 44 分钟、5 小时 52 分钟、11 小时 44 分钟、23 小时 28 分钟。
enum GrowthTier: String, CaseIterable, Identifiable {
    case oneHour = "1 小时菜"
    case eightHours = "8 小时菜"
    case sixteenHours = "16 小时菜"
    case thirtyTwoHours = "32 小时菜"

    var id: String { rawValue }

    /// 不浇水时的自然成熟时间，单位是秒。
    var baseDuration: TimeInterval {
        switch self {
        case .oneHour:
            return 60 * 60
        case .eightHours:
            return 8 * 60 * 60
        case .sixteenHours:
            return 16 * 60 * 60
        case .thirtyTwoHours:
            return 32 * 60 * 60
        }
    }

    /// “完美浇水”后的经验成熟时间，单位是秒。
    ///
    /// 这里不是游戏官方接口数据，而是根据多篇攻略交叉整理出的玩家经验值。
    var perfectDuration: TimeInterval {
        switch self {
        case .oneHour:
            return 44 * 60
        case .eightHours:
            return (5 * 60 + 52) * 60
        case .sixteenHours:
            return (11 * 60 + 44) * 60
        case .thirtyTwoHours:
            return (23 * 60 + 28) * 60
        }
    }

    /// 每个档位的推荐“完美浇水”次数。
    ///
    /// 游戏活动可能会调整规则；如果未来发现次数变化，只改这里即可。
    var wateringCount: Int {
        4
    }

    /// 给用户看的简短描述。
    var note: String {
        switch self {
        case .oneHour:
            return "适合短时间在线，完美浇水后约 44 分钟收。"
        case .eightHours:
            return "适合白天种、下午或晚上收，完美浇水后约 5:52 收。"
        case .sixteenHours:
            return "适合晚上种、第二天收，完美浇水后约 11:44 收。"
        case .thirtyTwoHours:
            return "适合冲周末双倍，完美浇水后约 23:28 收。"
        }
    }
}

/// 一个可选择的作物。
///
/// 有些攻略只给成熟档位，没有稳定列出完整作物名。这里把名称设计成可读的
/// “档位 + 常见菜名”列表：计算真正依赖的是 `tier`，未来你可以按游戏内实际名称改 `name`。
struct Crop: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let tier: GrowthTier
    let unlockLevel: Int
    let normalPrice: Int?
    let maxLevelPrice: Int?
    let imageName: String
    let coinHint: String
    let isSupplemental: Bool
}

/// 预置作物表。
///
/// 为了让不懂代码的人也能维护，数据集中放在这里：
/// - 想改名称：改 `name`
/// - 想改成熟档位：改 `tier`
/// - 想加备注：改 `coinHint`
let cropCatalog: [Crop] = [
    Crop(name: "小麦", tier: .oneHour, unlockLevel: 1, normalPrice: nil, maxLevelPrice: nil, imageName: "wheat", coinHint: "基础作物", isSupplemental: true),
    Crop(name: "胡萝卜", tier: .oneHour, unlockLevel: 1, normalPrice: nil, maxLevelPrice: nil, imageName: "carrot", coinHint: "基础作物", isSupplemental: true),
    Crop(name: "白萝卜", tier: .oneHour, unlockLevel: 1, normalPrice: 32, maxLevelPrice: 64, imageName: "radish", coinHint: "新手循环刷经验", isSupplemental: false),
    Crop(name: "生菜", tier: .sixteenHours, unlockLevel: 2, normalPrice: 225, maxLevelPrice: 450, imageName: "lettuce", coinHint: "过夜早收", isSupplemental: false),
    Crop(name: "黄瓜", tier: .oneHour, unlockLevel: 3, normalPrice: 180, maxLevelPrice: 360, imageName: "cucumber", coinHint: "短线高频", isSupplemental: false),
    Crop(name: "南瓜", tier: .sixteenHours, unlockLevel: 4, normalPrice: 52, maxLevelPrice: 104, imageName: "pumpkin", coinHint: "中期过渡", isSupplemental: false),
    Crop(name: "葡萄", tier: .eightHours, unlockLevel: 5, normalPrice: 360, maxLevelPrice: 720, imageName: "grapes", coinHint: "上班/上课档", isSupplemental: false),
    Crop(name: "青椒", tier: .eightHours, unlockLevel: 7, normalPrice: 960, maxLevelPrice: 1920, imageName: "pepper", coinHint: "白天档", isSupplemental: false),
    Crop(name: "番茄", tier: .eightHours, unlockLevel: 9, normalPrice: nil, maxLevelPrice: nil, imageName: "tomato", coinHint: "中期作物", isSupplemental: true),
    Crop(name: "玉米", tier: .eightHours, unlockLevel: 9, normalPrice: nil, maxLevelPrice: nil, imageName: "corn", coinHint: "稳定收益", isSupplemental: true),
    Crop(name: "大豆", tier: .eightHours, unlockLevel: 9, normalPrice: nil, maxLevelPrice: nil, imageName: "soybean", coinHint: "稳定收益", isSupplemental: true),
    Crop(name: "茄子", tier: .eightHours, unlockLevel: 9, normalPrice: 4110, maxLevelPrice: 8220, imageName: "eggplant", coinHint: "8 小时高收益", isSupplemental: false),
    Crop(name: "大蒜", tier: .sixteenHours, unlockLevel: 10, normalPrice: 6030, maxLevelPrice: 12060, imageName: "garlic", coinHint: "睡前优先", isSupplemental: false),
    Crop(name: "向日葵", tier: .oneHour, unlockLevel: 12, normalPrice: 480, maxLevelPrice: 960, imageName: "sunflower", coinHint: "短线高等级", isSupplemental: false),
    Crop(name: "卷心菜", tier: .thirtyTwoHours, unlockLevel: 15, normalPrice: 10500, maxLevelPrice: 21000, imageName: "cabbage", coinHint: "卡周末双倍", isSupplemental: false),
    Crop(name: "草莓", tier: .sixteenHours, unlockLevel: 16, normalPrice: nil, maxLevelPrice: nil, imageName: "strawberry", coinHint: "后期高价值作物", isSupplemental: true),
    Crop(name: "大王菊", tier: .sixteenHours, unlockLevel: 16, normalPrice: nil, maxLevelPrice: nil, imageName: "chrysanthemum", coinHint: "后期高价值作物", isSupplemental: true),
    Crop(name: "松树葡萄", tier: .sixteenHours, unlockLevel: 16, normalPrice: nil, maxLevelPrice: nil, imageName: "pinegrape", coinHint: "后期高价值作物", isSupplemental: true),
    Crop(name: "金南瓜", tier: .sixteenHours, unlockLevel: 16, normalPrice: nil, maxLevelPrice: nil, imageName: "goldenpumpkin", coinHint: "后期高价值作物", isSupplemental: true),
    Crop(name: "香蕉", tier: .sixteenHours, unlockLevel: 18, normalPrice: 19320, maxLevelPrice: 38640, imageName: "banana", coinHint: "周末收益核心", isSupplemental: false),
    Crop(name: "蓝莓", tier: .thirtyTwoHours, unlockLevel: 20, normalPrice: 13000, maxLevelPrice: 26000, imageName: "blueberry", coinHint: "长线收益", isSupplemental: false),
    Crop(name: "柚子", tier: .sixteenHours, unlockLevel: 28, normalPrice: 22550, maxLevelPrice: 45100, imageName: "grapefruit", coinHint: "高等级高收益", isSupplemental: false),
    Crop(name: "西瓜", tier: .sixteenHours, unlockLevel: 38, normalPrice: 27400, maxLevelPrice: 54800, imageName: "watermelon", coinHint: "中后期金币首选", isSupplemental: false),
    Crop(name: "辣椒（安琪拉椒）", tier: .thirtyTwoHours, unlockLevel: 40, normalPrice: 12760, maxLevelPrice: 25520, imageName: "hotpepper", coinHint: "英雄变异期待", isSupplemental: false),
    Crop(name: "木瓜", tier: .sixteenHours, unlockLevel: 48, normalPrice: nil, maxLevelPrice: nil, imageName: "papaya", coinHint: "高金币收益作物", isSupplemental: true),
    Crop(name: "棉花", tier: .sixteenHours, unlockLevel: 50, normalPrice: nil, maxLevelPrice: nil, imageName: "cotton", coinHint: "50-60 级收益作物", isSupplemental: true),
    Crop(name: "橘子", tier: .sixteenHours, unlockLevel: 54, normalPrice: 38640, maxLevelPrice: 77280, imageName: "orange", coinHint: "54 级解锁，下一档主力", isSupplemental: false),
    Crop(name: "杨桃", tier: .sixteenHours, unlockLevel: 59, normalPrice: 45120, maxLevelPrice: 90240, imageName: "starfruit", coinHint: "59 级解锁，高等级收益", isSupplemental: false)
]

/// 一条浇水或收菜提醒。
struct FarmEvent: Identifiable {
    let id = UUID()
    let title: String
    let time: Date
    let detail: String
    let kind: EventKind
}

enum EventKind {
    case watering
    case harvest
}

/// 一次种植计划的计算结果。
struct FarmPlan {
    let crop: Crop
    let plantTime: Date
    let naturalHarvestTime: Date
    let perfectHarvestTime: Date
    let events: [FarmEvent]
    let summary: String
    let weekendBonusHint: String
}
