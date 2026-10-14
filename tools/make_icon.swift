// Draws the Little Explorers app icon: a friendly owl explorer reading an open book, on a warm sunrise.
// Original vector artwork (no emoji or third-party art). Run: swift tools/make_icon.swift <output.png>
import AppKit

let S: CGFloat = 1024
func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
func oval(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSBezierPath {
    NSBezierPath(ovalIn: NSRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h))
}
func fill(_ p: NSBezierPath, _ c: NSColor) { c.setFill(); p.fill() }

let art = NSImage(size: NSSize(width: S, height: S))
art.lockFocus()

// Sky: soft sunrise gradient (matches the app's warm, low-glare palette).
NSGradient(colors: [rgb(0xF7C59F), rgb(0xEFA27C), rgb(0xE38B83)])!.draw(in: NSRect(x: 0, y: 0, width: S, height: S), angle: -90)
// Sun behind the owl.
fill(oval(512, 610, 760, 760), rgb(0xFBE3B4, 0.55))
fill(oval(512, 610, 560, 560), rgb(0xFDEFD2, 0.6))
// Rolling hill.
let hill = NSBezierPath()
hill.move(to: NSPoint(x: 0, y: 250))
hill.curve(to: NSPoint(x: S, y: 290), controlPoint1: NSPoint(x: 330, y: 360), controlPoint2: NSPoint(x: 700, y: 210))
hill.line(to: NSPoint(x: S, y: 0)); hill.line(to: NSPoint(x: 0, y: 0)); hill.close()
fill(hill, rgb(0x7DB38F))

// Owl body.
let body = NSBezierPath()
body.move(to: NSPoint(x: 512, y: 760))
body.curve(to: NSPoint(x: 760, y: 330), controlPoint1: NSPoint(x: 720, y: 760), controlPoint2: NSPoint(x: 800, y: 520))
body.curve(to: NSPoint(x: 512, y: 210), controlPoint1: NSPoint(x: 730, y: 230), controlPoint2: NSPoint(x: 620, y: 210))
body.curve(to: NSPoint(x: 264, y: 330), controlPoint1: NSPoint(x: 404, y: 210), controlPoint2: NSPoint(x: 294, y: 230))
body.curve(to: NSPoint(x: 512, y: 760), controlPoint1: NSPoint(x: 224, y: 520), controlPoint2: NSPoint(x: 304, y: 760))
body.close()
fill(body, rgb(0x8A6A55))
// Ear tufts.
for side: CGFloat in [-1, 1] {
    let tuft = NSBezierPath()
    tuft.move(to: NSPoint(x: 512 + side * 140, y: 720))
    tuft.curve(to: NSPoint(x: 512 + side * 200, y: 790), controlPoint1: NSPoint(x: 512 + side * 165, y: 760), controlPoint2: NSPoint(x: 512 + side * 185, y: 780))
    tuft.curve(to: NSPoint(x: 512 + side * 215, y: 680), controlPoint1: NSPoint(x: 512 + side * 215, y: 760), controlPoint2: NSPoint(x: 512 + side * 222, y: 720))
    tuft.close()
    fill(tuft, rgb(0x7A5B48))
}
// Belly.
fill(oval(512, 360, 330, 300), rgb(0xE9D6BF))
// Wings.
for side: CGFloat in [-1, 1] {
    let w = NSBezierPath()
    w.move(to: NSPoint(x: 512 + side * 205, y: 560))
    w.curve(to: NSPoint(x: 512 + side * 175, y: 300), controlPoint1: NSPoint(x: 512 + side * 290, y: 480), controlPoint2: NSPoint(x: 512 + side * 270, y: 330))
    w.curve(to: NSPoint(x: 512 + side * 205, y: 560), controlPoint1: NSPoint(x: 512 + side * 150, y: 400), controlPoint2: NSPoint(x: 512 + side * 160, y: 500))
    fill(w, rgb(0x6F513F))
}
// Face disc and big friendly eyes.
fill(oval(512, 585, 420, 270), rgb(0xF3E6D6))
for side: CGFloat in [-1, 1] {
    let cx = 512 + side * 98
    fill(oval(cx, 590, 170, 170), .white)
    fill(oval(cx + side * 4, 584, 96, 96), rgb(0x3E3550))
    fill(oval(cx + side * 4 + 20, 606, 30, 30), .white)       // sparkle
}
// Beak.
let beak = NSBezierPath()
beak.move(to: NSPoint(x: 482, y: 520)); beak.line(to: NSPoint(x: 542, y: 520)); beak.line(to: NSPoint(x: 512, y: 470)); beak.close()
fill(beak, rgb(0xF2A541))
// Explorer hat (little safari hat with a band).
fill(oval(512, 760, 330, 70), rgb(0xD9B36C))
let crown = NSBezierPath()
crown.move(to: NSPoint(x: 402, y: 770))
crown.curve(to: NSPoint(x: 622, y: 770), controlPoint1: NSPoint(x: 420, y: 905), controlPoint2: NSPoint(x: 604, y: 905))
crown.close()
fill(crown, rgb(0xE6C27E))
let band = NSBezierPath(rect: NSRect(x: 405, y: 770, width: 214, height: 30))
NSGraphicsContext.saveGraphicsState(); crown.addClip(); fill(band, rgb(0x5B8F7B)); NSGraphicsContext.restoreGraphicsState()

// Little feet peeking out under the book.
for side: CGFloat in [-1, 1] { fill(oval(512 + side * 80, 150, 64, 30), rgb(0xF2A541)) }

// Open book held at the bottom.
for side: CGFloat in [-1, 1] {
    let page = NSBezierPath()
    page.move(to: NSPoint(x: 512, y: 300))
    page.curve(to: NSPoint(x: 512 + side * 230, y: 320), controlPoint1: NSPoint(x: 512 + side * 80, y: 340), controlPoint2: NSPoint(x: 512 + side * 160, y: 345))
    page.line(to: NSPoint(x: 512 + side * 230, y: 190))
    page.curve(to: NSPoint(x: 512, y: 170), controlPoint1: NSPoint(x: 512 + side * 160, y: 215), controlPoint2: NSPoint(x: 512 + side * 80, y: 210))
    page.close()
    fill(page, rgb(0xFFFBF3))
    rgb(0xC9B79F).setStroke(); page.lineWidth = 6; page.stroke()
    for k in 0..<3 {   // lines of text
        let y = 280 - CGFloat(k) * 32
        let line = NSBezierPath()
        line.move(to: NSPoint(x: 512 + side * 50, y: y - 4))
        line.line(to: NSPoint(x: 512 + side * 190, y: y + 6))
        line.lineWidth = 10; line.lineCapStyle = .round
        rgb(0xC7D7E8).setStroke(); line.stroke()
    }
}
// Book cover edges.
let cover = NSBezierPath()
cover.move(to: NSPoint(x: 278, y: 188)); cover.curve(to: NSPoint(x: 746, y: 188), controlPoint1: NSPoint(x: 420, y: 150), controlPoint2: NSPoint(x: 604, y: 150))
cover.lineWidth = 16; cover.lineCapStyle = .round; rgb(0x6F98CF).setStroke(); cover.stroke()

art.unlockFocus()

// Flatten to an opaque 1024×1024 PNG (App Store icons must not have transparency). Drawing straight into an
// alpha-less NSBitmapImageRep comes out black on current macOS, so draw with alpha, then copy into an RGB-only context.
let withAlpha = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(S), pixelsHigh: Int(S), bitsPerSample: 8, samplesPerPixel: 4,
                                 hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: withAlpha)
art.draw(in: NSRect(x: 0, y: 0, width: S, height: S), from: .zero, operation: .copy, fraction: 1)
NSGraphicsContext.restoreGraphicsState()
let ctx = CGContext(data: nil, width: Int(S), height: Int(S), bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.draw(withAlpha.cgImage!, in: CGRect(x: 0, y: 0, width: S, height: S))
let opaque = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! opaque.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("wrote", CommandLine.arguments[1], "alpha:", opaque.hasAlpha)
