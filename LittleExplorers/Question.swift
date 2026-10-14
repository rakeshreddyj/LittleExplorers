import Foundation

/// One spoken phrase. `lang` is "en", "te" or "hi" so mixed questions use the right voice for each part.
struct Utter: Codable, Hashable {
    var text: String
    var lang: String
    static func en(_ t: String) -> Utter { .init(text: t, lang: "en") }
    static func te(_ t: String) -> Utter { .init(text: t, lang: "te") }
    static func hi(_ t: String) -> Utter { .init(text: t, lang: "hi") }
}

enum ShapeKind: String, Codable, CaseIterable { case circle, square, triangle, rectangle, oval, star }

struct Money: Codable, Hashable {
    var value: Int
    var note: Bool
    var spoken: String { "\(value) rupee \(note ? "note" : "coin")" }
}

/// The picture shown above the answers.
enum Visual: Codable, Hashable {
    case none
    case emojis(String, count: Int, crossed: Int)   // the last `crossed` items are faded and struck out
    case addition(String, a: Int, b: Int)
    case bigEmoji(String)
    case bigText(String)
    case sequence([String])                          // "?" renders as an empty box
    case shape(ShapeKind, String)
    case clock(hour: Int, minute: Int)
    case coins([Money])
    case placeValue(tens: Int, ones: Int)
    case script(String, roman: String?)              // large Telugu / Hindi text
}

/// What an answer button looks like.
enum OptionFace: Codable, Hashable {
    case text(String)
    case emoji(String)
    case emojiText(String, String)
    case shape(ShapeKind, String)
    case color(String)
    case sized(String, Double)
    case money(Money)
    case script(String, roman: String?)
}

struct Option: Codable, Hashable, Identifiable {
    var id: String
    var face: OptionFace
    var spoken: Utter?

    static func num(_ n: Int) -> Option { .init(id: "\(n)", face: .text("\(n)"), spoken: .en("\(n)")) }
    static func text(_ s: String) -> Option { .init(id: s, face: .text(s), spoken: .en(s)) }
    static func emojiText(_ e: String, _ s: String) -> Option { .init(id: s, face: .emojiText(e, s), spoken: .en(s)) }
}

struct Question: Codable, Identifiable {
    var id = UUID()
    var skill = ""
    var prompt: String
    var say: [Utter]
    var visual: Visual = .none
    var options: [Option]
    var answer: String
    var explain: String = ""
    /// Read the choices aloud too — for children who can't read the buttons yet.
    var readOptions = false

    var key: String { skill + prompt + say.map(\.text).joined() + "\(visual)" + options.map(\.id).sorted().joined() }
    var correctOption: Option? { options.first { $0.id == answer } }
}

// MARK: - Random helpers

func rnd(_ a: Int, _ b: Int) -> Int { a >= b ? a : Int.random(in: a...b) }

extension Array {
    func sample(_ n: Int) -> [Element] { Array(shuffled().prefix(n)) }
    var any: Element { randomElement()! }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] { var seen = Set<Element>(); return filter { seen.insert($0).inserted } }
}

/// The answer plus `n - 1` different distractors from `pool`, shuffled.
func choices<T: Hashable>(_ ans: T, from pool: [T], n: Int = 3) -> [T] {
    ([ans] + pool.filter { $0 != ans }.uniqued().sample(n - 1)).shuffled()
}

/// Number answers with nearby distractors (kept inside lo...hi).
func numOptions(_ ans: Int, n: Int = 3, lo: Int = 0, hi: Int = 10_000, steps: [Int] = [1, -1, 2, -2, 3, -3],
                rupees: Bool = false) -> [Option] {
    var vals = [ans]
    for d in steps.shuffled() + [4, -4, 5, -5, 6, 7, 8, 9, 10, 11] where vals.count < n {
        let v = ans + d
        if v >= lo && v <= hi && !vals.contains(v) { vals.append(v) }
    }
    return vals.shuffled().map { v in
        rupees ? Option(id: "\(v)", face: .text("₹\(v)"), spoken: .en("\(v) rupees")) : .num(v)
    }
}
