import Foundation

/// 负责所有“时间计算”的小工具。
///
/// 这样写的好处是：界面只负责显示，算法集中在这里，未来修改规则比较容易。
struct FarmPlanner {
    /// 当前使用中国区时间显示。
    ///
    /// 你的系统时区是 Asia/Shanghai；这里仍然显式写出来，避免电脑临时切到别的时区时
    /// App 给出的王者活动时间发生偏移。
    static let chinaTimeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

    /// 把种植时间和作物合成完整计划。
    static func makePlan(crop: Crop, plantTime: Date) -> FarmPlan {
        let naturalHarvestTime = plantTime.addingTimeInterval(crop.tier.baseDuration)
        let perfectHarvestTime = plantTime.addingTimeInterval(crop.tier.perfectDuration)
        let wateringEvents = makeWateringEvents(crop: crop, plantTime: plantTime)

        let harvestEvent = FarmEvent(
            title: "收菜",
            time: perfectHarvestTime,
            detail: "按完美浇水估算，这时成熟；不浇水则 \(friendlyTime(naturalHarvestTime)) 成熟。",
            kind: .harvest
        )

        let summary = "\(crop.name)：完美浇水约 \(friendlyTime(perfectHarvestTime)) 收；不浇水约 \(friendlyTime(naturalHarvestTime)) 收。"

        return FarmPlan(
            crop: crop,
            plantTime: plantTime,
            naturalHarvestTime: naturalHarvestTime,
            perfectHarvestTime: perfectHarvestTime,
            events: wateringEvents + [harvestEvent],
            summary: summary,
            weekendBonusHint: weekendBonusHint(for: perfectHarvestTime)
        )
    }

    /// 生成“完美浇水”的提醒点。
    ///
    /// 说明：
    /// 网上经验一般只稳定给出“浇满后总成熟时间”，没有官方公开每次浇水的精确冷却表。
    /// 因此这里采用最实用的安排：把 4 次浇水均匀分布在种植到成熟之间，
    /// 让你不会长时间漏水；如果游戏内允许好友立刻连续浇，越早浇满越好。
    private static func makeWateringEvents(crop: Crop, plantTime: Date) -> [FarmEvent] {
        let count = crop.tier.wateringCount
        let step = crop.tier.perfectDuration / Double(count + 1)

        return (1...count).map { index in
            let time = plantTime.addingTimeInterval(step * Double(index))
            return FarmEvent(
                title: "第 \(index) 次浇水",
                time: time,
                detail: "尽量在这个时间点前后完成浇水；如果能提前找好友浇满，可以更稳。",
                kind: .watering
            )
        }
    }

    /// 判断收菜时间是否落在周末双倍收益窗口。
    ///
    /// 玩家攻略里常见说法：周五 18:00 到周日 24:00 是双倍收益。
    /// 这里用中国时间计算。
    static func isInWeekendBonusWindow(_ date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = chinaTimeZone

        let weekday = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)

        // Calendar 的 weekday：周日 = 1，周一 = 2，...，周五 = 6，周六 = 7。
        if weekday == 6 {
            return hour >= 18
        }

        if weekday == 7 || weekday == 1 {
            return true
        }

        return false
    }

    /// 给收菜时间生成双倍收益提示。
    static func weekendBonusHint(for harvestTime: Date) -> String {
        if isInWeekendBonusWindow(harvestTime) {
            return "会落在周末双倍窗口内，适合收。"
        }

        return "不在周末双倍窗口内；如果想冲收益，尽量让成熟时间落在周五 18:00 至周日 24:00。"
    }

    /// 根据当前时间推荐作物。
    ///
    /// 策略很朴素：优先选择完美成熟时间落入双倍窗口的作物；如果都不落入，
    /// 推荐不会跨太久、适合当前时间管理的作物。
    static func recommendedCrop(now: Date, crops: [Crop], playerLevel: Int) -> Crop {
        let availableCrops = crops.filter { $0.unlockLevel <= playerLevel }
        let candidates = availableCrops.isEmpty ? crops : availableCrops

        if let bonusCrop = candidates
            .filter({ crop in
                isInWeekendBonusWindow(now.addingTimeInterval(crop.tier.perfectDuration))
            })
            .max(by: { cropA, cropB in
                cropA.recommendationScore < cropB.recommendationScore
            }) {
            return bonusCrop
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = chinaTimeZone
        let hour = calendar.component(.hour, from: now)

        if hour >= 22 || hour < 8 {
            return candidates
                .filter { $0.tier == .sixteenHours || $0.tier == .thirtyTwoHours }
                .max(by: { $0.recommendationScore < $1.recommendationScore }) ?? candidates[0]
        }

        if hour >= 8 && hour < 16 {
            return candidates
                .filter { $0.tier == .eightHours || $0.tier == .sixteenHours }
                .max(by: { $0.recommendationScore < $1.recommendationScore }) ?? candidates[0]
        }

        return candidates.max(by: { $0.recommendationScore < $1.recommendationScore }) ?? candidates[0]
    }

    /// 统一格式化时间，界面里所有时间都用这一个格式。
    static func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = chinaTimeZone
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: date)
    }

    /// 更适合人看的时间，比如“今天 周五 11:32”。
    ///
    /// 只看“5月22日”需要你自己在脑子里换算；这里会根据当前日期补上
    /// 今天、明天、后天和星期几。超过后天时保留月日。
    static func friendlyTime(_ date: Date, now: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = chinaTimeZone

        let dayText: String
        if calendar.isDate(date, inSameDayAs: now) {
            dayText = "今天"
        } else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)),
                  calendar.isDate(date, inSameDayAs: tomorrow) {
            dayText = "明天"
        } else if let afterTomorrow = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: now)),
                  calendar.isDate(date, inSameDayAs: afterTomorrow) {
            dayText = "后天"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = chinaTimeZone
            dateFormatter.locale = Locale(identifier: "zh_CN")
            dateFormatter.dateFormat = "M月d日"
            dayText = dateFormatter.string(from: date)
        }

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.timeZone = chinaTimeZone
        weekdayFormatter.locale = Locale(identifier: "zh_CN")
        weekdayFormatter.dateFormat = "E"

        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = chinaTimeZone
        timeFormatter.locale = Locale(identifier: "zh_CN")
        timeFormatter.dateFormat = "HH:mm"

        return "\(dayText) \(weekdayFormatter.string(from: date)) \(timeFormatter.string(from: date))"
    }

    /// 显示一段“还剩多久”的文字。
    static func relativeDuration(from start: Date, to end: Date) -> String {
        let seconds = max(0, Int(end.timeIntervalSince(start)))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours) 小时 \(minutes) 分钟"
        }

        return "\(minutes) 分钟"
    }
}

extension Crop {
    /// 推荐排序分数。
    ///
    /// 价格未知的补充作物不会被完全排除，但分数偏低；这样它们能出现在图鉴里，
    /// 推荐时会优先选择价格明确、收益可计算的作物。
    var recommendationScore: Double {
        let price = Double(normalPrice ?? 0)
        let hours = max(1, tier.perfectDuration / 3600)
        return price / hours
    }

    /// 给界面显示的收益文字。
    var priceText: String {
        guard let normalPrice, let maxLevelPrice else {
            return "待补价格"
        }

        return "\(normalPrice) / \(maxLevelPrice)"
    }
}
