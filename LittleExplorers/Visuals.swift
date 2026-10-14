import SwiftUI

/// Eye comfort: "auto" switches to the warm, dim evening palette from 6 pm to 7 am.
enum EyeMode: String, CaseIterable { case auto, day, evening }

/// Which palette is showing. Views re-render when it flips (only between rounds, never mid-question).
@MainActor
final class Palette: ObservableObject {
    static let shared = Palette()
    @Published private(set) var evening = false

    func refresh(_ now: Date = Date()) {
        let mode = EyeMode(rawValue: UserDefaults.standard.string(forKey: "eye_mode") ?? "") ?? .auto
        let hour = Calendar.current.component(.hour, from: now)
        let e = mode == .evening || (mode == .auto && (hour >= 18 || hour < 7))
        if e != evening { evening = e }
    }
}

/// Low-glare colours: warm paper instead of bright white, soft ink instead of black, muted (not neon) accents.
/// The evening palette is darker and warmer, with very little blue light.
@MainActor
enum Theme {
    static var evening: Bool { Palette.shared.evening }
    private static func pick(_ day: String, _ eve: String) -> Color { Color(hex: evening ? eve : day) }

    static var bg: Color { pick("#F3ECE0", "#26201C") }
    static var card: Color { pick("#FBF7F0", "#362E28") }
    static var ink: Color { pick("#4A4357", "#EFE1CB") }
    static var muted: Color { pick("#8E869C", "#B3A48D") }
    static var good: Color { pick("#4E9F76", "#8DBA86") }
    static var soft: Color { pick("#D27A6F", "#D99582") }
    static var onColor: Color { pick("#FFFDF8", "#FBEEDB") }     // text on coloured tiles and buttons
    static var accent: Color { pick("#E39268", "#A9704F") }
    static var deep: Color { pick("#5A5170", "#4A4038") }        // dark button
    static var highlight: Color { pick("#F7E3B5", "#4A3D2A") }   // "?" boxes, gentle notices
    static var line: Color { pick("#E5DACB", "#4A4038") }
    static var guide: Color { pick("#DCCFBD", "#5C5046") }       // faint letter to trace over
    static var inkPen: Color { pick("#5A5170", "#F2C98A") }      // tracing ink
    static var writing: Color { pick("#C98A6E", "#8E6450") }     // Writing tile
    static var stories: Color { pick("#B98BB0", "#7E5E78") }     // Stories tile
    static var speaking: Color { pick("#6FA7B8", "#4D7480") }    // Speaking tile
    static var plate: Color { pick("#F3ECE0", "#7A6A5B") }       // soft disc behind pictures so dark emoji stay visible at night
    static var hero: [Color] { evening ? [Color(hex: "#7A5640"), Color(hex: "#6E4A4A")] : [Color(hex: "#EDB27C"), Color(hex: "#E39A8E")] }
    static var shapeDim: Double { evening ? 0.85 : 1 }           // content colours are toned down a little at night

    static func font(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font { .system(size: size, weight: weight, design: .rounded) }
}

struct Triangle: Shape {
    func path(in r: CGRect) -> Path {
        Path { p in p.move(to: CGPoint(x: r.midX, y: r.minY)); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.maxY)); p.closeSubpath() }
    }
}

struct StarShape: Shape {
    func path(in r: CGRect) -> Path {
        let c = CGPoint(x: r.midX, y: r.midY), outer = min(r.width, r.height) / 2, inner = outer * 0.42
        return Path { p in
            for i in 0..<10 {
                let a = Double(i) * .pi / 5 - .pi / 2, rad = i.isMultiple(of: 2) ? outer : inner
                let pt = CGPoint(x: c.x + rad * cos(a), y: c.y + rad * sin(a))
                i == 0 ? p.move(to: pt) : p.addLine(to: pt)
            }
            p.closeSubpath()
        }
    }
}

struct ShapeView: View {
    let kind: ShapeKind
    let color: Color
    var size: CGFloat = 90
    var body: some View {
        Group {
            switch kind {
            case .circle: Circle().fill(color).frame(width: size, height: size)
            case .square: Rectangle().fill(color).frame(width: size * 0.85, height: size * 0.85)
            case .triangle: Triangle().fill(color).frame(width: size, height: size * 0.88)
            case .rectangle: Rectangle().fill(color).frame(width: size * 1.2, height: size * 0.6)
            case .oval: Ellipse().fill(color).frame(width: size * 1.15, height: size * 0.7)
            case .star: StarShape().fill(color).frame(width: size, height: size)
            }
        }
        .frame(width: size * 1.2, height: size)
    }
}

struct ClockView: View {
    let hour: Int, minute: Int
    var size: CGFloat = 220
    var body: some View {
        ZStack {
            Circle().fill(Theme.card).overlay(Circle().stroke(Theme.ink, lineWidth: 7))
            ForEach(1...12, id: \.self) { i in
                let a = Double(i) * .pi / 6
                Text("\(i)").font(Theme.font(size * 0.11)).foregroundStyle(Theme.ink)
                    .offset(x: sin(a) * size * 0.38, y: -cos(a) * size * 0.38)
            }
            hand(length: size * 0.24, width: 10, color: Theme.soft,
                 degrees: (Double(hour % 12) + Double(minute) / 60) * 30)
            hand(length: size * 0.36, width: 6, color: Subject.english.color, degrees: Double(minute) * 6)
            Circle().fill(Theme.ink).frame(width: 14, height: 14)
        }
        .frame(width: size, height: size)
    }
    private func hand(length: CGFloat, width: CGFloat, color: Color, degrees: Double) -> some View {
        Capsule().fill(color).frame(width: width, height: length)
            .offset(y: -length / 2).rotationEffect(.degrees(degrees))
    }
}

struct MoneyView: View {
    let money: Money
    var scale: CGFloat = 1
    var body: some View {
        if money.note {
            let tint = [10: "#C98B5B", 20: "#C9C25B", 50: "#5BBFC9"][money.value] ?? "#9BC95B"
            Text("₹\(money.value)").font(Theme.font(30 * scale)).foregroundStyle(.white)
                .frame(width: 130 * scale, height: 64 * scale)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: tint)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.15), lineWidth: 2))
        } else {
            let d: CGFloat = [1: 62, 2: 68, 5: 72, 10: 78][money.value] ?? 70
            let gold = money.value == 5 || money.value == 10
            Text("₹\(money.value)").font(Theme.font(22 * scale)).foregroundStyle(Theme.ink)
                .frame(width: d * scale, height: d * scale)
                .background(Circle().fill(LinearGradient(colors: gold ? [Color(hex: "#F7D774"), Color(hex: "#D9A938")]
                                                                 : [Color(hex: "#EDEDED"), Color(hex: "#B9B9B9")],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing)))
                .overlay(Circle().stroke(.black.opacity(0.15), lineWidth: 2))
        }
    }
}

struct PlaceValueView: View {
    let tens: Int, ones: Int
    var body: some View {
        HStack(alignment: .bottom, spacing: 28) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<tens, id: \.self) { _ in
                    VStack(spacing: 2) { ForEach(0..<10, id: \.self) { _ in cube(Subject.english.color) } }
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(20), spacing: 4), count: 3), spacing: 4) {
                ForEach(0..<ones, id: \.self) { _ in cube(Subject.math.color) }
            }
            .frame(width: 70)
        }
    }
    private func cube(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 18, height: 18)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(.white.opacity(0.6), lineWidth: 1))
    }
}

struct EmojiGrid: View {
    let emoji: String
    let count: Int
    var crossed = 0
    var maxSize: CGFloat = 64
    var body: some View {
        let size: CGFloat = count > 10 ? maxSize * 0.62 : count > 5 ? maxSize * 0.8 : maxSize
        let cols = min(count, 5)
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(size + 8), spacing: 6), count: max(cols, 1)), spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                let gone = i >= count - crossed
                Text(emoji).font(.system(size: size)).opacity(gone ? 0.3 : 1)
                    .overlay { if gone { Rectangle().fill(Theme.soft).frame(height: 5).rotationEffect(.degrees(-30)) } }
            }
        }
        .fixedSize()
    }
}

struct VisualView: View {
    let visual: Visual
    var body: some View {
        switch visual {
        case .none: EmptyView()
        case .emojis(let e, let n, let crossed): EmojiGrid(emoji: e, count: n, crossed: crossed)
        case .addition(let e, let a, let b):
            HStack(spacing: 18) {
                EmojiGrid(emoji: e, count: a, maxSize: 52)
                Text("+").font(Theme.font(60)).foregroundStyle(Theme.ink)
                EmojiGrid(emoji: e, count: b, maxSize: 52)
            }
        case .bigEmoji(let e): Text(e).font(.system(size: 130)).padding(26).background(Circle().fill(Theme.plate))
        case .bigText(let t): Text(t).font(Theme.font(110)).foregroundStyle(Theme.ink).minimumScaleFactor(0.4).lineLimit(1)
        case .sequence(let items):
            HStack(spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, s in
                    Text(s == "?" ? " " : s).font(Theme.font(48))
                        .foregroundStyle(Theme.ink).minimumScaleFactor(0.5)
                        .frame(width: 84, height: 84)
                        .background(RoundedRectangle(cornerRadius: 18).fill(s == "?" ? Theme.highlight : Theme.bg))
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .stroke(s == "?" ? Theme.accent : .clear, style: StrokeStyle(lineWidth: 4, dash: [8, 6])))
                }
            }
        case .shape(let k, let c): ShapeView(kind: k, color: Color(hex: c).opacity(Theme.shapeDim), size: 170)
        case .clock(let h, let m): ClockView(hour: h, minute: m)
        case .coins(let items):
            HStack(spacing: 14) { ForEach(Array(items.enumerated()), id: \.offset) { _, m in MoneyView(money: m, scale: 1.2) } }
        case .placeValue(let t, let o): PlaceValueView(tens: t, ones: o)
        case .script(let s, let roman):
            VStack(spacing: 4) {
                Text(s).font(.system(size: 120, weight: .bold)).foregroundStyle(Theme.ink).minimumScaleFactor(0.4).lineLimit(1)
                if let roman { Text(roman).font(Theme.font(30, .semibold)).foregroundStyle(Theme.muted) }
            }
        }
    }
}

struct OptionFaceView: View {
    let face: OptionFace
    var body: some View {
        switch face {
        case .text(let s): Text(s).font(Theme.font(s.count > 14 ? 28 : 44)).multilineTextAlignment(.center)
                .minimumScaleFactor(0.5).padding(.horizontal, 10)
        case .emoji(let e): Text(e).font(.system(size: 84)).padding(10)
                .background(Circle().fill(Theme.evening ? Theme.plate : .clear))
        case .emojiText(let e, let s):
            VStack(spacing: 2) { Text(e).font(.system(size: 54)); Text(s).font(Theme.font(32)) }
        case .shape(let k, let c): ShapeView(kind: k, color: Color(hex: c).opacity(Theme.shapeDim), size: 96)
        case .color(let c): Circle().fill(Color(hex: c)).frame(width: 100, height: 100)
                .overlay(Circle().stroke(.black.opacity(0.12), lineWidth: 3))
        case .sized(let e, let s): Text(e).font(.system(size: s))
        case .money(let m): MoneyView(money: m, scale: 1.25)
        case .script(let s, let roman):
            VStack(spacing: 2) {
                Text(s).font(.system(size: s.count > 3 ? 46 : 70, weight: .bold)).minimumScaleFactor(0.5).lineLimit(1)
                if let roman { Text(roman).font(Theme.font(22, .semibold)).foregroundStyle(Theme.muted) }
            }
        }
    }
}

/// Small left-right wiggle for a wrong tap.
struct Shake: GeometryEffect {
    var travel: CGFloat = 10
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: travel * sin(animatableData * .pi * 4), y: 0))
    }
}

struct BigButtonStyle: ButtonStyle {
    var color: Color? = nil
    func makeBody(configuration: Configuration) -> some View {
        let c = color ?? Theme.accent
        return configuration.label.font(Theme.font(30)).foregroundStyle(Theme.onColor)
            .padding(.horizontal, 40).padding(.vertical, 20)
            .background(Capsule().fill(c))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
