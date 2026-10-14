import SwiftUI

private let praise = ["Great job!", "Super!", "You got it!", "Well done!", "Wonderful!", "Brilliant!", "Yay!"]

/// One round of five questions. No timers, no penalties: two tries, then we show the answer kindly.
struct QuizView: View {
    @EnvironmentObject var store: KidStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let mode: RoundMode
    let onFinish: (Int) -> Void
    let onQuit: () -> Void

    @State private var questions: [Question] = []
    @State private var i = 0
    @State private var tries = 0
    @State private var wrong: Set<String> = []
    @State private var solved: String?
    @State private var revealed = false
    @State private var stars = 0
    @State private var results: [Bool] = []
    @State private var feedback = ""
    @State private var shake: CGFloat = 0
    @State private var levelUp = false

    private var q: Question? { questions.indices.contains(i) ? questions[i] : nil }
    private var tint: Color {
        if case .subject(let s) = mode { return s.color }
        return q.flatMap { skillById[$0.skill]?.subject.color } ?? Theme.ink
    }

    var body: some View {
        VStack(spacing: 18) {
            topBar
            if let q {
                card(q)
                options(q)
                feedbackRow
            }
        }
        .padding(24)
        .onAppear { if questions.isEmpty { questions = store.buildRound(mode) } }
        .task(id: questions.isEmpty ? -1 : i) { if q != nil { speakQuestion() } }
        .onDisappear { Speech.shared.stop() }
    }

    private var topBar: some View {
        HStack {
            Button { onQuit() } label: { Text("🏠").font(.system(size: 40)) }
                .accessibilityLabel("Home")
            Spacer()
            HStack(spacing: 10) {
                ForEach(0..<max(questions.count, 1), id: \.self) { k in
                    Circle()
                        .fill(k < results.count ? (results[k] ? Theme.good : Theme.accent.opacity(0.6))
                              : k == i ? tint : Theme.line)
                        .frame(width: k == i ? 24 : 18, height: k == i ? 24 : 18)
                }
            }
            Spacer()
            Button { speakQuestion() } label: { Text("🔊").font(.system(size: 40)) }
                .accessibilityLabel("Listen again")
        }
    }

    private func card(_ q: Question) -> some View {
        VStack(spacing: 16) {
            if let def = skillById[q.skill] {
                Text("\(def.subject.emoji)  \(def.name)").font(Theme.font(18, .semibold)).foregroundStyle(Theme.onColor)
                    .padding(.horizontal, 14).padding(.vertical, 6).background(Capsule().fill(def.subject.color))
            }
            Text(q.prompt).font(Theme.font(q.prompt.count > 60 ? 30 : 40)).foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center).minimumScaleFactor(0.6)
            VisualView(visual: q.visual)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 32).fill(Theme.card))
        .onTapGesture { speakQuestion() }
    }

    private func options(_ q: Question) -> some View {
        let cols = q.options.count == 4 ? 4 : q.options.count
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: cols), spacing: 18) {
            ForEach(q.options) { o in
                let isRight = solved == o.id || (revealed && o.id == q.answer)
                let isWrong = wrong.contains(o.id)
                Button { tap(o, in: q) } label: {
                    OptionFaceView(face: o.face)
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(RoundedRectangle(cornerRadius: 26)
                            .fill(isRight ? Theme.good.opacity(0.2) : Theme.card))
                        .overlay(RoundedRectangle(cornerRadius: 26)
                            .stroke(isRight ? Theme.good : tint.opacity(0.35), lineWidth: isRight ? 6 : 3))
                        .opacity(isWrong ? 0.35 : 1)
                        .scaleEffect(isRight && !reduceMotion ? 1.04 : 1)
                }
                .buttonStyle(.plain)
                .disabled(isWrong || solved != nil || revealed)
                .modifier(Shake(animatableData: isWrong ? shake : 0))
            }
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: solved)
    }

    private var feedbackRow: some View {
        HStack(spacing: 20) {
            Text(feedback).font(Theme.font(28, .semibold)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
            if revealed {
                Button("Next ➜") { advance() }.buttonStyle(BigButtonStyle(color: tint))
            }
        }
        .frame(minHeight: 80)
    }

    private func speakQuestion() {
        guard let q else { return }
        var parts = q.say
        if q.readOptions {
            let spoken = q.options.compactMap(\.spoken)
            for (k, s) in spoken.enumerated() {
                parts.append(k == spoken.count - 1 && spoken.count > 1 ? .en("or") : .en(""))
                parts.append(s)
            }
        }
        Speech.shared.say(parts)
    }

    private func tap(_ o: Option, in q: Question) {
        if o.id == q.answer {
            let firstTry = tries == 0
            solved = o.id
            if firstTry { stars += 1 }
            results.append(firstTry)
            levelUp = store.record(q, firstTry: firstTry)
            let p = levelUp ? "Level up! 🚀" : praise.any
            feedback = (firstTry ? "⭐ " : "") + p
            Chime.shared.play(correct: true)
            Speech.shared.say(p)
            Task { try? await Task.sleep(for: .seconds(1.6)); advance() }
        } else {
            wrong.insert(o.id)
            tries += 1
            Chime.shared.play(correct: false)
            if !reduceMotion { withAnimation(.easeInOut(duration: 0.35)) { shake += 1 } }
            let remaining = q.options.count - wrong.count
            if tries >= 2 || remaining <= 1 {
                revealed = true
                results.append(false)
                store.record(q, firstTry: false)
                feedback = q.explain
                Speech.shared.say("Good try! " + q.explain)
            } else {
                feedback = "Almost! Try again 💪"
                Speech.shared.say("Almost! Try again.")
            }
        }
    }

    private func advance() {
        guard solved != nil || revealed else { return }
        if i + 1 >= questions.count { onFinish(stars); return }
        i += 1; tries = 0; wrong = []; solved = nil; revealed = false; feedback = ""; levelUp = false
    }
}
