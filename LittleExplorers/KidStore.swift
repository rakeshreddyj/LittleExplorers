import Foundation

struct SkillState: Codable {
    var lvl: Int
    var correct = 0
    var total = 0
    var recent: [Bool] = []
}

struct DayStat: Codable {
    var secs = 0
    var rounds = 0
    var stars = 0
    var questions = 0
    var correct = 0
    var adventure = 0     // mixed "adventure" rounds finished today
    var stories = 0       // stories read today (kept on the iPad only)
    var spoken = 0        // speaking tasks done well today (kept on the iPad only)

    init() {}
    init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        secs = try c.decodeIfPresent(Int.self, forKey: .secs) ?? 0
        rounds = try c.decodeIfPresent(Int.self, forKey: .rounds) ?? 0
        stars = try c.decodeIfPresent(Int.self, forKey: .stars) ?? 0
        questions = try c.decodeIfPresent(Int.self, forKey: .questions) ?? 0
        correct = try c.decodeIfPresent(Int.self, forKey: .correct) ?? 0
        adventure = try c.decodeIfPresent(Int.self, forKey: .adventure) ?? 0
        stories = try c.decodeIfPresent(Int.self, forKey: .stories) ?? 0
        spoken = try c.decodeIfPresent(Int.self, forKey: .spoken) ?? 0
    }
}

struct Progress: Codable {
    var skills: [String: SkillState] = [:]
    var days: [String: DayStat] = [:]
    var stickers: [String] = []
    var review: [Question] = []   // missed questions, asked again later
}

enum RoundMode: Hashable { case adventure, subject(Subject), writing, speaking, story(String) }

/// Local-first progress for one child. Everything works offline; it syncs to the HomeBuddy backend when it can.
@MainActor
final class KidStore: ObservableObject {
    @Published var profile: KidProfile
    @Published var progress: Progress
    @Published var syncError: String?

    private let fileURL: URL

    init(profile: KidProfile) {
        self.profile = profile
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("progress-\(profile.id).json")
        progress = (try? JSONDecoder().decode(Progress.self, from: Data(contentsOf: fileURL))) ?? Progress()
    }

    func save() {
        if let d = try? JSONEncoder().encode(progress) { try? d.write(to: fileURL, options: .atomic) }
        cacheProfile(profile)
    }

    // MARK: Day + time limit

    static func dayKey(_ date: Date = Date()) -> String {
        let f = DateFormatter(); f.calendar = Calendar(identifier: .gregorian); f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }

    var today: DayStat {
        get { progress.days[Self.dayKey()] ?? DayStat() }
        set { progress.days[Self.dayKey()] = newValue }
    }

    var limitSecs: Int { (profile.daily_limit_min + profile.bonus_today_min) * 60 }
    var secsLeft: Int { max(0, limitSecs - today.secs) }
    var isTimeUp: Bool { secsLeft == 0 }
    var adventureDone: Bool { today.adventure >= profile.plan_rounds }

    /// Screen time since the last eye break; after 8 minutes the next round ends with an eye break (20-20-20 rule).
    private(set) var secsSinceEyeBreak = 0
    var eyeBreakDue: Bool { secsSinceEyeBreak >= 8 * 60 }
    func tookEyeBreak() { secsSinceEyeBreak = 0 }

    func tick(_ secs: Int) {
        secsSinceEyeBreak += secs
        today.secs += secs
        if today.secs % 30 == 0 { save() }
    }

    // MARK: Skills

    var isClassOne: Bool { profile.grade == "C1" }

    var subjects: [Subject] {
        Subject.allCases.filter { s in
            switch s {
            case .telugu: profile.languages.contains("te")
            case .hindi: profile.languages.contains("hi")
            default: true
            }
        }
    }

    /// Speaking practice is switched on by a grown-up (it needs the microphone and on-device speech recognition).
    var speakingOn: Bool { UserDefaults.standard.bool(forKey: "speaking_on") && Listener.shared.ready }

    func skills(in subject: Subject) -> [SkillDef] {
        allSkills.filter {
            $0.subject == subject && (isClassOne ? $0.grades != .ukgOnly : $0.grades != .c1Only) && (!$0.isSpeak || speakingOn)
        }
    }

    var storyShelf: [Story] { stories.filter { isClassOne || !$0.classOne } }

    /// UKG stays within the UKG syllabus (levels 1–2); level 3 is Class 1 material.
    var maxLevel: Int { isClassOne ? 3 : 2 }

    func isAvailable(_ id: String) -> Bool {
        guard let def = skillById[id] else { return false }
        return subjects.contains(def.subject) && skills(in: def.subject).contains { $0.id == id }
    }

    func state(_ id: String) -> SkillState {
        let start = isClassOne && skillById[id]?.grades == .both ? 3 : 2
        var s = progress.skills[id] ?? SkillState(lvl: start)
        s.lvl = min(s.lvl, maxLevel)   // e.g. if the class is changed back from Class 1 to UKG
        return s
    }

    /// Weaker and newer skills come up more often.
    private func pickSkill(in subject: Subject, avoiding last: String?) -> SkillDef {
        let pool = skills(in: subject).filter { $0.id != last && $0.inRounds }
        let weights = pool.map { def -> Double in
            let s = state(def.id)
            let acc = s.total == 0 ? 0.5 : Double(s.correct) / Double(s.total)
            return 1 + (1 - acc) * 2 + (s.total < 5 ? 1 : 0)
        }
        var r = Double.random(in: 0..<weights.reduce(0, +))
        for (def, w) in zip(pool, weights) { r -= w; if r < 0 { return def } }
        return pool.last!
    }

    func buildRound(_ mode: RoundMode, size: Int = 5) -> [Question] {
        #if DEBUG
        // Screenshots / checks: SIMCTL_CHILD_LE_SKILL=clock SIMCTL_CHILD_LE_LEVEL=3 opens straight into that skill.
        let env = ProcessInfo.processInfo.environment
        if let id = env["LE_SKILL"], let def = skillById[id] {
            let lvl = Int(env["LE_LEVEL"] ?? "") ?? 2
            return (0..<size).map { _ in var q = def.make(lvl); q.skill = id; return q }
        }
        #endif
        var qs: [Question] = []
        var seen = Set<String>()
        progress.review.removeAll { !isAvailable($0.skill) }   // drop missed questions from another class
        if case .story(let id) = mode { return stories.first { $0.id == id }?.quizQuestions() ?? [] }
        if mode == .writing { return specialRound(\.isTrace, size: 4) }
        if mode == .speaking { return specialRound(\.isSpeak, size: 4) }
        if mode == .adventure, let missed = progress.review.first {
            progress.review.removeFirst()
            var q = missed; q.id = UUID()
            qs.append(q); seen.insert(q.key)
        }
        let order: [Subject] = { if case .subject(let s) = mode { return [s] }; return subjects.shuffled() }()
        var traces = 0, speaks = 0
        var last: String?
        var guardCount = 0
        while qs.count < size && guardCount < 80 {
            guardCount += 1
            let subject = order[qs.count % order.count]
            let def = pickSkill(in: subject, avoiding: last)
            if def.isTrace { if traces >= 1 { continue }; traces += 1 }   // at most one tracing task in a mixed round
            if def.isSpeak { if speaks >= 1 { continue }; speaks += 1 }   // and at most one speaking task
            var q = def.make(state(def.id).lvl)
            q.skill = def.id
            guard seen.insert(q.key).inserted else { continue }
            qs.append(q); last = def.id
        }
        return qs
    }

    /// A round of one kind only: tracing (letters, numbers, Telugu / Hindi letters) or speaking.
    private func specialRound(_ kind: KeyPath<SkillDef, Bool>, size: Int) -> [Question] {
        let pool = subjects.flatMap { skills(in: $0) }.filter { $0[keyPath: kind] }
        var qs: [Question] = [], seen = Set<String>(), guardCount = 0
        while qs.count < size && guardCount < 40 && !pool.isEmpty {
            guardCount += 1
            let def = pool.any
            var q = def.make(state(def.id).lvl); q.skill = def.id
            if seen.insert(q.key).inserted { qs.append(q) }
        }
        return qs
    }

    /// Records a first-try result. Three right in a row → harder; three of the last four wrong → easier.
    /// Returns true when the child just levelled up.
    @discardableResult
    func record(_ q: Question, firstTry ok: Bool) -> Bool {
        var s = state(q.skill)
        s.total += 1; if ok { s.correct += 1 }
        s.recent.append(ok); if s.recent.count > 6 { s.recent.removeFirst() }
        var levelUp = false
        let last3 = s.recent.suffix(3), last4 = s.recent.suffix(4)
        if last3.count == 3 && last3.allSatisfy({ $0 }) && s.lvl < maxLevel { s.lvl += 1; s.recent = []; levelUp = true }
        else if last4.filter({ !$0 }).count >= 3 && s.lvl > 1 { s.lvl -= 1; s.recent = [] }
        progress.skills[q.skill] = s
        var d = today; d.questions += 1; if ok { d.correct += 1 }; if ok && q.speak != nil { d.spoken += 1 }; today = d
        if !ok && !progress.review.contains(where: { $0.key == q.key }) {
            progress.review.append(q); if progress.review.count > 12 { progress.review.removeFirst() }
        }
        save()
        return levelUp
    }

    /// Ends a round and hands out the next sticker.
    func finishRound(mode: RoundMode, stars: Int) -> String {
        var d = today
        d.rounds += 1; d.stars += stars
        if mode == .adventure { d.adventure += 1 }
        if case .story = mode { d.stories += 1 }
        today = d
        let sticker = stickerSet[progress.stickers.count % stickerSet.count]
        progress.stickers.append(sticker)
        save()
        Task { await sync() }
        return sticker
    }

    var stickersToday: Int { today.rounds }

    var mission: String {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return missions[day % missions.count]
    }

    // MARK: Sync

    func sync() async {
        let recentDays = progress.days.keys.sorted().suffix(30)
        let payload = KidSyncPayload(
            skills: progress.skills.compactMap { id, s in
                guard let def = skillById[id] else { return nil }
                return .init(skill_id: id, name: def.name, subject: def.subject.rawValue, lvl: s.lvl, correct: s.correct, total: s.total)
            },
            days: recentDays.map { k in
                let d = progress.days[k]!
                return .init(date: k, secs: d.secs, rounds: d.rounds, stars: d.stars, questions: d.questions, correct: d.correct,
                             stories: d.stories, spoken: d.spoken)
            },
            stickers: progress.stickers.count,
            today: Self.dayKey())
        do {
            profile = try await APIClient.shared.sync(profileId: profile.id, payload)
            syncError = nil
            save()
        } catch {
            syncError = error.localizedDescription   // offline is fine; we'll try again next round
        }
    }
}

// Last-known profile so the app opens offline.
func cacheProfile(_ p: KidProfile) {
    if let d = try? JSONEncoder().encode(p) { UserDefaults.standard.set(d, forKey: "profile_cache") }
}
func cachedProfile() -> KidProfile? {
    UserDefaults.standard.data(forKey: "profile_cache").flatMap { try? JSONDecoder().decode(KidProfile.self, from: $0) }
}
