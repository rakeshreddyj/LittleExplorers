import Foundation

/// Something to say aloud. `target` may hold alternatives ("shoes|socks") and "*" for "anything" (e.g. "My name is *").
struct SpeakTask: Codable, Hashable {
    var target: String
    var listenFirst: Bool      // play the model first ("repeat after me")
    var needed: Double = 0.6   // share of the important words that must be heard

    /// What we show and what the model voice says.
    var display: String { target.split(separator: "|").first.map(String.init)?.replacingOccurrences(of: "*", with: "___") ?? target }
    var modelSpeech: String { display.replacingOccurrences(of: "___", with: "…") }
}

/// Forgiving comparison of what the child said with what we hoped for. Children's speech is often recognised
/// slightly wrong ("cat" → "kat"), so near-misses count, word order doesn't matter, and a/an/the are optional.
enum SpeakMatch {
    private static let digits = ["0": "zero", "1": "one", "2": "two", "3": "three", "4": "four", "5": "five",
                                 "6": "six", "7": "seven", "8": "eight", "9": "nine", "10": "ten"]
    private static let optional: Set<String> = ["a", "an", "the"]

    static func words(_ s: String) -> [String] {
        let cleaned = String(s.lowercased().map { (c: Character) -> Character in
            c.isLetter || c.isNumber || c == "*" ? c : " "
        })
        return cleaned.split(separator: " ").map { w in digits[String(w)] ?? String(w) }
    }

    static func distance(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }; if b.isEmpty { return a.count }
        var prev = Array(0...b.count)
        for i in 1...a.count {
            var cur = [i] + Array(repeating: 0, count: b.count)
            for j in 1...b.count {
                cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1))
            }
            prev = cur
        }
        return prev[b.count]
    }

    static func similar(_ heard: String, _ want: String) -> Bool {
        if heard == want { return true }
        if want.count < 3 { return false }
        return distance(heard, want) <= (want.count >= 6 ? 2 : 1)
    }

    /// For each word of the (first matching) target: was it heard? Wildcards count when something extra was said.
    static func matches(target: String, heard: String) -> [Bool] {
        let h = words(heard)
        var best: [Bool] = []
        for alt in target.split(separator: "|").map(String.init) {
            let t = words(alt)
            var used = Set<Int>()
            let marks = t.map { w -> Bool in
                if w == "*" { return false }
                if let k = h.indices.first(where: { !used.contains($0) && similar(h[$0], w) }) { used.insert(k); return true }
                return false
            }
            // "*" is satisfied when the child said at least one more word than the fixed part.
            let filled = t.enumerated().map { i, w in w == "*" ? h.count > used.count : marks[i] }
            if filled.filter({ $0 }).count > best.filter({ $0 }).count || best.isEmpty { best = filled }
        }
        return best
    }

    static func passes(_ task: SpeakTask, heard: String) -> Bool {
        let alt = task.target.split(separator: "|").map(String.init)
        for a in alt {
            let t = words(a)
            let marks = matches(target: a, heard: heard)
            let important = t.indices.filter { !optional.contains(t[$0]) }
            guard !important.isEmpty else { continue }
            // A blank ("My name is ___") must be filled in, and those sentences need nearly every word.
            if let blank = t.firstIndex(of: "*"), !marks[blank] { continue }
            let needed = t.contains("*") ? max(task.needed, 0.8) : task.needed
            let got = important.filter { marks[$0] }.count
            if Double(got) / Double(important.count) >= (important.count == 1 ? 1 : needed) { return true }
        }
        return false
    }
}

enum SpeakGen {
    private static func q(_ prompt: String, say: String, visual: Visual, task: SpeakTask, explain: String) -> Question {
        Question(prompt: prompt, say: [.en(say)], visual: visual, options: [], answer: task.target, explain: explain, speak: task)
    }

    /// Picture → say the word. Level 1 hears it first.
    static func words(_ l: Int) -> Question {
        if l == 1 {
            let (w, e) = cvcWords.any
            return q("Say: \(w)", say: "Listen, then say it. \(w).", visual: .bigEmoji(e),
                     task: SpeakTask(target: w, listenFirst: true), explain: "This is a \(w).")
        }
        let (w, e) = picWords.any
        return q("What is this? Say it!", say: "What is this? Say it out loud!", visual: .bigEmoji(e),
                 task: SpeakTask(target: w, listenFirst: false), explain: "It is a \(w).")
    }

    static let sentences: [[(String, String)]] = [
        [("I see a cat.", "🐱"), ("I like mangoes.", "🥭"), ("This is my bag.", "🎒"), ("I can jump.", "🤸"),
         ("The sun is hot.", "☀️"), ("My name is *.", "🙋"), ("Good morning, teacher.", "🧑‍🏫"),
         ("Thank you very much.", "🙏"), ("I am happy.", "😀"), ("I can run fast.", "🏃")],
        [("I have a red ball.", "⚽"), ("The dog is under the table.", "🐶"), ("Can I have some water, please?", "💧"),
         ("I am * years old.", "🎂"), ("I like to play with my friends.", "🧒"), ("My favourite colour is *.", "🎨"),
         ("The bird is in the sky.", "🐦"), ("I wash my hands before I eat.", "🧼")],
        [("Please may I go out to play?", "🛝"), ("Yesterday I went to the park with my family.", "🌳"),
         ("My school bag is blue and very big.", "🎒"), ("I brush my teeth every morning and night.", "🪥"),
         ("Can you help me find my shoes?", "👟"), ("The little cat is sleeping on the bed.", "🐈")],
    ]

    /// Repeat after me.
    static func sentences(_ l: Int) -> Question {
        let (s, e) = sentences[l - 1].any
        let task = SpeakTask(target: s, listenFirst: true, needed: l == 1 ? 0.6 : 0.7)
        return q("Say: \(task.display)", say: "Listen, then say it with me. \(task.modelSpeech)", visual: .bigEmoji(e),
                 task: task, explain: "Well tried! " + task.modelSpeech)
    }

    static let answers: [(String, String, String)] = [
        ("What colour is the sky?", "blue", "☁️"), ("What do cows give us?", "milk", "🐄"),
        ("How many legs does a dog have?", "four", "🐶"), ("What do we wear on our feet?", "shoes|socks|chappals", "👣"),
        ("Which animal says meow?", "cat", "🐱"), ("What is the opposite of hot?", "cold", "🔥"),
        ("What do we use to cut paper?", "scissors", "✂️"), ("What colour is a banana?", "yellow", "🍌"),
        ("What do bees make?", "honey", "🐝"), ("How many fingers are on one hand?", "five", "✋"),
        ("What do we drink when we are thirsty?", "water|milk|juice", "🥤"), ("Which animal has a very long neck?", "giraffe", "🦒"),
    ]

    /// Answer a question out loud.
    static func answers(_ l: Int) -> Question {
        let (question, ans, e) = answers.any
        return q(question, say: question + " Say your answer!", visual: .bigEmoji(e),
                 task: SpeakTask(target: ans, listenFirst: false),
                 explain: "The answer is \(ans.split(separator: "|").first ?? "").")
    }
}
