import PencilKit
import SwiftUI
import UIKit

/// Draws the guide letter. The same image is used on screen and for checking, so they always line up.
@MainActor
enum TraceGlyph {
    nonisolated static let boardSize = CGSize(width: 600, height: 400)

    static func font(for text: String, in size: CGSize) -> UIFont {
        // Telugu / Devanagari strokes are much heavier in bold; a regular weight is closer to a child's pencil line.
        let indic = text.unicodeScalars.contains { $0.value >= 0x0900 && $0.value <= 0x0D7F }
        func make(_ pt: CGFloat) -> UIFont {
            let base = UIFont.systemFont(ofSize: pt, weight: indic ? .regular : .bold)
            return base.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: pt) } ?? base
        }
        var pt = size.height * 0.72
        let width = (text as NSString).size(withAttributes: [.font: make(pt)]).width
        if width > size.width * 0.88 { pt *= size.width * 0.88 / width }
        return make(pt)
    }

    static func image(_ text: String, color: UIColor, size: CGSize = boardSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let s = NSAttributedString(string: text, attributes: [.font: font(for: text, in: size), .foregroundColor: color])
            let b = s.size()
            s.draw(at: CGPoint(x: (size.width - b.width) / 2, y: (size.height - b.height) / 2))
        }
    }

    /// Alpha channel of an image, shrunk to a w×h grid.
    static func grid(_ image: UIImage, w: Int, h: Int, threshold: UInt8) -> [Bool] {
        guard let cg = image.cgImage else { return [Bool](repeating: false, count: w * h) }
        var buf = [UInt8](repeating: 0, count: w * h)
        buf.withUnsafeMutableBytes { raw in
            let ctx = CGContext(data: raw.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
                                space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue)
            ctx?.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        }
        return buf.map { $0 > threshold }
    }

    static func check(_ drawing: PKDrawing, text: String) -> TraceScoring.Result {
        let size = boardSize
        let w = 160, h = Int(160 * size.height / size.width)
        let glyph = grid(image(text, color: .black), w: w, h: h, threshold: 100)
        let inkImage = drawing.image(from: CGRect(origin: .zero, size: size), scale: 1)
        let ink = grid(inkImage, w: w, h: h, threshold: 40)
        return TraceScoring.score(glyph: glyph, ink: ink, w: w, h: h)
    }
}

/// PencilKit canvas for tracing with Apple Pencil (or a finger when the iPad allows finger drawing).
struct TraceCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let clearToken: Int
    let ink: UIColor
    let enabled: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PKCanvasView {
        let c = PKCanvasView()
        c.backgroundColor = .clear
        c.isOpaque = false
        c.isScrollEnabled = false
        // Without a tool picker on screen, PencilKit's .default policy means Pencil-only, so follow the iPad's
        // "Only Draw with Apple Pencil" setting ourselves: Pencil-only (palm ignored) when on, Pencil or finger when off.
        c.drawingPolicy = UIPencilInteraction.prefersPencilOnlyDrawing ? .pencilOnly : .anyInput
        c.overrideUserInterfaceStyle = .light   // stop PencilKit inverting our ink colour in the evening palette
        c.tool = PKInkingTool(.monoline, color: ink, width: 22)
        c.delegate = context.coordinator
        return c
    }

    func updateUIView(_ c: PKCanvasView, context: Context) {
        context.coordinator.parent = self
        if context.coordinator.lastClear != clearToken {
            context.coordinator.lastClear = clearToken
            c.drawing = PKDrawing()
        }
        c.tool = PKInkingTool(.monoline, color: ink, width: 22)
        c.isUserInteractionEnabled = enabled
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: TraceCanvas
        var lastClear: Int
        init(_ p: TraceCanvas) { parent = p; lastClear = p.clearToken }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) { parent.drawing = canvasView.drawing }
    }
}

/// The tracing board: writing lines, the faint guide letter, and the canvas on top.
struct TraceBoard: View {
    let task: TraceTask
    @Binding var drawing: PKDrawing
    let clearToken: Int
    let enabled: Bool
    let passed: Bool

    var body: some View {
        let size = TraceGlyph.boardSize
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(Theme.bg)
            // Four-line writing guides, like a school notebook.
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    Spacer()
                    Rectangle().fill(Theme.line).frame(height: 2)
                }
                Spacer()
            }
            .padding(.vertical, 40)
            Image(uiImage: TraceGlyph.image(task.text, color: UIColor(Theme.guide)))
            TraceCanvas(drawing: $drawing, clearToken: clearToken, ink: UIColor(Theme.inkPen), enabled: enabled)
        }
        .frame(width: size.width, height: size.height)
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(passed ? Theme.good : Theme.line, lineWidth: passed ? 6 : 3))
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}
