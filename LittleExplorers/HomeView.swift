import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: KidStore
    let start: (RoundMode) -> Void
    let openStories: () -> Void
    let openStickers: () -> Void
    let openGrownUps: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                if store.secsLeft < 4 * 60 {
                    Text("⏳ Just one more round today, then it's play time outside!")
                        .font(Theme.font(22, .semibold)).foregroundStyle(Theme.ink)
                        .padding(16).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.highlight))
                }
                adventure
                week
                if store.today.rounds == 0 { postureTip }
                Text("Explore").font(Theme.font(30)).foregroundStyle(Theme.ink)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 20)], spacing: 20) {
                    ForEach(store.subjects) { s in
                        Button { start(.subject(s)) } label: { tile(s) }.buttonStyle(.plain)
                        if s == .english {
                            Button { openStories() } label: { tile(emoji: "📖", title: "Stories", color: Theme.stories) }
                                .buttonStyle(.plain)
                            Button { start(.writing) } label: { tile(emoji: "✏️", title: "Writing", color: Theme.writing) }
                                .buttonStyle(.plain)
                            if store.speakingOn {
                                Button { start(.speaking) } label: { tile(emoji: "🗣️", title: "Speaking", color: Theme.speaking) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(32)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(store.profile.name)! 👋").font(Theme.font(44)).foregroundStyle(Theme.ink)
                Text("⭐ \(store.today.stars) stars today").font(Theme.font(22, .semibold)).foregroundStyle(Theme.muted)
            }
            Spacer()
            Button(action: openStickers) {
                VStack { Text("📒").font(.system(size: 44)); Text("Stickers").font(Theme.font(16)) }
            }.buttonStyle(.plain).foregroundStyle(Theme.ink)
            Button(action: openGrownUps) {
                VStack { Text("👪").font(.system(size: 30)); Text("Grown-ups").font(Theme.font(13)) }
            }.buttonStyle(.plain).foregroundStyle(Theme.muted).padding(.leading, 16)
        }
    }

    private var adventure: some View {
        let done = store.today.adventure, plan = store.profile.plan_rounds
        return VStack(alignment: .leading, spacing: 18) {
            Text(store.adventureDone ? "Today's adventure is complete! 🎉" : "Today's Adventure")
                .font(Theme.font(32)).foregroundStyle(Theme.onColor)
            HStack(spacing: 14) {
                ForEach(0..<plan, id: \.self) { k in
                    Text(k < done ? "⭐" : "\(k + 1)").font(Theme.font(30))
                        .frame(width: 64, height: 64)
                        .background(Circle().fill(Theme.onColor.opacity(k < done ? 1 : k == done ? 0.9 : 0.35)))
                        .foregroundStyle(Theme.accent)
                        .scaleEffect(k == done ? 1.12 : 1)
                    if k < plan - 1 { Rectangle().fill(Theme.onColor.opacity(0.5)).frame(width: 24, height: 5) }
                }
                Text("🏁").font(.system(size: 44))
                Spacer()
                if !store.adventureDone {
                    Button(done == 0 ? "Start ▶" : "Next ▶") { start(.adventure) }
                        .buttonStyle(BigButtonStyle(color: Theme.deep))
                }
            }
            if store.adventureDone {
                Text("You can explore a little more, or go and play! 🌳").font(Theme.font(20, .semibold)).foregroundStyle(Theme.onColor)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 32)
            .fill(LinearGradient(colors: Theme.hero, startPoint: .topLeading, endPoint: .bottomTrailing)))
    }

    /// Daily scores for the last 7 days: stars earned each day (a record, not a streak to protect).
    private var week: some View {
        let cal = Calendar.current
        let days = (0..<7).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My week").font(Theme.font(24)).foregroundStyle(Theme.ink)
                Spacer()
                let t = store.today
                if t.questions > 0 {
                    Text("Today: \(t.correct) of \(t.questions) right first time")
                        .font(Theme.font(18, .semibold)).foregroundStyle(Theme.muted)
                }
            }
            HStack(spacing: 10) {
                ForEach(days, id: \.self) { day in
                    let key = KidStore.dayKey(day)
                    let stat = store.progress.days[key]
                    let isToday = cal.isDateInToday(day)
                    VStack(spacing: 6) {
                        Text(day.formatted(.dateTime.weekday(.abbreviated))).font(Theme.font(15, .semibold)).foregroundStyle(Theme.muted)
                        Text((stat?.stars ?? 0) > 0 ? "⭐\(stat!.stars)" : "·").font(Theme.font(20)).foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(RoundedRectangle(cornerRadius: 14).fill(isToday ? Theme.highlight : Theme.bg))
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Theme.card))
    }

    private var postureTip: some View {
        HStack(spacing: 14) {
            Text("👀").font(.system(size: 40))
            Text("Hold the iPad far away — as far as your elbow — and sit up tall.")
                .font(Theme.font(22, .semibold)).foregroundStyle(Theme.ink)
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
    }

    private func tile(_ s: Subject) -> some View { tile(emoji: s.emoji, title: s.title, color: s.color) }

    private func tile(emoji: String, title: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Text(emoji).font(.system(size: 64, weight: .bold)).foregroundStyle(Theme.onColor)
            Text(title).font(Theme.font(26)).foregroundStyle(Theme.onColor)
        }
        .frame(maxWidth: .infinity, minHeight: 170)
        .background(RoundedRectangle(cornerRadius: 28).fill(color))
    }
}

struct RoundEndView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let stars: Int
    let sticker: String
    let onContinue: () -> Void
    @State private var pop = false

    var body: some View {
        VStack(spacing: 28) {
            Text(stars >= 4 ? "Amazing work!" : stars >= 2 ? "Well done!" : "Good effort — you're learning!")
                .font(Theme.font(48)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { k in Text("⭐").font(.system(size: 56)).opacity(k < stars ? 1 : 0.18) }
            }
            Text("You got a new sticker!").font(Theme.font(28, .semibold)).foregroundStyle(Theme.muted)
            Text(sticker).font(.system(size: 160))
                .scaleEffect(pop || reduceMotion ? 1 : 0.4).opacity(pop ? 1 : 0)
            Button("Continue ➜", action: onContinue).buttonStyle(BigButtonStyle())
        }
        .padding(40)
        .onAppear {
            withAnimation(reduceMotion ? .easeIn(duration: 0.3) : .spring(response: 0.6, dampingFraction: 0.75)) { pop = true }
            Speech.shared.say(stars >= 4 ? "Amazing work! You got a new sticker!" : "Well done! You got a new sticker!")
        }
    }
}

/// A short movement or eye break every two rounds. Break time doesn't count toward the daily limit.
struct BreakView: View {
    let eye: Bool
    let onDone: () -> Void
    @State private var item: (String, String)

    init(eye: Bool, onDone: @escaping () -> Void) {
        self.eye = eye; self.onDone = onDone
        _item = State(initialValue: (eye ? eyeBreaks : moveBreaks).any)
    }
    @State private var left = 20

    var body: some View {
        VStack(spacing: 30) {
            Text(eye ? "Eye break!" : "Brain break!").font(Theme.font(50)).foregroundStyle(Theme.ink)
            Text(item.0).font(.system(size: 150))
            Text(item.1).font(Theme.font(36, .semibold)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
            ZStack {
                Circle().stroke(Theme.line, lineWidth: 14)
                Circle().trim(from: 0, to: CGFloat(20 - left) / 20).stroke(Theme.good, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90)).animation(.linear(duration: 1), value: left)
                Text(left > 0 ? "\(left)" : "✓").font(Theme.font(40)).foregroundStyle(Theme.ink)
            }
            .frame(width: 120, height: 120)
            Button("I did it! ✅", action: onDone).buttonStyle(BigButtonStyle(color: Theme.good))
                .disabled(left > 0).opacity(left > 0 ? 0.4 : 1)
        }
        .padding(40)
        .task {
            Speech.shared.say((eye ? "Eye break! " : "Brain break! ") + item.1)
            while left > 0 { try? await Task.sleep(for: .seconds(1)); left -= 1 }
        }
    }
}

/// Shown once today's time is used up. Waits quietly; a grown-up can add minutes from HomeBuddy.
struct DoneForTodayView: View {
    @EnvironmentObject var store: KidStore
    let openGrownUps: () -> Void
    let onUnlocked: () -> Void

    var body: some View {
        VStack(spacing: 26) {
            Text("🌙").font(.system(size: 120))
            Text("All done for today, \(store.profile.name)!").font(Theme.font(46)).foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
            let t = store.today
            VStack(spacing: 8) {
                Text("Today's score").font(Theme.font(22)).foregroundStyle(Theme.muted)
                HStack(spacing: 26) {
                    scoreBit("⭐", "\(t.stars)", "stars")
                    scoreBit("✅", t.questions > 0 ? "\(t.correct)/\(t.questions)" : "–", "right first time")
                    scoreBit("📖", "\(t.stories)", t.stories == 1 ? "story" : "stories")
                    if t.spoken > 0 { scoreBit("🗣️", "\(t.spoken)", "spoken") }
                    scoreBit("🎁", "\(store.stickersToday)", "stickers")
                }
            }
            .padding(20).background(RoundedRectangle(cornerRadius: 24).fill(Theme.card))
            VStack(spacing: 10) {
                Text("Today's real-world mission").font(Theme.font(22)).foregroundStyle(Theme.onColor.opacity(0.9))
                Text(store.mission).font(Theme.font(32)).foregroundStyle(Theme.onColor).multilineTextAlignment(.center)
            }
            .padding(30).frame(maxWidth: 700)
            .background(RoundedRectangle(cornerRadius: 30).fill(Subject.evs.color))
            Text("Your brain grows when you play, run around and sleep too. See you tomorrow! 👋")
                .font(Theme.font(22, .medium)).foregroundStyle(Theme.ink).multilineTextAlignment(.center).frame(maxWidth: 640)
            Button("👪 Grown-ups", action: openGrownUps).font(Theme.font(18)).foregroundStyle(Theme.muted)
        }
        .padding(40)
        .task {
            Speech.shared.say("All done for today! Here is your real world mission. " + plain(store.mission))
            // A grown-up may add bonus minutes from HomeBuddy; check now and then.
            while !Task.isCancelled {
                await store.sync()
                if !store.isTimeUp { onUnlocked(); return }
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }
}

@MainActor private func scoreBit(_ icon: String, _ value: String, _ label: String) -> some View {
    VStack(spacing: 2) {
        Text("\(icon) \(value)").font(Theme.font(30)).foregroundStyle(Theme.ink)
        Text(label).font(Theme.font(15, .medium)).foregroundStyle(Theme.muted)
    }
}

struct StickerBookView: View {
    @EnvironmentObject var store: KidStore
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { onClose() } label: { Text("🏠").font(.system(size: 40)) }
                Spacer()
                Text("My Sticker Book").font(Theme.font(40)).foregroundStyle(Theme.ink)
                Spacer()
                Text("\(store.progress.stickers.count)").font(Theme.font(28)).foregroundStyle(Theme.muted)
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                    ForEach(Array(store.progress.stickers.enumerated()), id: \.offset) { _, s in
                        Text(s).font(.system(size: 64)).frame(width: 100, height: 100)
                            .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
                    }
                    ForEach(0..<3, id: \.self) { _ in
                        Text("?").font(Theme.font(40)).foregroundStyle(Theme.muted.opacity(0.5)).frame(width: 100, height: 100)
                            .background(RoundedRectangle(cornerRadius: 22).stroke(Theme.muted.opacity(0.3), style: StrokeStyle(lineWidth: 3, dash: [8, 6])))
                    }
                }
            }
            if store.progress.stickers.isEmpty {
                Text("Finish a round to get your first sticker!").font(Theme.font(24, .semibold)).foregroundStyle(Theme.muted)
            }
        }
        .padding(32)
    }
}
