#!/usr/bin/swift
import Cocoa

let _ = NSApplication.shared

func makeIconPNG(size: Int) -> Data? {
    let s = CGFloat(size)
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil, width: size, height: size,
        bitsPerComponent: 8, bytesPerRow: 0, space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // Rounded rect clip (macOS icon corner radius ~22%)
    let r = s * 0.22
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Dark blue gradient background
    let c1 = CGColor(red: 0/255, green: 45/255, blue: 82/255, alpha: 1)   // #002d52
    let c2 = CGColor(red: 0/255, green: 70/255, blue: 130/255, alpha: 1)  // #004682
    let gradColors = [c1, c2] as CFArray
    if let grad = CGGradient(colorsSpace: cs, colors: gradColors, locations: [0, 1]) {
        ctx.drawLinearGradient(grad,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: s, y: s),
            options: [])
    }

    // Subtle sound-wave arcs on the right side (orange)
    ctx.setStrokeColor(CGColor(red: 0.97, green: 0.41, blue: 0, alpha: 0.85))
    let lineWidth = max(1, s * 0.038)
    ctx.setLineWidth(lineWidth)
    ctx.setLineCap(.round)

    let cx = s * 0.735
    let cy = s * 0.50

    // Three arcs - small, medium, large
    for (i, radius) in [(s * 0.09), (s * 0.17), (s * 0.25)].enumerated() {
        ctx.setAlpha(1.0 - CGFloat(i) * 0.18)
        let arc = CGMutablePath()
        arc.addArc(center: CGPoint(x: cx, y: cy),
                   radius: radius,
                   startAngle: -.pi / 3,
                   endAngle:  .pi / 3,
                   clockwise: false)
        ctx.addPath(arc)
        ctx.strokePath()
    }
    ctx.setAlpha(1.0)

    // Use NSGraphicsContext for text
    let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = nsCtx

    // Bold white "N"
    let nFontSize = s * 0.56
    let nFont = NSFont(name: "HelveticaNeue-Bold", size: nFontSize)
             ?? NSFont.boldSystemFont(ofSize: nFontSize)
    let nAttrs: [NSAttributedString.Key: Any] = [
        .font: nFont,
        .foregroundColor: NSColor.white
    ]
    let nStr = NSAttributedString(string: "N", attributes: nAttrs)
    let nSz = nStr.size()
    // Center horizontally in left ~62% of icon
    let nX = s * 0.31 - nSz.width / 2
    let nY = (s - nSz.height) / 2
    nStr.draw(at: CGPoint(x: nX, y: nY))

    // Small orange music note below the arcs
    let noteFontSize = s * 0.20
    let noteFont = NSFont.systemFont(ofSize: noteFontSize)
    let noteAttrs: [NSAttributedString.Key: Any] = [
        .font: noteFont,
        .foregroundColor: NSColor(red: 0.97, green: 0.41, blue: 0, alpha: 1)
    ]
    let noteStr = NSAttributedString(string: "♪", attributes: noteAttrs)
    let noteSz = noteStr.size()
    noteStr.draw(at: CGPoint(x: cx - noteSz.width / 2, y: s * 0.12))

    NSGraphicsContext.restoreGraphicsState()

    guard let img = ctx.makeImage() else { return nil }
    let nsImg = NSImage(cgImage: img, size: NSSize(width: size, height: size))
    guard let tiff = nsImg.tiffRepresentation,
          let bmp = NSBitmapImageRep(data: tiff),
          let png = bmp.representation(using: .png, properties: [:])
    else { return nil }
    return png
}

// Icon spec: (logical_size, scale)
let specs: [(Int, Int, String)] = [
    (16,  1, "icon_16x16"),
    (16,  2, "icon_16x16@2x"),
    (32,  1, "icon_32x32"),
    (32,  2, "icon_32x32@2x"),
    (128, 1, "icon_128x128"),
    (128, 2, "icon_128x128@2x"),
    (256, 1, "icon_256x256"),
    (256, 2, "icon_256x256@2x"),
    (512, 1, "icon_512x512"),
    (512, 2, "icon_512x512@2x"),
]

let iconsetDir = "AppIcon.iconset"
try! FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

for (logicalSize, scale, name) in specs {
    let pixelSize = logicalSize * scale
    guard let png = makeIconPNG(size: pixelSize) else {
        print("✗ Greška pri pravljenju \(name)")
        continue
    }
    let path = "\(iconsetDir)/\(name).png"
    try! png.write(to: URL(fileURLWithPath: path))
    print("✓ \(path) (\(pixelSize)×\(pixelSize)px)")
}

print("\nSve slike napravljene!")
