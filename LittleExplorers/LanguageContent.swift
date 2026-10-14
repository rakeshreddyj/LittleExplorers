import Foundation

/// Telugu / Hindi learning content. Romanisation is shown under every letter and word so a grown-up can help,
/// and so it still works when the iPad has no voice installed for that language.
struct Letter: Hashable { let ch: String, roman: String }
struct LangWord: Hashable { let word: String, roman: String, emoji: String, meaning: String, first: String }

struct LangPack {
    let code: String           // "te" / "hi"
    let name: String
    let vowels: [Letter]
    let consonants: [Letter]
    let words: [LangWord]
    let numbers: [Letter]      // 1...10 as words
}

let telugu = LangPack(
    code: "te", name: "Telugu",
    vowels: zip(["అ", "ఆ", "ఇ", "ఈ", "ఉ", "ఊ", "ఋ", "ఎ", "ఏ", "ఐ", "ఒ", "ఓ", "ఔ", "అం", "అః"],
                ["a", "ā", "i", "ī", "u", "ū", "ru", "e", "ē", "ai", "o", "ō", "au", "am", "aha"]).map(Letter.init),
    consonants: zip(["క", "ఖ", "గ", "ఘ", "చ", "ఛ", "జ", "ఝ", "ట", "ఠ", "డ", "ఢ", "ణ", "త", "థ", "ద", "ధ", "న",
                     "ప", "ఫ", "బ", "భ", "మ", "య", "ర", "ల", "వ", "శ", "ష", "స", "హ", "ళ", "క్ష", "ఱ"],
                    ["ka", "kha", "ga", "gha", "cha", "chha", "ja", "jha", "ṭa", "ṭha", "ḍa", "ḍha", "ṇa", "ta", "tha", "da", "dha", "na",
                     "pa", "pha", "ba", "bha", "ma", "ya", "ra", "la", "va", "śa", "ṣa", "sa", "ha", "ḷa", "kṣa", "ṟa"]).map(Letter.init),
    words: [
        .init(word: "అమ్మ", roman: "amma", emoji: "👩", meaning: "mother", first: "అ"),
        .init(word: "అరటిపండు", roman: "araṭipaṇḍu", emoji: "🍌", meaning: "banana", first: "అ"),
        .init(word: "ఆవు", roman: "āvu", emoji: "🐄", meaning: "cow", first: "ఆ"),
        .init(word: "ఇల్లు", roman: "illu", emoji: "🏠", meaning: "house", first: "ఇ"),
        .init(word: "ఉడుత", roman: "uḍuta", emoji: "🐿️", meaning: "squirrel", first: "ఉ"),
        .init(word: "ఎలుక", roman: "eluka", emoji: "🐭", meaning: "mouse", first: "ఎ"),
        .init(word: "ఏనుగు", roman: "ēnugu", emoji: "🐘", meaning: "elephant", first: "ఏ"),
        .init(word: "ఒంటె", roman: "oṇṭe", emoji: "🐪", meaning: "camel", first: "ఒ"),
        .init(word: "కప్ప", roman: "kappa", emoji: "🐸", meaning: "frog", first: "క"),
        .init(word: "కుక్క", roman: "kukka", emoji: "🐶", meaning: "dog", first: "క"),
        .init(word: "కోతి", roman: "kōti", emoji: "🐒", meaning: "monkey", first: "క"),
        .init(word: "గుర్రం", roman: "gurram", emoji: "🐴", meaning: "horse", first: "గ"),
        .init(word: "గుడ్డు", roman: "guḍḍu", emoji: "🥚", meaning: "egg", first: "గ"),
        .init(word: "చేప", roman: "chēpa", emoji: "🐟", meaning: "fish", first: "చ"),
        .init(word: "చెట్టు", roman: "cheṭṭu", emoji: "🌳", meaning: "tree", first: "చ"),
        .init(word: "టమాట", roman: "ṭamāṭa", emoji: "🍅", meaning: "tomato", first: "ట"),
        .init(word: "తాబేలు", roman: "tābēlu", emoji: "🐢", meaning: "tortoise", first: "త"),
        .init(word: "దీపం", roman: "dīpam", emoji: "🪔", meaning: "lamp", first: "ద"),
        .init(word: "నక్క", roman: "nakka", emoji: "🦊", meaning: "fox", first: "న"),
        .init(word: "నెమలి", roman: "nemali", emoji: "🦚", meaning: "peacock", first: "న"),
        .init(word: "పాము", roman: "pāmu", emoji: "🐍", meaning: "snake", first: "ప"),
        .init(word: "పిల్లి", roman: "pilli", emoji: "🐱", meaning: "cat", first: "ప"),
        .init(word: "పువ్వు", roman: "puvvu", emoji: "🌸", meaning: "flower", first: "ప"),
        .init(word: "పాలు", roman: "pālu", emoji: "🥛", meaning: "milk", first: "ప"),
        .init(word: "బంతి", roman: "banti", emoji: "⚽", meaning: "ball", first: "బ"),
        .init(word: "మామిడి", roman: "māmiḍi", emoji: "🥭", meaning: "mango", first: "మ"),
        .init(word: "రైలు", roman: "railu", emoji: "🚂", meaning: "train", first: "ర"),
        .init(word: "సింహం", roman: "simham", emoji: "🦁", meaning: "lion", first: "స"),
        .init(word: "సూర్యుడు", roman: "sūryuḍu", emoji: "☀️", meaning: "sun", first: "స"),
        .init(word: "హంస", roman: "hamsa", emoji: "🦢", meaning: "swan", first: "హ"),
    ],
    numbers: zip(["ఒకటి", "రెండు", "మూడు", "నాలుగు", "ఐదు", "ఆరు", "ఏడు", "ఎనిమిది", "తొమ్మిది", "పది"],
                 ["okaṭi", "reṇḍu", "mūḍu", "nālugu", "aidu", "āru", "ēḍu", "enimidi", "tommidi", "padi"]).map(Letter.init)
)

let hindi = LangPack(
    code: "hi", name: "Hindi",
    vowels: zip(["अ", "आ", "इ", "ई", "उ", "ऊ", "ऋ", "ए", "ऐ", "ओ", "औ", "अं", "अः"],
                ["a", "ā", "i", "ī", "u", "ū", "ṛi", "e", "ai", "o", "au", "aṃ", "aḥ"]).map(Letter.init),
    consonants: zip(["क", "ख", "ग", "घ", "च", "छ", "ज", "झ", "ट", "ठ", "ड", "ढ", "ण", "त", "थ", "द", "ध", "न",
                     "प", "फ", "ब", "भ", "म", "य", "र", "ल", "व", "श", "ष", "स", "ह", "क्ष", "त्र", "ज्ञ"],
                    ["ka", "kha", "ga", "gha", "cha", "chha", "ja", "jha", "ṭa", "ṭha", "ḍa", "ḍha", "ṇa", "ta", "tha", "da", "dha", "na",
                     "pa", "pha", "ba", "bha", "ma", "ya", "ra", "la", "va", "śa", "ṣa", "sa", "ha", "kṣa", "tra", "gya"]).map(Letter.init),
    words: [
        .init(word: "आम", roman: "ām", emoji: "🥭", meaning: "mango", first: "आ"),
        .init(word: "उल्लू", roman: "ullū", emoji: "🦉", meaning: "owl", first: "उ"),
        .init(word: "ऊन", roman: "ūn", emoji: "🧶", meaning: "wool", first: "ऊ"),
        .init(word: "ऐनक", roman: "ainak", emoji: "👓", meaning: "spectacles", first: "ऐ"),
        .init(word: "कबूतर", roman: "kabūtar", emoji: "🕊️", meaning: "pigeon", first: "क"),
        .init(word: "केला", roman: "kelā", emoji: "🍌", meaning: "banana", first: "क"),
        .init(word: "कुत्ता", roman: "kuttā", emoji: "🐶", meaning: "dog", first: "क"),
        .init(word: "खरगोश", roman: "khargosh", emoji: "🐰", meaning: "rabbit", first: "ख"),
        .init(word: "गाय", roman: "gāy", emoji: "🐄", meaning: "cow", first: "ग"),
        .init(word: "गेंद", roman: "gẽd", emoji: "⚽", meaning: "ball", first: "ग"),
        .init(word: "घड़ी", roman: "ghaṛī", emoji: "⌚", meaning: "watch", first: "घ"),
        .init(word: "घर", roman: "ghar", emoji: "🏠", meaning: "house", first: "घ"),
        .init(word: "चम्मच", roman: "chammach", emoji: "🥄", meaning: "spoon", first: "च"),
        .init(word: "चाँद", roman: "chā̃d", emoji: "🌙", meaning: "moon", first: "च"),
        .init(word: "छाता", roman: "chhātā", emoji: "☂️", meaning: "umbrella", first: "छ"),
        .init(word: "जहाज़", roman: "jahāz", emoji: "🚢", meaning: "ship", first: "ज"),
        .init(word: "झंडा", roman: "jhaṇḍā", emoji: "🚩", meaning: "flag", first: "झ"),
        .init(word: "टमाटर", roman: "ṭamāṭar", emoji: "🍅", meaning: "tomato", first: "ट"),
        .init(word: "ढोल", roman: "ḍhol", emoji: "🥁", meaning: "drum", first: "ढ"),
        .init(word: "तरबूज़", roman: "tarbūz", emoji: "🍉", meaning: "watermelon", first: "त"),
        .init(word: "दूध", roman: "dūdh", emoji: "🥛", meaning: "milk", first: "द"),
        .init(word: "धनुष", roman: "dhanuṣ", emoji: "🏹", meaning: "bow", first: "ध"),
        .init(word: "नल", roman: "nal", emoji: "🚰", meaning: "tap", first: "न"),
        .init(word: "पतंग", roman: "patang", emoji: "🪁", meaning: "kite", first: "प"),
        .init(word: "पेड़", roman: "peṛ", emoji: "🌳", meaning: "tree", first: "प"),
        .init(word: "फूल", roman: "phūl", emoji: "🌸", meaning: "flower", first: "फ"),
        .init(word: "बत्तख", roman: "battakh", emoji: "🦆", meaning: "duck", first: "ब"),
        .init(word: "बिल्ली", roman: "billī", emoji: "🐱", meaning: "cat", first: "ब"),
        .init(word: "भालू", roman: "bhālū", emoji: "🐻", meaning: "bear", first: "भ"),
        .init(word: "मछली", roman: "machhlī", emoji: "🐟", meaning: "fish", first: "म"),
        .init(word: "मोर", roman: "mor", emoji: "🦚", meaning: "peacock", first: "म"),
        .init(word: "रेल", roman: "rel", emoji: "🚂", meaning: "train", first: "र"),
        .init(word: "शेर", roman: "sher", emoji: "🦁", meaning: "lion", first: "श"),
        .init(word: "सेब", roman: "seb", emoji: "🍎", meaning: "apple", first: "स"),
        .init(word: "सूरज", roman: "sūraj", emoji: "☀️", meaning: "sun", first: "स"),
        .init(word: "हाथी", roman: "hāthī", emoji: "🐘", meaning: "elephant", first: "ह"),
    ],
    numbers: zip(["एक", "दो", "तीन", "चार", "पाँच", "छह", "सात", "आठ", "नौ", "दस"],
                 ["ek", "do", "tīn", "chār", "pā̃ch", "chhah", "sāt", "āṭh", "nau", "das"]).map(Letter.init)
)

enum LangGen {
    private static func letterOption(_ l: Letter, showRoman: Bool) -> Option {
        Option(id: l.ch, face: .script(l.ch, roman: showRoman ? l.roman : nil), spoken: nil)
    }

    /// Visual discrimination: find the same letter. Works without any audio.
    static func match(_ p: LangPack, _ l: Int) -> Question {
        let pool = l == 1 ? p.vowels : p.consonants
        let target = pool.any
        let opts = ([target] + pool.filter { $0 != target }.sample(l == 3 ? 3 : 2)).shuffled()
        return Question(prompt: "Find the same letter", say: [.en("Find the same letter.")],
                        visual: .script(target.ch, roman: nil), options: opts.map { letterOption($0, showRoman: false) },
                        answer: target.ch, explain: "This letter says \(target.roman).")
    }

    /// Hear (or read the romanisation of) a letter, tap it.
    static func sound(_ p: LangPack, _ l: Int) -> Question {
        let pool = l == 1 ? p.vowels : l == 2 ? p.consonants : p.vowels + p.consonants
        let target = pool.any
        let opts = ([target] + pool.filter { $0 != target }.sample(l == 1 ? 2 : 3)).shuffled()
        return Question(prompt: "Find the letter “\(target.roman)”",
                        say: [.en("Find the letter"), .init(text: target.ch, lang: p.code)],
                        options: opts.map { letterOption($0, showRoman: false) }, answer: target.ch,
                        explain: "\(target.ch) says \(target.roman).")
    }

    /// Picture → which letter does the word start with.
    static func firstLetter(_ p: LangPack, _ l: Int) -> Question {
        let w = p.words.any
        let letters = p.vowels + p.consonants
        let target = letters.first { $0.ch == w.first } ?? Letter(ch: w.first, roman: "")
        let pool = p.words.map(\.first).uniqued().compactMap { f in letters.first { $0.ch == f } }
        let opts = ([target] + pool.filter { $0 != target }.sample(l == 1 ? 2 : 3)).shuffled()
        return Question(prompt: "\(w.word) (\(w.roman)) starts with…",
                        say: [.init(text: w.word, lang: p.code), .en("Which letter does it start with?")],
                        visual: .bigEmoji(w.emoji), options: opts.map { letterOption($0, showRoman: l == 1) },
                        answer: target.ch, explain: "\(w.roman.capitalized) means \(w.meaning). It starts with \(target.ch).")
    }

    /// Picture → word.
    static func words(_ p: LangPack, _ l: Int) -> Question {
        let w = p.words.any
        let others = p.words.filter { $0.emoji != w.emoji }.sample(l == 1 ? 1 : 2)
        return Question(prompt: "What is this in \(p.name)?", say: [.en("What is this in \(p.name)?")],
                        visual: .bigEmoji(w.emoji),
                        options: ([w] + others).shuffled().map { Option(id: $0.word, face: .script($0.word, roman: $0.roman), spoken: .init(text: $0.word, lang: p.code)) },
                        answer: w.word, explain: "\(w.meaning.capitalized) is \(w.word) — \(w.roman).", readOptions: true)
    }

    /// Number word → number.
    static func numbers(_ p: LangPack, _ l: Int) -> Question {
        let n = rnd(1, l == 1 ? 5 : 10)
        let w = p.numbers[n - 1]
        return Question(prompt: "Which number is this?", say: [.init(text: w.ch, lang: p.code), .en("Which number is it?")],
                        visual: .script(w.ch, roman: w.roman), options: numOptions(n, lo: 1, hi: 10), answer: "\(n)",
                        explain: "\(w.ch) (\(w.roman)) is \(n).")
    }
}
