import Foundation

/// Countable things: emoji, singular, plural.
struct Thing: Hashable {
    let e: String, one: String, many: String
    func word(_ n: Int) -> String { n == 1 ? one : many }
}

let things: [Thing] = [
    .init(e: "🍎", one: "apple", many: "apples"), .init(e: "⭐", one: "star", many: "stars"),
    .init(e: "🐟", one: "fish", many: "fish"), .init(e: "🎈", one: "balloon", many: "balloons"),
    .init(e: "🚗", one: "car", many: "cars"), .init(e: "🌸", one: "flower", many: "flowers"),
    .init(e: "🐤", one: "chick", many: "chicks"), .init(e: "🍌", one: "banana", many: "bananas"),
    .init(e: "⚽", one: "ball", many: "balls"), .init(e: "🦋", one: "butterfly", many: "butterflies"),
    .init(e: "🐞", one: "ladybird", many: "ladybirds"), .init(e: "🍪", one: "biscuit", many: "biscuits"),
]

let shapeColors = ["#FF7A59", "#4F8EF7", "#2DBE7E", "#A66CFF", "#F5B700", "#F0609E"]
let kidNames = ["Ria", "Arjun", "Meera", "Kabir", "Anaya", "Dev", "Ishaan", "Saanvi", "Aarav", "Diya"]
let numberWords = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
                   "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty"]

enum MathGen {
    static func count(_ l: Int) -> Question {
        let t = things.any
        let n = l == 1 ? rnd(3, 10) : l == 2 ? rnd(6, 20) : rnd(12, 30)
        return Question(prompt: "How many \(t.e)?", say: [.en("How many \(t.many) can you count?")],
                        visual: .emojis(t.e, count: n, crossed: 0), options: numOptions(n, lo: 1), answer: "\(n)",
                        explain: "There are \(n) \(t.word(n)).")
    }

    static func add(_ l: Int) -> Question {
        let t = things.any
        let (a, b): (Int, Int) = {
            switch l {
            case 1: let a = rnd(1, 5); return (a, rnd(1, 7 - a))
            case 2: let a = rnd(2, 8); return (a, rnd(1, 10 - a))
            default: let a = rnd(5, 15); return (a, rnd(2, 20 - a))
            }
        }()
        let s = a + b
        let pictured = l == 1 || (l == 2 && Bool.random())
        return Question(prompt: "\(a) + \(b) = ?",
                        say: [.en(pictured ? "\(a) \(t.word(a)) and \(b) more. How many altogether?" : "What is \(a) plus \(b)?")],
                        visual: pictured ? .addition(t.e, a: a, b: b) : .none, options: numOptions(s), answer: "\(s)",
                        explain: "\(a) plus \(b) makes \(s).")
    }

    static func sub(_ l: Int) -> Question {
        let t = things.any
        let (a, b): (Int, Int) = {
            switch l {
            case 1: let a = rnd(3, 7); return (a, rnd(1, a - 1))
            case 2: let a = rnd(5, 10); return (a, rnd(1, a - 1))
            default: return (rnd(11, 20), rnd(2, 9))
            }
        }()
        let r = a - b
        let pictured = l == 1 || (l == 2 && Bool.random())
        return Question(prompt: "\(a) − \(b) = ?",
                        say: [.en(pictured ? "There are \(a) \(t.word(a)). \(b) are taken away. How many are left?" : "What is \(a) minus \(b)?")],
                        visual: pictured ? .emojis(t.e, count: a, crossed: b) : .none, options: numOptions(r), answer: "\(r)",
                        explain: "\(a) take away \(b) leaves \(r).")
    }

    static func compare(_ l: Int) -> Question {
        let hi = [20, 50, 100][l - 1]
        let a = rnd(1, hi)
        var b = rnd(1, hi); while b == a { b = rnd(1, hi) }
        let bigger = l < 2 || Bool.random()
        let ans = bigger ? max(a, b) : min(a, b)
        let word = bigger ? "bigger" : "smaller"
        return Question(prompt: "Which number is \(word)?", say: [.en("Which number is \(word)?")],
                        options: [a, b].map(Option.num), answer: "\(ans)", explain: "\(ans) is \(word).")
    }

    static func order(_ l: Int) -> Question {
        let hi = [20, 50, 100][l - 1]
        let kind = l == 1 ? ["after", "before"].any : ["after", "before", "between"].any
        switch kind {
        case "after":
            let n = rnd(1, hi - 1)
            return Question(prompt: "What comes after?", say: [.en("What number comes after \(n)?")],
                            visual: .sequence(["\(n)", "?"]), options: numOptions(n + 1), answer: "\(n + 1)",
                            explain: "\(n + 1) comes after \(n).")
        case "before":
            let n = rnd(2, hi)
            return Question(prompt: "What comes before?", say: [.en("What number comes just before \(n)?")],
                            visual: .sequence(["?", "\(n)"]), options: numOptions(n - 1), answer: "\(n - 1)",
                            explain: "\(n - 1) comes before \(n).")
        default:
            let n = rnd(1, hi - 2)
            return Question(prompt: "What comes in between?", say: [.en("What number comes between \(n) and \(n + 2)?")],
                            visual: .sequence(["\(n)", "?", "\(n + 2)"]), options: numOptions(n + 1), answer: "\(n + 1)",
                            explain: "\(n + 1) is between \(n) and \(n + 2).")
        }
    }

    static func shapes(_ l: Int) -> Question {
        if l == 3 && Bool.random() {
            let sides: [ShapeKind: Int] = [.triangle: 3, .square: 4, .rectangle: 4]
            let s = sides.keys.sorted { $0.rawValue < $1.rawValue }.any
            let n = sides[s]!
            return Question(prompt: "How many sides?", say: [.en("How many sides does a \(s.rawValue) have?")],
                            visual: .shape(s, shapeColors.any), options: numOptions(n, lo: 1, hi: 6), answer: "\(n)",
                            explain: "A \(s.rawValue) has \(n) sides.")
        }
        let pool: [ShapeKind] = l == 1 ? [.circle, .square, .triangle, .rectangle] : ShapeKind.allCases
        let target = pool.any
        let opts = choices(target, from: pool, n: l == 1 ? 3 : 4)
        let colors = shapeColors.shuffled()
        return Question(prompt: "Find the \(target.rawValue)", say: [.en("Tap the \(target.rawValue).")],
                        options: opts.enumerated().map { i, s in Option(id: s.rawValue, face: .shape(s, colors[i % colors.count]), spoken: nil) },
                        answer: target.rawValue, explain: "This is a \(target.rawValue).")
    }

    static func skip(_ l: Int) -> Question {
        let step = l <= 2 ? [10, 2].any : [2, 5, 10].any
        let start = step * rnd(0, 4)
        let seq = (0..<4).map { start + step * $0 }
        let ans = start + step * 4
        let opts = [ans, ans + step, ans + 1].uniqued().shuffled().map(Option.num)
        return Question(prompt: "Count by \(step)s", say: [.en("Count by \(step)s. What comes next?")],
                        visual: .sequence(seq.map(String.init) + ["?"]), options: opts, answer: "\(ans)",
                        explain: (seq + [ans]).map(String.init).joined(separator: ", ") + ".")
    }

    static func numberNames(_ l: Int) -> Question {
        let n = rnd(1, l <= 2 ? 10 : 20)
        if Bool.random() {
            return Question(prompt: "Which number is this word?", say: [.en("Read the word. Which number is it?")],
                            visual: .bigText(numberWords[n]), options: numOptions(n, lo: 1, hi: 20), answer: "\(n)",
                            explain: "\(numberWords[n].capitalized) is \(n).")
        }
        let opts = choices(n, from: Array(max(1, n - 3)...min(20, n + 3)), n: 3)
        return Question(prompt: "Which word says this number?", say: [.en("Which word says this number?")],
                        visual: .bigText("\(n)"),
                        options: opts.map { Option(id: "\($0)", face: .text(numberWords[$0]), spoken: nil) },
                        answer: "\(n)", explain: "\(n) is written \(numberWords[n]).")
    }

    static func placeValue(_ l: Int) -> Question {
        let n = l <= 2 ? rnd(11, 49) : rnd(21, 99)
        let t = n / 10, o = n % 10
        let opts = [n, o * 10 + t, n + 10 <= 99 ? n + 10 : n - 10, n + 1].uniqued().prefix(3)
        let pictured = l <= 2
        return Question(prompt: pictured ? "What number is this?" : "\(t) tens and \(o) ones",
                        say: [.en(pictured ? "Each long stick is ten. Each small cube is one. What number is this?"
                                           : "\(t) tens and \(o) ones. What number is it?")],
                        visual: pictured ? .placeValue(tens: t, ones: o) : .none,
                        options: opts.shuffled().map(Option.num), answer: "\(n)",
                        explain: "\(t) tens and \(o) ones make \(n).")
    }

    static func story(_ l: Int) -> Question {
        let name = kidNames.any
        let t = things.filter { $0.one != $0.many }.any
        let hi = l <= 2 ? 10 : 20
        if Bool.random() {
            let a = rnd(1, hi - 2), b = rnd(1, hi - a)
            let text = "\(name) has \(a) \(t.word(a)). \(name) gets \(b) more. How many \(t.many) now?"
            return Question(prompt: text, say: [.en(text)], visual: .bigEmoji(t.e), options: numOptions(a + b),
                            answer: "\(a + b)", explain: "\(a) plus \(b) is \(a + b).")
        }
        let a = rnd(3, hi), b = rnd(1, a - 1)
        let text = "\(name) has \(a) \(t.word(a)). \(name) gives \(b) to a friend. How many are left?"
        return Question(prompt: text, say: [.en(text)], visual: .bigEmoji(t.e), options: numOptions(a - b),
                        answer: "\(a - b)", explain: "\(a) take away \(b) is \(a - b).")
    }
}
