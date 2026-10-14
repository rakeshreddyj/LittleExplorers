import Foundation

/// Removes emoji so option labels are spoken cleanly.
func plain(_ s: String) -> String {
    s.unicodeScalars.filter { !($0.properties.isEmojiPresentation || $0.properties.isEmoji && $0.value > 0x2000 || $0.value == 0xFE0F || $0.value == 0x200D) }
        .map(String.init).joined().trimmingCharacters(in: .whitespaces)
}

/// Multiple choice where every option is "emoji label" text, read aloud for pre-readers.
private func spokenChoice(prompt: String, say: String, visual: Visual, answer: String, pool: [String], n: Int = 3,
                          explain: String) -> Question {
    let opts = choices(answer, from: pool, n: n)
    return Question(prompt: prompt, say: [.en(say)], visual: visual,
                    options: opts.map { Option(id: $0, face: .text($0), spoken: .en(plain($0))) },
                    answer: answer, explain: explain, readOptions: true)
}

enum WorldGen {
    static let homes: [(String, String, String)] = [   // emoji, animal, home
        ("🐦", "bird", "nest 🪺"), ("🕷️", "spider", "web 🕸️"), ("🐶", "dog", "kennel 🏠"), ("🦁", "lion", "den 🪨"),
        ("🐟", "fish", "water 🌊"), ("🐰", "rabbit", "burrow 🕳️"), ("🐴", "horse", "stable 🛖"),
    ]
    static func homes(_ l: Int) -> Question {
        let (e, a, h) = homes.any
        return spokenChoice(prompt: "Where does a \(a) live?", say: "Where does a \(a) live?", visual: .bigEmoji(e),
                            answer: h, pool: homes.map(\.2), n: l == 1 ? 2 : 3, explain: "A \(a) lives in a \(plain(h)).")
    }

    static let sounds: [(String, String, String)] = [
        ("🐄", "cow", "moo"), ("🐶", "dog", "woof"), ("🐱", "cat", "meow"), ("🦁", "lion", "roar"), ("🦆", "duck", "quack"),
        ("🐑", "sheep", "baa"), ("🐍", "snake", "hiss"), ("🐝", "bee", "buzz"), ("🐴", "horse", "neigh"), ("🐸", "frog", "croak"),
    ]
    static func sounds(_ l: Int) -> Question {
        let (e, a, s) = sounds.any
        return spokenChoice(prompt: "What does a \(a) say?", say: "What sound does a \(a) make?", visual: .bigEmoji(e),
                            answer: s, pool: sounds.map(\.2), explain: "A \(a) says \(s)!")
    }

    static let body: [(String, String)] = [
        ("see", "eyes 👀"), ("hear", "ears 👂"), ("smell", "nose 👃"), ("taste", "tongue 👅"),
        ("walk", "legs 🦵"), ("hold things", "hands ✋"), ("chew food", "teeth 🦷"),
    ]
    static func body(_ l: Int) -> Question {
        let (verb, part) = body.any
        return spokenChoice(prompt: "We \(verb) with our…", say: "We \(verb) with our what?", visual: .none,
                            answer: part, pool: body.map(\.1), n: l == 1 ? 3 : 4, explain: "We \(verb) with our \(plain(part)).")
    }

    static let fruits = [("🍎", "apple"), ("🍌", "banana"), ("🍇", "grapes"), ("🍊", "orange"), ("🍉", "watermelon"),
                         ("🍓", "strawberry"), ("🥭", "mango"), ("🍍", "pineapple"), ("🍐", "pear")]
    static let veggies = [("🥕", "carrot"), ("🥔", "potato"), ("🥦", "broccoli"), ("🌽", "corn"), ("🧅", "onion"),
                          ("🥒", "cucumber"), ("🍆", "brinjal"), ("🫑", "capsicum")]
    static func fruitVeg(_ l: Int) -> Question {
        let isFruit = Bool.random()
        let (e, n) = (isFruit ? fruits : veggies).any
        let ans = isFruit ? "Fruit" : "Vegetable"
        return Question(prompt: "Fruit or vegetable?", say: [.en("\(n). Is it a fruit or a vegetable?")], visual: .bigEmoji(e),
                        options: [.text("Fruit"), .text("Vegetable")], answer: ans,
                        explain: "\(n.capitalized) is a \(ans.lowercased()).", readOptions: true)
    }

    static let tame = [("🐄", "cow"), ("🐶", "dog"), ("🐱", "cat"), ("🐐", "goat"), ("🐑", "sheep"), ("🐔", "hen"), ("🐃", "buffalo")]
    static let wild = [("🦁", "lion"), ("🐯", "tiger"), ("🐻", "bear"), ("🦊", "fox"), ("🦓", "zebra"), ("🦒", "giraffe"), ("🐺", "wolf")]
    static func wildTame(_ l: Int) -> Question {
        let isWild = Bool.random()
        let (e, n) = (isWild ? wild : tame).any
        let ans = isWild ? "Wild animal 🌳" : "Pet or farm animal 🏡"
        return Question(prompt: "Where does it belong?", say: [.en("\(n). Is it a wild animal, or a pet or farm animal?")],
                        visual: .bigEmoji(e), options: ["Pet or farm animal 🏡", "Wild animal 🌳"].map { Option(id: $0, face: .text($0), spoken: .en(plain($0))) },
                        answer: ans, explain: "A \(n) is a \(plain(ans).lowercased()).")
    }

    static let helpers: [(String, String, String)] = [
        ("🧑‍🚒", "puts out fires", "firefighter"), ("🧑‍⚕️", "looks after sick people", "doctor"),
        ("👮", "keeps us safe", "police officer"), ("🧑‍🌾", "grows our food", "farmer"),
        ("🧑‍🏫", "teaches us in school", "teacher"), ("🧑‍✈️", "flies an aeroplane", "pilot"),
        ("🧑‍🍳", "cooks food", "cook"), ("🧑‍🔧", "fixes cars and machines", "mechanic"),
    ]
    static func helpers(_ l: Int) -> Question {
        let h = helpers.any
        let others = helpers.filter { $0.2 != h.2 }.sample(l == 1 ? 2 : 3)
        return Question(prompt: "Who \(h.1)?", say: [.en("Who \(h.1)?")],
                        options: ([h] + others).shuffled().map { Option(id: $0.2, face: .emoji($0.0), spoken: nil) },
                        answer: h.2, explain: "A \(h.2) \(h.1).")
    }

    static let transport: [(String, String, String)] = [
        ("🚗", "car", "Land 🛣️"), ("🚌", "bus", "Land 🛣️"), ("🚲", "cycle", "Land 🛣️"), ("🚂", "train", "Land 🛣️"),
        ("🛺", "auto rickshaw", "Land 🛣️"), ("🚜", "tractor", "Land 🛣️"), ("⛵", "sailboat", "Water 🌊"),
        ("🚢", "ship", "Water 🌊"), ("🛶", "canoe", "Water 🌊"), ("✈️", "aeroplane", "Air ☁️"), ("🚁", "helicopter", "Air ☁️"),
    ]
    static func transport(_ l: Int) -> Question {
        let (e, n, way) = transport.any
        return Question(prompt: "Where does it go?", say: [.en("Where does a \(n) go? On land, on water, or in the air?")],
                        visual: .bigEmoji(e),
                        options: ["Land 🛣️", "Water 🌊", "Air ☁️"].map { Option(id: $0, face: .text($0), spoken: .en(plain($0))) },
                        answer: way, explain: "A \(n) goes on \(plain(way).lowercased() == "air" ? "the air" : plain(way).lowercased()).")
    }

    static let weather: [(String, String, String)] = [
        ("🌧️", "it is raining", "umbrella ☂️"), ("🥶", "it is very cold", "sweater 🧥"),
        ("☀️", "it is very sunny", "cap 🧢"), ("🌙", "it is dark at night", "torch 🔦"),
    ]
    static func weather(_ l: Int) -> Question {
        let (e, w, item) = weather.any
        return spokenChoice(prompt: "What do we need?", say: "What do we need when \(w)?", visual: .bigEmoji(e),
                            answer: item, pool: weather.map(\.2), explain: "When \(w), we use a \(plain(item)).")
    }

    static let habits: [(String, String)] = [
        ("🪥 Brush teeth every day", "😬 Never brush teeth"), ("🧼 Wash hands before eating", "🤲 Eat with dirty hands"),
        ("🗑️ Throw rubbish in the dustbin", "🛣️ Throw rubbish on the road"), ("🙏 Say thank you", "😠 Snatch toys"),
        ("😴 Sleep early", "📺 Watch TV all night"), ("💧 Drink clean water", "🚱 Drink dirty water"),
        ("🚦 Wait for the green light", "🏃 Run across the road"), ("🤝 Share with friends", "🙅 Never share"),
    ]
    static func habits(_ l: Int) -> Question {
        let (good, bad) = habits.any
        return Question(prompt: "Which is a good habit?", say: [.en("Which one is a good habit?")],
                        options: [good, bad].shuffled().map { Option(id: $0, face: .text($0), spoken: .en(plain($0))) },
                        answer: good, explain: "\(plain(good)) is a good habit.", readOptions: true)
    }

    static let living = ["🐶", "🌳", "🐦", "🧒", "🐟", "🌻", "🐛", "🐄"]
    static let nonLiving = ["🪨", "🚗", "🪑", "📱", "🏠", "⚽", "🧸", "✏️"]
    static func living(_ l: Int) -> Question {
        let isLiving = Bool.random()
        let e = (isLiving ? living : nonLiving).any
        let ans = isLiving ? "Living" : "Non-living"
        return Question(prompt: "Living or non-living?", say: [.en("Is it living or non-living?")], visual: .bigEmoji(e),
                        options: [.text("Living"), .text("Non-living")], answer: ans,
                        explain: isLiving ? "Living things grow, eat and breathe." : "Non-living things do not grow or breathe.",
                        readOptions: true)
    }

    static let plantParts: [(String, String)] = [
        ("Which part of a plant grows under the ground?", "Roots"), ("Which part of a plant makes food from sunlight?", "Leaves"),
        ("Which part of a plant holds it up straight?", "Stem"), ("Which part of a plant turns into a fruit?", "Flower"),
        ("What do we put in the soil to grow a new plant?", "Seed"),
    ]
    static func plants(_ l: Int) -> Question {
        let (q, a) = plantParts.any
        return spokenChoice(prompt: q, say: q, visual: .bigEmoji("🌱"), answer: a, pool: plantParts.map(\.1),
                            explain: "The answer is \(a.lowercased()).")
    }

    static let foodFrom: [(String, String, String)] = [   // product, animal emoji, animal
        ("milk 🥛", "🐄", "cow"), ("eggs 🥚", "🐔", "hen"), ("honey 🍯", "🐝", "bee"), ("wool 🧶", "🐑", "sheep"),
    ]
    static func foodFrom(_ l: Int) -> Question {
        let f = foodFrom.any
        return Question(prompt: "Where do we get \(f.0) from?", say: [.en("Where do we get \(plain(f.0)) from?")],
                        options: ([f] + foodFrom.filter { $0.2 != f.2 }.sample(2)).shuffled()
                            .map { Option(id: $0.2, face: .emoji($0.1), spoken: nil) },
                        answer: f.2, explain: "We get \(plain(f.0)) from a \(f.2).")
    }
}
