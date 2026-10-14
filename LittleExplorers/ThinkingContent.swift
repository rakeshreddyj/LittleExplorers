import Foundation

let kidColors: [(String, String)] = [
    ("red", "#E53935"), ("blue", "#1E88E5"), ("yellow", "#FDD835"), ("green", "#43A047"), ("orange", "#FB8C00"),
    ("purple", "#8E24AA"), ("pink", "#F06292"), ("brown", "#795548"), ("black", "#222222"), ("white", "#FFFFFF"),
]
let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

enum ThinkingGen {
    static let colorThings: [(String, String, String)] = [
        ("🍌", "banana", "yellow"), ("🍎", "apple", "red"), ("🥦", "broccoli", "green"), ("🍊", "orange", "orange"),
        ("🍇", "grapes", "purple"), ("🐸", "frog", "green"), ("🌻", "sunflower", "yellow"), ("🍫", "chocolate", "brown"),
        ("🍓", "strawberry", "red"), ("🥕", "carrot", "orange"),
    ]

    static func colors(_ l: Int) -> Question {
        let pool = Array(kidColors.prefix(l == 1 ? 4 : l == 2 ? 7 : 10))
        if l > 1 && Bool.random() {
            let (e, n, c) = colorThings.any
            let hex = kidColors.first { $0.0 == c }!.1
            let opts = ([(c, hex)] + kidColors.filter { $0.0 != c }.sample(2)).shuffled()
            return Question(prompt: "What colour is a \(n)?", say: [.en("What colour is a \(n)?")], visual: .bigEmoji(e),
                            options: opts.map { Option(id: $0.0, face: .color($0.1), spoken: nil) }, answer: c,
                            explain: "A \(n) is \(c).")
        }
        let target = pool.any
        let opts = ([target] + pool.filter { $0.0 != target.0 }.sample(l == 1 ? 2 : 3)).shuffled()
        return Question(prompt: "Tap \(target.0)", say: [.en("Tap the \(target.0) one.")],
                        options: opts.map { Option(id: $0.0, face: .color($0.1), spoken: nil) }, answer: target.0,
                        explain: "This one is \(target.0).")
    }

    static func size(_ l: Int) -> Question {
        let t = things.any
        let sizes = [44.0, 66.0, 92.0, 120.0].sample(l == 1 ? 2 : 3)
        let wantBig = Bool.random()
        let word = l == 1 ? (wantBig ? "bigger" : "smaller") : (wantBig ? "biggest" : "smallest")
        let ans = wantBig ? sizes.max()! : sizes.min()!
        return Question(prompt: "Tap the \(word) one", say: [.en("Tap the \(word) \(t.one).")],
                        options: sizes.map { Option(id: "\(Int($0))", face: .sized(t.e, $0), spoken: nil) },
                        answer: "\(Int(ans))", explain: "That one is the \(word).")
    }

    static let groups: [String: [String]] = [
        "fruits": ["🍎", "🍌", "🍇", "🍊", "🍓", "🍍", "🥭", "🍉"],
        "animals": ["🐶", "🐱", "🐄", "🐘", "🦁", "🐒", "🐰", "🐯"],
        "vehicles": ["🚗", "🚌", "🚲", "🚂", "✈️", "🚢", "🛺", "🚜"],
        "clothes": ["👕", "👖", "👗", "🧦", "🧢", "🧥"],
        "school things": ["✏️", "📏", "✂️", "📚", "🖍️", "🎒"],
    ]
    static func oddOneOut(_ l: Int) -> Question {
        let names = groups.keys.sorted().shuffled()
        let same = groups[names[0]]!.sample(l == 1 ? 2 : 3)
        let odd = groups[names[1]]!.any
        return Question(prompt: "Which one does not belong?", say: [.en("Which one does not belong?")],
                        options: (same + [odd]).shuffled().map { Option(id: $0, face: .emoji($0), spoken: nil) },
                        answer: odd, explain: "The others are all \(names[0]).")
    }

    static let patternSets = [["🔴", "🔵", "🟡", "🟢"], ["🍎", "🍌", "🍇"], ["🐶", "🐱", "🐭"], ["⭐", "🌙", "☀️"], ["🔺", "🟦", "🟣"]]
    static func pattern(_ l: Int) -> Question {
        let s = patternSets.any.shuffled()
        let a = s[0], b = s[1], c = s[2]
        let unit: [String] = l == 1 ? [[a, b], [a, a, b]].any : l == 2 ? [[a, b, c], [a, b, b], [a, a, b, b]].any : [[a, b, c, c], [a, a, b, c], [a, b, b, c]].any
        let len = max(5, unit.count * 2 - 1)
        let seq = (0..<len).map { unit[$0 % unit.count] }
        let ans = unit[len % unit.count]
        return Question(prompt: "What comes next?", say: [.en("Look at the pattern. What comes next?")],
                        visual: .sequence(seq + ["?"]),
                        options: [a, b, c].shuffled().map { Option(id: $0, face: .emoji($0), spoken: nil) },
                        answer: ans, explain: "The pattern repeats.")
    }

    static func days(_ l: Int) -> Question {
        let i = rnd(0, 6)
        let after = l < 2 || Bool.random()
        let ans = weekDays[(i + (after ? 1 : 6)) % 7]
        let pool = weekDays.filter { $0 != weekDays[i] }
        return Question(prompt: "Which day comes \(after ? "after" : "before") \(weekDays[i])?",
                        say: [.en("Which day comes \(after ? "after" : "before") \(weekDays[i])?")],
                        options: choices(ans, from: pool).map(Option.text), answer: ans,
                        explain: "\(ans) comes \(after ? "after" : "before") \(weekDays[i]).", readOptions: true)
    }

    static func months(_ l: Int) -> Question {
        let i = rnd(0, 11)
        let after = l < 3 || Bool.random()
        let ans = monthNames[(i + (after ? 1 : 11)) % 12]
        let pool = monthNames.filter { $0 != monthNames[i] }
        return Question(prompt: "Which month comes \(after ? "after" : "before") \(monthNames[i])?",
                        say: [.en("Which month comes \(after ? "after" : "before") \(monthNames[i])?")],
                        options: choices(ans, from: pool).map(Option.text), answer: ans,
                        explain: "\(ans) comes \(after ? "after" : "before") \(monthNames[i]).", readOptions: true)
    }
}

enum TimeMoneyGen {
    static let dayNight: [(String, String)] = [
        ("When do we see the moon and stars?", "Night 🌙"), ("When does the sun shine in the sky?", "Day ☀️"),
        ("When do we sleep in our beds?", "Night 🌙"), ("When do we go to school?", "Day ☀️"),
        ("When do we play in the park?", "Day ☀️"), ("When do owls wake up to look for food?", "Night 🌙"),
    ]
    static func dayNight(_ l: Int) -> Question {
        let (q, a) = dayNight.any
        return Question(prompt: q, say: [.en(q)], options: ["Day ☀️", "Night 🌙"].map { Option(id: $0, face: .text($0), spoken: .en(plain($0))) },
                        answer: a, explain: "The answer is \(plain(a).lowercased()).", readOptions: true)
    }

    static let money: [Money] = [.init(value: 1, note: false), .init(value: 2, note: false), .init(value: 5, note: false),
                                 .init(value: 10, note: false), .init(value: 10, note: true), .init(value: 20, note: true),
                                 .init(value: 50, note: true)]
    static func coinSpot(_ l: Int) -> Question {
        let pool = Array(money.prefix(l == 1 ? 4 : 7))
        let target = pool.any
        let opts = ([target] + pool.filter { $0 != target }.sample(l == 1 ? 2 : 3)).shuffled()
        return Question(prompt: "Find the ₹\(target.value) \(target.note ? "note" : "coin")",
                        say: [.en("Tap the \(target.spoken).")],
                        options: opts.map { Option(id: "\($0.value)\($0.note ? "n" : "c")", face: .money($0), spoken: nil) },
                        answer: "\(target.value)\(target.note ? "n" : "c")", explain: "This is the \(target.spoken).")
    }

    static func clock(_ l: Int) -> Question {
        let h = rnd(1, 12)
        let half = l == 3 && Bool.random()
        let label = { (hh: Int, hf: Bool) in hf ? "half past \(hh)" : "\(hh) o'clock" }
        let ans = label(h, half)
        let wrongs = [label(h % 12 + 1, half), label(h, !half), label((h + 5) % 12 + 1, half)].filter { $0 != ans }.uniqued()
        let opts = ([ans] + wrongs.prefix(2)).shuffled()
        return Question(prompt: "What time is it?", say: [.en("What time is it?")], visual: .clock(hour: h, minute: half ? 30 : 0),
                        options: opts.map(Option.text), answer: ans,
                        explain: half ? "The long hand is on 6, so it is half past \(h)." : "The long hand is on 12 and the short hand is on \(h), so it is \(h) o'clock.",
                        readOptions: true)
    }

    static func countMoney(_ l: Int) -> Question {
        let pool = l <= 2 ? money.filter { !$0.note && $0.value <= 5 } : money.filter { $0.value <= 20 }
        let items = (0..<rnd(2, l <= 2 ? 3 : 4)).map { _ in pool.any }.sorted { $0.value > $1.value }
        let total = items.map(\.value).reduce(0, +)
        return Question(prompt: "How much money?", say: [.en("How much money is this? Add it up.")], visual: .coins(items),
                        options: numOptions(total, lo: 1, rupees: true), answer: "\(total)",
                        explain: items.map { "\($0.value)" }.joined(separator: " plus ") + " makes \(total) rupees.")
    }
}
