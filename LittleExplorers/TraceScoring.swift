import Foundation

/// Checks a tracing attempt on two small pixel grids (the guide letter and the child's ink, same size).
/// No stroke order or timing; it asks two kind questions:
///  - coverage: did the ink go over most of the letter?
///  - precision: did most of the ink stay on the letter (not scribbling over the whole box)?
enum TraceScoring {
    struct Result { let coverage: Double; let precision: Double; let inkPixels: Int; let passed: Bool }

    static let minCoverage = 0.65
    static let minPrecision = 0.85

    /// Grows every "on" pixel into a (2r+1)² square, using prefix sums per row then per column.
    static func dilate(_ m: [Bool], w: Int, h: Int, r: Int) -> [Bool] {
        var rows = [Bool](repeating: false, count: w * h)
        var pre = [Int](repeating: 0, count: max(w, h) + 1)
        for y in 0..<h {
            for x in 0..<w { pre[x + 1] = pre[x] + (m[y * w + x] ? 1 : 0) }
            for x in 0..<w { rows[y * w + x] = pre[min(w, x + r + 1)] - pre[max(0, x - r)] > 0 }
        }
        var out = [Bool](repeating: false, count: w * h)
        for x in 0..<w {
            for y in 0..<h { pre[y + 1] = pre[y] + (rows[y * w + x] ? 1 : 0) }
            for y in 0..<h { out[y * w + x] = pre[min(h, y + r + 1)] - pre[max(0, y - r)] > 0 }
        }
        return out
    }

    static func score(glyph: [Bool], ink: [Bool], w: Int, h: Int) -> Result {
        let inkCount = ink.filter { $0 }.count
        let glyphCount = glyph.filter { $0 }.count
        guard inkCount >= 12, glyphCount > 0 else { return Result(coverage: 0, precision: 0, inkPixels: inkCount, passed: false) }
        // A line drawn along the middle of a letter stroke should count for the whole stroke width.
        let r = max(3, w / 32)   // ≈ half a letter stroke at this size
        let inkNear = dilate(ink, w: w, h: h, r: r)
        let glyphNear = dilate(glyph, w: w, h: h, r: r)
        var covered = 0, onLetter = 0
        for k in 0..<(w * h) {
            if glyph[k] && inkNear[k] { covered += 1 }
            if ink[k] && glyphNear[k] { onLetter += 1 }
        }
        let coverage = Double(covered) / Double(glyphCount)
        let precision = Double(onLetter) / Double(inkCount)
        return Result(coverage: coverage, precision: precision, inkPixels: inkCount,
                      passed: coverage >= minCoverage && precision >= minPrecision)
    }
}
