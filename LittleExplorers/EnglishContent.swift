import Foundation

/// Picture words for phonics (word, emoji). The word is spoken, so pictures only need to be recognisable.
let picWords: [(String, String)] = [
    ("apple", "🍎"), ("ant", "🐜"), ("ball", "⚽"), ("bus", "🚌"), ("cat", "🐱"), ("car", "🚗"), ("dog", "🐶"),
    ("duck", "🦆"), ("egg", "🥚"), ("elephant", "🐘"), ("fish", "🐟"), ("frog", "🐸"), ("goat", "🐐"),
    ("grapes", "🍇"), ("hat", "🎩"), ("hen", "🐔"), ("ice cream", "🍦"), ("juice", "🧃"), ("kite", "🪁"),
    ("key", "🔑"), ("lion", "🦁"), ("leaf", "🍃"), ("moon", "🌙"), ("monkey", "🐒"), ("nest", "🪺"),
    ("nose", "👃"), ("orange", "🍊"), ("owl", "🦉"), ("pig", "🐷"), ("pen", "🖊️"), ("rabbit", "🐰"),
    ("rose", "🌹"), ("sun", "☀️"), ("star", "⭐"), ("tiger", "🐯"), ("tree", "🌳"), ("umbrella", "☂️"),
    ("van", "🚐"), ("violin", "🎻"), ("watch", "⌚"), ("web", "🕸️"), ("yo-yo", "🪀"), ("zebra", "🦓"),
]

let cvcWords: [(String, String)] = [
    ("cat", "🐱"), ("dog", "🐶"), ("pig", "🐷"), ("hat", "🎩"), ("bat", "🦇"), ("sun", "☀️"), ("bus", "🚌"),
    ("bed", "🛏️"), ("pen", "🖊️"), ("box", "📦"), ("fox", "🦊"), ("hen", "🐔"), ("cup", "☕"), ("map", "🗺️"),
    ("van", "🚐"), ("web", "🕸️"), ("bag", "👜"), ("cap", "🧢"), ("log", "🪵"), ("rat", "🐀"), ("bug", "🐛"),
    ("nut", "🥜"), ("leg", "🦵"), ("hut", "🛖"), ("tub", "🛁"), ("pan", "🍳"), ("net", "🥅"), ("six", "6️⃣"), ("ten", "🔟"),
]

let sightWordsEasy = ["a", "I", "is", "the", "and", "to", "in", "it", "my", "go", "see", "me", "we", "up", "no", "on", "can", "big"]
let sightWordsHard = ["you", "he", "she", "was", "are", "said", "have", "like", "they", "come", "here", "look", "what", "this", "play", "with", "where", "little"]

let rhymeSets: [[String]] = [
    ["cat", "hat", "bat", "mat", "rat"], ["dog", "log", "frog", "fog"], ["sun", "run", "bun", "fun"],
    ["bee", "tree", "three", "see"], ["star", "car", "jar"], ["cake", "snake", "lake", "rake"],
    ["moon", "spoon", "noon"], ["goat", "boat", "coat"], ["king", "ring", "sing"], ["bell", "shell", "well"],
    ["ball", "wall", "tall", "fall"], ["house", "mouse"], ["pen", "hen", "ten"], ["bed", "red", "fed"],
    ["fish", "dish", "wish"], ["cap", "map", "tap", "nap"],
]
let wordEmoji: [String: String] = [
    "cat": "🐱", "hat": "🎩", "bat": "🦇", "rat": "🐀", "dog": "🐶", "log": "🪵", "frog": "🐸", "sun": "☀️",
    "bee": "🐝", "tree": "🌳", "three": "3️⃣", "star": "⭐", "car": "🚗", "jar": "🫙", "cake": "🎂", "snake": "🐍",
    "lake": "🏞️", "moon": "🌙", "spoon": "🥄", "goat": "🐐", "boat": "⛵", "coat": "🧥", "king": "🤴", "ring": "💍",
    "bell": "🔔", "shell": "🐚", "ball": "⚽", "wall": "🧱", "house": "🏠", "mouse": "🐭", "pen": "🖊️", "hen": "🐔",
    "ten": "🔟", "bed": "🛏️", "red": "🔴", "fish": "🐟", "dish": "🍽️", "cap": "🧢", "map": "🗺️", "tap": "🚰",
]

let opposites: [(String, String)] = [
    ("big", "small"), ("hot", "cold"), ("up", "down"), ("day", "night"), ("happy", "sad"), ("fast", "slow"),
    ("tall", "short"), ("wet", "dry"), ("full", "empty"), ("open", "closed"), ("in", "out"), ("old", "new"),
    ("hard", "soft"), ("clean", "dirty"), ("heavy", "light"), ("loud", "quiet"), ("near", "far"),
]
let oppositeEmoji: [String: String] = [
    "big": "🐘", "small": "🐭", "hot": "🔥", "cold": "🧊", "up": "⬆️", "down": "⬇️", "day": "☀️", "night": "🌙",
    "happy": "😀", "sad": "😢", "fast": "🐇", "slow": "🐢", "tall": "🦒", "short": "🐧", "loud": "📢", "quiet": "🤫",
]

let plurals: [(String, String, String)] = [   // singular, plural, emoji
    ("cat", "cats", "🐱"), ("dog", "dogs", "🐶"), ("ball", "balls", "⚽"), ("pen", "pens", "🖊️"), ("cup", "cups", "☕"),
    ("hat", "hats", "🎩"), ("box", "boxes", "📦"), ("bus", "buses", "🚌"), ("fox", "foxes", "🦊"),
    ("dish", "dishes", "🍽️"), ("watch", "watches", "⌚"), ("glass", "glasses", "🥛"),
]

let articleWords: [(String, String)] = [   // word, emoji; "an" if it starts with a vowel sound
    ("apple", "🍎"), ("egg", "🥚"), ("owl", "🦉"), ("umbrella", "☂️"), ("ant", "🐜"), ("elephant", "🐘"),
    ("orange", "🍊"), ("ice cream", "🍦"), ("ball", "⚽"), ("cat", "🐱"), ("dog", "🐶"), ("kite", "🪁"),
    ("tree", "🌳"), ("book", "📕"), ("pen", "🖊️"), ("bus", "🚌"), ("fish", "🐟"), ("star", "⭐"),
]

private let similarLetters: [Character: String] = [
    "b": "dpq", "d": "bpq", "p": "bdq", "q": "pdb", "m": "nw", "n": "mhu", "u": "nv", "w": "mv",
    "i": "jl", "j": "il", "c": "eo", "e": "ca", "o": "ca", "h": "nk", "f": "tl", "t": "fl",
]

enum EnglishGen {
    static func letters(_ l: Int) -> Question {
        let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
        let lower = alphabet.any
        let upper = Character(lower.uppercased())
        let similar = Array(similarLetters[lower] ?? "")
        let others = (similar + alphabet.filter { $0 != lower }.shuffled()).filter { $0 != lower }.uniqued()
        let opts = ([lower] + others.prefix(l == 1 ? 2 : 3)).shuffled()
        let toSmall = l < 2 || Bool.random()
        return Question(prompt: toSmall ? "Find the small letter" : "Find the capital letter",
                        say: [.en(toSmall ? "Find the small letter for capital \(upper)." : "Find the capital letter for small \(lower).")],
                        visual: .bigText(toSmall ? String(upper) : String(lower)),
                        options: opts.map { c in
                            let s = toSmall ? String(c) : c.uppercased()
                            return Option(id: String(c), face: .text(s), spoken: nil)
                        },
                        answer: String(lower), explain: "Capital \(upper) and small \(lower) are the same letter.")
    }

    static func firstLetter(_ l: Int) -> Question {
        let (w, e) = picWords.any
        let first = String(w.prefix(1))
        let pool = picWords.map { String($0.0.prefix(1)) }
        let opts = choices(first, from: pool, n: l == 1 ? 3 : 4)
        return Question(prompt: "Which letter does it start with?", say: [.en("\(w). Which letter does \(w) start with?")],
                        visual: .bigEmoji(e), options: opts.map { Option(id: $0, face: .text($0), spoken: .en($0)) },
                        answer: first, explain: "\(w.capitalized) starts with \(first).")
    }

    static func startsWith(_ l: Int) -> Question {
        let target = picWords.any
        let letter = target.0.prefix(1)
        let others = picWords.filter { $0.0.prefix(1) != letter }.sample(l == 1 ? 2 : 3)
        let opts = ([target] + others).shuffled()
        return Question(prompt: "Which picture starts with \(letter.uppercased()) \(letter)?",
                        say: [.en("Which picture starts with the letter \(letter)?")],
                        options: opts.map { Option(id: $0.0, face: .emoji($0.1), spoken: nil) },
                        answer: target.0, explain: "\(target.0.capitalized) starts with \(letter).")
    }

    static func readWord(_ l: Int) -> Question {
        let (w, e) = cvcWords.any
        // Distractors that look alike: same middle vowel or same ending first.
        let similar = cvcWords.map(\.0).filter { $0 != w }.sorted { a, b in
            score(a, w) > score(b, w) || (score(a, w) == score(b, w) && Bool.random())
        }
        let opts = ([w] + similar.prefix(l == 1 ? 2 : 3)).shuffled()
        return Question(prompt: l == 1 ? "Find the word" : "What is this? Find its word.",
                        say: [.en(l == 1 ? "Find the word \(w)." : "Look at the picture. Find its word.")],
                        visual: .bigEmoji(e), options: opts.map { Option(id: $0, face: .text($0), spoken: nil) },
                        answer: w, explain: "This is a \(w).")
    }

    private static func score(_ a: String, _ b: String) -> Int {
        zip(a, b).filter { $0 == $1 }.count
    }

    static func missingLetter(_ l: Int) -> Question {
        let (w, e) = cvcWords.filter { $0.0.count == 3 }.any
        let chars = Array(w)
        let idx = l < 2 ? 1 : [0, 1, 2].any
        let missing = chars[idx]
        let vowels = Array("aeiou"), consonants = Array("bcdfghlmnprstv")
        let pool = "aeiou".contains(missing) ? vowels : consonants
        let opts = choices(missing, from: pool, n: 3)
        var shown = chars.map(String.init); shown[idx] = "_"
        return Question(prompt: shown.joined(separator: " "), say: [.en("\(w). Which letter is missing?")],
                        visual: .bigEmoji(e), options: opts.map { Option(id: String($0), face: .text(String($0)), spoken: nil) },
                        answer: String(missing), explain: "\(w) is spelt \(chars.map(String.init).joined(separator: ", ")).")
    }

    static func sightWords(_ l: Int) -> Question {
        let pool = l == 1 ? sightWordsEasy : l == 2 ? sightWordsEasy + sightWordsHard : sightWordsHard
        let w = pool.any
        let opts = choices(w, from: pool, n: l == 1 ? 3 : 4)
        return Question(prompt: "Listen and find the word 🔊", say: [.en("Find the word: \(w).")],
                        options: opts.map { Option(id: $0, face: .text($0), spoken: nil) }, answer: w,
                        explain: "This word is \(w).")
    }

    static func rhyme(_ l: Int) -> Question {
        let set = rhymeSets.any.shuffled()
        let w = set[0], ans = set[1]
        let others = rhymeSets.filter { !$0.contains(w) }.flatMap { $0 }.sample(l == 1 ? 2 : 3)
        let opts = ([ans] + others).shuffled()
        return Question(prompt: "Which word rhymes with \(w)?", say: [.en("Which word rhymes with \(w)?")],
                        visual: wordEmoji[w].map { .bigEmoji($0) } ?? .bigText(w),
                        options: opts.map { o in Option(id: o, face: wordEmoji[o].map { .emojiText($0, o) } ?? .text(o), spoken: .en(o)) },
                        answer: ans, explain: "\(w.capitalized) and \(ans) sound alike at the end.", readOptions: true)
    }

    static func opposite(_ l: Int) -> Question {
        let pair = opposites.any
        let (w, ans) = Bool.random() ? pair : (pair.1, pair.0)
        let pool = opposites.flatMap { [$0.0, $0.1] }.filter { $0 != w }
        let opts = choices(ans, from: pool, n: l == 1 ? 3 : 4)
        return Question(prompt: "Opposite of \(w)?", say: [.en("What is the opposite of \(w)?")],
                        visual: oppositeEmoji[w].map { .bigEmoji($0) } ?? .bigText(w),
                        options: opts.map { o in Option(id: o, face: oppositeEmoji[o].map { .emojiText($0, o) } ?? .text(o), spoken: .en(o)) },
                        answer: ans, explain: "The opposite of \(w) is \(ans).", readOptions: l == 1)
    }

    static func plural(_ l: Int) -> Question {
        let (one, many, e) = plurals.any
        let wrong = many.hasSuffix("es") ? one + "s" : one + "es"
        let n = rnd(2, 5)
        return Question(prompt: "One \(one), \(n) ___", say: [.en("One \(one). \(numberWords[n]) what?")],
                        visual: .emojis(e, count: n, crossed: 0),
                        options: [one, many, wrong].shuffled().map { Option(id: $0, face: .text($0), spoken: nil) },
                        answer: many, explain: "One \(one), \(numberWords[n]) \(many).")
    }

    static func article(_ l: Int) -> Question {
        let (w, e) = articleWords.any
        let an = "aeiou".contains(w.prefix(1))
        return Question(prompt: "___ \(w)", say: [.en("A or an? Which one goes with \(w)?")], visual: .bigEmoji(e),
                        options: [Option.text("a"), Option.text("an")], answer: an ? "an" : "a",
                        explain: an ? "We say an \(w), because \(w) starts with a vowel sound." : "We say a \(w).")
    }
}
