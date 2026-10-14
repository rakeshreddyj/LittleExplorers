import SwiftUI

/// Subject ids match what HomeBuddy's Kids screen expects.
enum Subject: String, CaseIterable, Codable, Identifiable {
    case math, english, evs, thinking, time, telugu, hindi
    var id: String { rawValue }
    var title: String {
        switch self {
        case .math: "Numbers"; case .english: "English"; case .evs: "Our World"; case .thinking: "Thinking"
        case .time: "Time & Money"; case .telugu: "Telugu"; case .hindi: "Hindi"
        }
    }
    var emoji: String {
        switch self {
        case .math: "🔢"; case .english: "🔤"; case .evs: "🌍"; case .thinking: "🧩"; case .time: "⏰"; case .telugu: "అ"; case .hindi: "अ"
        }
    }
    /// Muted, low-saturation tones (no neon), deeper and warmer in the evening palette.
    @MainActor var color: Color {
        let (day, eve): (String, String) = switch self {
        case .math: ("#E39268", "#A66A4C")
        case .english: ("#6F98CF", "#56698C")
        case .evs: ("#5FA884", "#4D7A60")
        case .thinking: ("#9A86CF", "#706391")
        case .time: ("#CFA24C", "#94773C")
        case .telugu: ("#D27C9D", "#935B71")
        case .hindi: ("#4FA39C", "#3E7470")
        }
        return Color(hex: Theme.evening ? eve : day)
    }
}

enum Grades { case both, ukgOnly, c1Only }

struct SkillDef {
    var isTrace: Bool { id.contains("trace") }
    var isSpeak: Bool { id.hasPrefix("speak") }
    /// Story questions only make sense right after reading the story, so they never appear in rounds.
    var inRounds: Bool { id != "story_time" }
    let id: String
    let name: String
    let subject: Subject
    let grades: Grades
    let make: (Int) -> Question
}

private func langSkills(_ p: LangPack, _ s: Subject) -> [SkillDef] {
    [
        SkillDef(id: "\(p.code)_match", name: "\(p.name): same letter", subject: s, grades: .both) { LangGen.match(p, $0) },
        SkillDef(id: "\(p.code)_sound", name: "\(p.name): letter sounds", subject: s, grades: .both) { LangGen.sound(p, $0) },
        SkillDef(id: "\(p.code)_first", name: "\(p.name): first letter", subject: s, grades: .both) { LangGen.firstLetter(p, $0) },
        SkillDef(id: "\(p.code)_words", name: "\(p.name): words", subject: s, grades: .both) { LangGen.words(p, $0) },
        SkillDef(id: "\(p.code)_numbers", name: "\(p.name): numbers", subject: s, grades: .both) { LangGen.numbers(p, $0) },
        SkillDef(id: "\(p.code)_trace", name: "\(p.name): writing letters", subject: s, grades: .both) { TraceGen.language(p, $0) },
    ]
}

let allSkills: [SkillDef] = [
    .init(id: "count", name: "Counting", subject: .math, grades: .both, make: MathGen.count),
    .init(id: "add", name: "Adding", subject: .math, grades: .both, make: MathGen.add),
    .init(id: "sub", name: "Taking away", subject: .math, grades: .both, make: MathGen.sub),
    .init(id: "compare", name: "Bigger & smaller numbers", subject: .math, grades: .both, make: MathGen.compare),
    .init(id: "order", name: "Before, after, between", subject: .math, grades: .both, make: MathGen.order),
    .init(id: "shapes", name: "Shapes", subject: .math, grades: .both, make: MathGen.shapes),
    .init(id: "skip", name: "Skip counting", subject: .math, grades: .c1Only, make: MathGen.skip),
    .init(id: "numname", name: "Number names", subject: .math, grades: .c1Only, make: MathGen.numberNames),
    .init(id: "place", name: "Tens and ones", subject: .math, grades: .c1Only, make: MathGen.placeValue),
    .init(id: "story", name: "Story sums", subject: .math, grades: .c1Only, make: MathGen.story),
    .init(id: "trace_num", name: "Writing numbers", subject: .math, grades: .both, make: TraceGen.numbers),

    .init(id: "letters", name: "Capital & small letters", subject: .english, grades: .ukgOnly, make: EnglishGen.letters),
    .init(id: "first", name: "First letter sounds", subject: .english, grades: .both, make: EnglishGen.firstLetter),
    .init(id: "starts", name: "Starts with…", subject: .english, grades: .both, make: EnglishGen.startsWith),
    .init(id: "cvc", name: "Reading 3-letter words", subject: .english, grades: .both, make: EnglishGen.readWord),
    .init(id: "missing", name: "Missing letter", subject: .english, grades: .both, make: EnglishGen.missingLetter),
    .init(id: "sight", name: "Sight words", subject: .english, grades: .both, make: EnglishGen.sightWords),
    .init(id: "rhyme", name: "Rhyming words", subject: .english, grades: .both, make: EnglishGen.rhyme),
    .init(id: "opposite", name: "Opposites", subject: .english, grades: .both, make: EnglishGen.opposite),
    .init(id: "plural", name: "One and many", subject: .english, grades: .c1Only, make: EnglishGen.plural),
    .init(id: "article", name: "A or an", subject: .english, grades: .c1Only, make: EnglishGen.article),
    .init(id: "trace_caps", name: "Writing capital letters", subject: .english, grades: .both, make: TraceGen.capitals),
    .init(id: "trace_small", name: "Writing small letters", subject: .english, grades: .both, make: TraceGen.small),
    .init(id: "trace_words", name: "Writing words", subject: .english, grades: .c1Only, make: TraceGen.words),
    .init(id: "speak_words", name: "Speaking: words", subject: .english, grades: .both, make: SpeakGen.words),
    .init(id: "speak_sentences", name: "Speaking: sentences", subject: .english, grades: .both, make: SpeakGen.sentences),
    .init(id: "speak_answers", name: "Speaking: answers", subject: .english, grades: .both, make: SpeakGen.answers),
    .init(id: "story_time", name: "Story time", subject: .english, grades: .both, make: { _ in stories[0].quizQuestions()[0] }),

    .init(id: "homes", name: "Animal homes", subject: .evs, grades: .both, make: WorldGen.homes),
    .init(id: "sounds", name: "Animal sounds", subject: .evs, grades: .ukgOnly, make: WorldGen.sounds),
    .init(id: "body", name: "My body", subject: .evs, grades: .both, make: WorldGen.body),
    .init(id: "fruitveg", name: "Fruits & vegetables", subject: .evs, grades: .both, make: WorldGen.fruitVeg),
    .init(id: "wild", name: "Wild & farm animals", subject: .evs, grades: .both, make: WorldGen.wildTame),
    .init(id: "helpers", name: "Community helpers", subject: .evs, grades: .both, make: WorldGen.helpers),
    .init(id: "transport", name: "Transport", subject: .evs, grades: .both, make: WorldGen.transport),
    .init(id: "weather", name: "Weather", subject: .evs, grades: .both, make: WorldGen.weather),
    .init(id: "habits", name: "Good habits", subject: .evs, grades: .both, make: WorldGen.habits),
    .init(id: "living", name: "Living & non-living", subject: .evs, grades: .c1Only, make: WorldGen.living),
    .init(id: "plants", name: "Parts of a plant", subject: .evs, grades: .c1Only, make: WorldGen.plants),
    .init(id: "foodfrom", name: "Food from animals", subject: .evs, grades: .c1Only, make: WorldGen.foodFrom),

    .init(id: "colors", name: "Colours", subject: .thinking, grades: .ukgOnly, make: ThinkingGen.colors),
    .init(id: "size", name: "Big & small", subject: .thinking, grades: .ukgOnly, make: ThinkingGen.size),
    .init(id: "odd", name: "Odd one out", subject: .thinking, grades: .both, make: ThinkingGen.oddOneOut),
    .init(id: "pattern", name: "Patterns", subject: .thinking, grades: .both, make: ThinkingGen.pattern),
    .init(id: "days", name: "Days of the week", subject: .thinking, grades: .both, make: ThinkingGen.days),
    .init(id: "months", name: "Months", subject: .thinking, grades: .c1Only, make: ThinkingGen.months),

    .init(id: "daynight", name: "Day & night", subject: .time, grades: .ukgOnly, make: TimeMoneyGen.dayNight),
    .init(id: "coins", name: "Coins & notes", subject: .time, grades: .both, make: TimeMoneyGen.coinSpot),
    .init(id: "clock", name: "Telling time", subject: .time, grades: .c1Only, make: TimeMoneyGen.clock),
    .init(id: "money", name: "Counting money", subject: .time, grades: .c1Only, make: TimeMoneyGen.countMoney),
] + langSkills(telugu, .telugu) + langSkills(hindi, .hindi)

let skillById: [String: SkillDef] = Dictionary(uniqueKeysWithValues: allSkills.map { ($0.id, $0) })

let stickerSet = ["🦁", "🐯", "🐼", "🐨", "🦊", "🐸", "🐵", "🦄", "🐙", "🦋", "🐢", "🐳", "🦒", "🦓", "🐘", "🦔", "🦉", "🐧",
                  "🦜", "🐬", "🐞", "🐝", "🌻", "🌈", "⭐", "🚀", "🎈", "🍉", "🍓", "🧁", "🍦", "🎨", "🎵", "⚽", "🪁", "🚂",
                  "🚁", "🌙", "☀️", "🌸", "🍀", "🐠", "🦕", "🦖", "🐿️", "🦩", "🐻", "🐰", "🐶", "🐱", "🐮", "🐷", "🐔",
                  "🐤", "🦚", "🌵", "🍄", "🐚", "🌍", "🎠"]

/// Screen-free things to do once today's time is over.
let missions = [
    "Find 3 round things in your home ⭕", "Count the spoons in the kitchen 🥄", "Find something that starts with S 🐍",
    "Help water a plant 🌱", "Tell someone at home 3 new words you learned 🗣️", "Look at a clock with a grown-up ⏰",
    "Sort your toys into big and small 🧸", "Find 5 red things 🔴", "Draw your favourite animal and its home 🖍️",
    "Help set the table and count the plates 🍽️", "Go outside and look for a bird 🐦", "Sing a rhyme with Amma or Nanna 🎶",
]

/// Eye breaks (the 20-20-20 rule: look at something far away to relax the eyes). Not counted as screen time.
let eyeBreaks: [(String, String)] = [
    ("🌳", "Look out of the window at something far, far away. Count to 20!"),
    ("🦉", "Blink slowly 10 times, like a sleepy owl."),
    ("😌", "Close your eyes and count slowly to 10."),
    ("🙌", "Rub your hands until they are warm, then cup them gently over your closed eyes."),
    ("👀", "Look up, down, left and right — slowly, without moving your head."),
]

/// Movement breaks between rounds. Not counted as screen time.
let moveBreaks: [(String, String)] = [
    ("🐸", "Jump like a frog 5 times!"), ("🦒", "Stretch up high like a giraffe!"), ("🙆", "Touch your toes 10 times!"),
    ("💧", "Go and drink some water."),
    ("🦩", "Stand on one leg like a flamingo. Count to 10!"), ("🐢", "Take 5 slow, deep breaths like a turtle."),
    ("👏", "Clap your hands 10 times!"),
]

extension Color {
    init(hex: String) {
        var v: UInt64 = 0
        Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))).scanHexInt64(&v)
        self.init(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }
}
