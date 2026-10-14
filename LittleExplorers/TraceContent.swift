import Foundation

/// Something to trace: a letter, number or short word, in English, Telugu or Hindi.
struct TraceTask: Codable, Hashable {
    var text: String
    var lang: String          // "en", "te", "hi"
    var hint: String? = nil   // e.g. "⚽ ball", or the romanisation for Telugu / Hindi
}

enum TraceGen {
    private static func letterHint(_ c: Character) -> String? {
        picWords.first { $0.0.hasPrefix(String(c).lowercased()) }.map { "\($0.1) \($0.0)" }
    }

    private static func task(_ prompt: String, say: [Utter], text: String, lang: String = "en", hint: String?,
                             explain: String) -> Question {
        Question(prompt: prompt, say: say, options: [], answer: text, explain: explain, trace: TraceTask(text: text, lang: lang, hint: hint))
    }

    /// Straight-line capitals first (easier for small hands), then all of them.
    static func capitals(_ l: Int) -> Question {
        let c = Array(l == 1 ? "LTIEFHAKMNVWXYZ" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ").any
        let hint = letterHint(c)
        return task("Trace the capital letter \(c)",
                    say: [.en("Trace the capital letter \(c)." + (hint.map { " \(c) is for \(plain($0))." } ?? ""))],
                    text: String(c), hint: hint, explain: "That's capital \(c)!")
    }

    static func small(_ l: Int) -> Question {
        let c = Array(l == 1 ? "ilotcvwxs" : "abcdefghijklmnopqrstuvwxyz").any
        let hint = letterHint(c)
        return task("Trace the small letter \(c)",
                    say: [.en("Trace the small letter \(c)." + (hint.map { " \(c) is for \(plain($0))." } ?? ""))],
                    text: String(c), hint: hint, explain: "That's small \(c)!")
    }

    static func numbers(_ l: Int) -> Question {
        let n = l == 1 ? rnd(0, 9) : l == 2 ? rnd(10, 20) : rnd(21, 50)
        return task("Trace the number \(n)", say: [.en("Trace the number \(n).")], text: "\(n)",
                    hint: n <= 10 ? String(repeating: "⭐", count: n) : nil, explain: "That's \(n)!")
    }

    static func words(_ l: Int) -> Question {
        let (w, e) = cvcWords.any
        return task("Trace the word \(w)", say: [.en("Trace the word \(w).")], text: w, hint: "\(e) \(w)",
                    explain: "You wrote \(w)!")
    }

    static func language(_ p: LangPack, _ l: Int) -> Question {
        let letter = (l == 1 ? p.vowels : l == 2 ? p.consonants : p.vowels + p.consonants).any
        return task("Trace this \(p.name) letter",
                    say: [.en("Trace this \(p.name) letter."), .init(text: letter.ch, lang: p.code)],
                    text: letter.ch, lang: p.code, hint: letter.roman, explain: "\(letter.ch) says \(letter.roman).")
    }
}
