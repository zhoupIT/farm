import AppKit
import Foundation

/// 这个脚本用 macOS 自带的彩色 emoji 字体生成一套 PNG 作物图片。
///
/// 为什么不用直接画在 App 里？
/// 因为用户希望“图片放到项目里”，所以这里把图片生成到
/// `Sources/WangZheFarmAssistantApp/Resources/CropImages`，之后 App 离线也能显示。

struct CropIcon {
    let fileName: String
    let emoji: String
    let backgroundTop: NSColor
    let backgroundBottom: NSColor
}

let projectURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = projectURL
    .appendingPathComponent("Sources/WangZheFarmAssistantApp/Resources/CropImages", isDirectory: true)

try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

let icons: [CropIcon] = [
    CropIcon(fileName: "radish.png", emoji: "🥕", backgroundTop: NSColor(red: 1.00, green: 0.94, blue: 0.82, alpha: 1), backgroundBottom: NSColor(red: 0.93, green: 0.55, blue: 0.34, alpha: 1)),
    CropIcon(fileName: "wheat.png", emoji: "🌾", backgroundTop: NSColor(red: 1.00, green: 0.96, blue: 0.75, alpha: 1), backgroundBottom: NSColor(red: 0.79, green: 0.59, blue: 0.24, alpha: 1)),
    CropIcon(fileName: "carrot.png", emoji: "🥕", backgroundTop: NSColor(red: 1.00, green: 0.93, blue: 0.78, alpha: 1), backgroundBottom: NSColor(red: 0.95, green: 0.49, blue: 0.21, alpha: 1)),
    CropIcon(fileName: "cucumber.png", emoji: "🥒", backgroundTop: NSColor(red: 0.88, green: 0.98, blue: 0.76, alpha: 1), backgroundBottom: NSColor(red: 0.37, green: 0.69, blue: 0.30, alpha: 1)),
    CropIcon(fileName: "sunflower.png", emoji: "🌻", backgroundTop: NSColor(red: 1.00, green: 0.95, blue: 0.67, alpha: 1), backgroundBottom: NSColor(red: 0.95, green: 0.64, blue: 0.18, alpha: 1)),
    CropIcon(fileName: "grapes.png", emoji: "🍇", backgroundTop: NSColor(red: 0.91, green: 0.84, blue: 1.00, alpha: 1), backgroundBottom: NSColor(red: 0.52, green: 0.35, blue: 0.85, alpha: 1)),
    CropIcon(fileName: "pepper.png", emoji: "🫑", backgroundTop: NSColor(red: 0.85, green: 0.98, blue: 0.82, alpha: 1), backgroundBottom: NSColor(red: 0.27, green: 0.68, blue: 0.36, alpha: 1)),
    CropIcon(fileName: "eggplant.png", emoji: "🍆", backgroundTop: NSColor(red: 0.91, green: 0.85, blue: 1.00, alpha: 1), backgroundBottom: NSColor(red: 0.45, green: 0.31, blue: 0.71, alpha: 1)),
    CropIcon(fileName: "tomato.png", emoji: "🍅", backgroundTop: NSColor(red: 1.00, green: 0.86, blue: 0.80, alpha: 1), backgroundBottom: NSColor(red: 0.85, green: 0.25, blue: 0.19, alpha: 1)),
    CropIcon(fileName: "corn.png", emoji: "🌽", backgroundTop: NSColor(red: 1.00, green: 0.96, blue: 0.70, alpha: 1), backgroundBottom: NSColor(red: 0.83, green: 0.66, blue: 0.19, alpha: 1)),
    CropIcon(fileName: "soybean.png", emoji: "🫘", backgroundTop: NSColor(red: 0.93, green: 0.88, blue: 0.76, alpha: 1), backgroundBottom: NSColor(red: 0.60, green: 0.45, blue: 0.30, alpha: 1)),
    CropIcon(fileName: "lettuce.png", emoji: "🥬", backgroundTop: NSColor(red: 0.87, green: 1.00, blue: 0.82, alpha: 1), backgroundBottom: NSColor(red: 0.35, green: 0.73, blue: 0.40, alpha: 1)),
    CropIcon(fileName: "pumpkin.png", emoji: "🎃", backgroundTop: NSColor(red: 1.00, green: 0.89, blue: 0.72, alpha: 1), backgroundBottom: NSColor(red: 0.91, green: 0.43, blue: 0.17, alpha: 1)),
    CropIcon(fileName: "garlic.png", emoji: "🧄", backgroundTop: NSColor(red: 0.98, green: 0.95, blue: 0.88, alpha: 1), backgroundBottom: NSColor(red: 0.76, green: 0.68, blue: 0.55, alpha: 1)),
    CropIcon(fileName: "banana.png", emoji: "🍌", backgroundTop: NSColor(red: 1.00, green: 0.96, blue: 0.70, alpha: 1), backgroundBottom: NSColor(red: 0.92, green: 0.74, blue: 0.20, alpha: 1)),
    CropIcon(fileName: "grapefruit.png", emoji: "🍊", backgroundTop: NSColor(red: 1.00, green: 0.92, blue: 0.76, alpha: 1), backgroundBottom: NSColor(red: 0.91, green: 0.48, blue: 0.20, alpha: 1)),
    CropIcon(fileName: "watermelon.png", emoji: "🍉", backgroundTop: NSColor(red: 0.91, green: 1.00, blue: 0.86, alpha: 1), backgroundBottom: NSColor(red: 0.25, green: 0.68, blue: 0.39, alpha: 1)),
    CropIcon(fileName: "cabbage.png", emoji: "🥬", backgroundTop: NSColor(red: 0.88, green: 0.98, blue: 0.91, alpha: 1), backgroundBottom: NSColor(red: 0.38, green: 0.64, blue: 0.48, alpha: 1)),
    CropIcon(fileName: "blueberry.png", emoji: "🫐", backgroundTop: NSColor(red: 0.83, green: 0.89, blue: 1.00, alpha: 1), backgroundBottom: NSColor(red: 0.28, green: 0.43, blue: 0.80, alpha: 1)),
    CropIcon(fileName: "strawberry.png", emoji: "🍓", backgroundTop: NSColor(red: 1.00, green: 0.86, blue: 0.86, alpha: 1), backgroundBottom: NSColor(red: 0.83, green: 0.18, blue: 0.24, alpha: 1)),
    CropIcon(fileName: "chrysanthemum.png", emoji: "🌼", backgroundTop: NSColor(red: 1.00, green: 0.96, blue: 0.78, alpha: 1), backgroundBottom: NSColor(red: 0.87, green: 0.67, blue: 0.20, alpha: 1)),
    CropIcon(fileName: "pinegrape.png", emoji: "🍇", backgroundTop: NSColor(red: 0.82, green: 0.94, blue: 0.90, alpha: 1), backgroundBottom: NSColor(red: 0.30, green: 0.56, blue: 0.43, alpha: 1)),
    CropIcon(fileName: "goldenpumpkin.png", emoji: "🎃", backgroundTop: NSColor(red: 1.00, green: 0.95, blue: 0.68, alpha: 1), backgroundBottom: NSColor(red: 0.93, green: 0.62, blue: 0.12, alpha: 1)),
    CropIcon(fileName: "hotpepper.png", emoji: "🌶️", backgroundTop: NSColor(red: 1.00, green: 0.84, blue: 0.78, alpha: 1), backgroundBottom: NSColor(red: 0.85, green: 0.20, blue: 0.17, alpha: 1)),
    CropIcon(fileName: "papaya.png", emoji: "🥭", backgroundTop: NSColor(red: 1.00, green: 0.91, blue: 0.74, alpha: 1), backgroundBottom: NSColor(red: 0.90, green: 0.54, blue: 0.18, alpha: 1)),
    CropIcon(fileName: "cotton.png", emoji: "☁️", backgroundTop: NSColor(red: 0.91, green: 0.96, blue: 1.00, alpha: 1), backgroundBottom: NSColor(red: 0.63, green: 0.78, blue: 0.90, alpha: 1)),
    CropIcon(fileName: "orange.png", emoji: "🍊", backgroundTop: NSColor(red: 1.00, green: 0.92, blue: 0.74, alpha: 1), backgroundBottom: NSColor(red: 0.93, green: 0.51, blue: 0.14, alpha: 1)),
    CropIcon(fileName: "starfruit.png", emoji: "⭐️", backgroundTop: NSColor(red: 1.00, green: 0.96, blue: 0.70, alpha: 1), backgroundBottom: NSColor(red: 0.91, green: 0.72, blue: 0.18, alpha: 1))
]

func drawIcon(_ icon: CropIcon) throws {
    let size = NSSize(width: 360, height: 360)
    let image = NSImage(size: size)

    image.lockFocus()

    let rect = NSRect(origin: .zero, size: size)
    let gradient = NSGradient(starting: icon.backgroundTop, ending: icon.backgroundBottom)
    gradient?.draw(in: rect, angle: -35)

    NSColor.white.withAlphaComponent(0.42).setFill()
    NSBezierPath(ovalIn: NSRect(x: 42, y: 38, width: 276, height: 276)).fill()

    NSColor.black.withAlphaComponent(0.10).setFill()
    NSBezierPath(ovalIn: NSRect(x: 95, y: 48, width: 170, height: 34)).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: "Apple Color Emoji", size: 176) ?? NSFont.systemFont(ofSize: 176),
        .paragraphStyle: paragraph
    ]

    let textRect = NSRect(x: 0, y: 82, width: size.width, height: 210)
    icon.emoji.draw(in: textRect, withAttributes: attributes)

    image.unlockFocus()

    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "CropIconGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法生成 \(icon.fileName)"])
    }

    try png.write(to: outputURL.appendingPathComponent(icon.fileName))
}

for icon in icons {
    try drawIcon(icon)
}

print("已生成 \(icons.count) 张作物 PNG：\(outputURL.path)")
