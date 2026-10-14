import SwiftUI

/// Wraps word chips onto lines, like text.
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    var lineSpacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + lineSpacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width ?? rows.map(\.width).max() ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX + (bounds.width - row.width) / 2   // centred lines
            for i in row.items {
                let s = subviews[i].sizeThatFits(.unspecified)
                subviews[i].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
                x += s.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row { var items: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }
    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows = [Row()]
        for (i, v) in subviews.enumerated() {
            let s = v.sizeThatFits(.unspecified)
            if !rows[rows.count - 1].items.isEmpty && rows[rows.count - 1].width + spacing + s.width > width { rows.append(Row()) }
            var r = rows[rows.count - 1]
            r.width += (r.items.isEmpty ? 0 : spacing) + s.width
            r.height = max(r.height, s.height)
            r.items.append(i)
            rows[rows.count - 1] = r
        }
        return rows
    }
}

/// Words of a page with their character ranges, so spoken ranges can be matched to them.
private struct PageWord: Identifiable { let id: Int; let text: String; let range: NSRange }
private func pageWords(_ text: String) -> [PageWord] {
    var out: [PageWord] = []
    let ns = text as NSString
    var i = 0
    for chunk in text.split(separator: " ") {
        let r = ns.range(of: String(chunk), options: [], range: NSRange(location: i, length: ns.length - i))
        out.append(PageWord(id: out.count, text: String(chunk), range: r))
        i = r.location + r.length
    }
    return out
}

struct StoryShelfView: View {
    @EnvironmentObject var store: KidStore
    let onPick: (Story) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { onClose() } label: { Text("🏠").font(.system(size: 40)) }
                Spacer()
                Text("Story Time").font(Theme.font(42)).foregroundStyle(Theme.ink)
                Spacer()
                Text("📖").font(.system(size: 40))
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 20)], spacing: 20) {
                    ForEach(store.storyShelf) { s in
                        Button { onPick(s) } label: {
                            VStack(spacing: 12) {
                                Text(s.cover).font(.system(size: 80)).padding(10).background(Circle().fill(Theme.plate))
                                Text(s.title).font(Theme.font(24)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
                                    .lineLimit(2).minimumScaleFactor(0.7)
                                Text("\(s.pages.count) pages").font(Theme.font(16, .medium)).foregroundStyle(Theme.muted)
                            }
                            .padding(20).frame(maxWidth: .infinity, minHeight: 240)
                            .background(RoundedRectangle(cornerRadius: 28).fill(Theme.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(32)
    }
}

/// Read-along: the iPad reads each page and highlights each word; tap a word to hear it again.
/// With speaking practice on, "I'll read it!" lets the child read the page aloud and turns the words she says green.
struct StoryReaderView: View {
    @EnvironmentObject var store: KidStore
    @ObservedObject private var listener = Listener.shared
    let story: Story
    let onDone: () -> Void
    let onQuit: () -> Void

    @State private var page = 0
    @State private var spoken: NSRange?
    @State private var reading = false
    @State private var heard: [Bool] = []
    @State private var message = ""

    private var words: [PageWord] { pageWords(story.pages[page].text) }

    var body: some View {
        VStack(spacing: 22) {
            HStack {
                Button { onQuit() } label: { Text("🏠").font(.system(size: 40)) }
                Spacer()
                Text(story.title).font(Theme.font(28)).foregroundStyle(Theme.muted)
                Spacer()
                Text("\(page + 1) / \(story.pages.count)").font(Theme.font(24)).foregroundStyle(Theme.muted)
            }
            VStack(spacing: 30) {
                Spacer(minLength: 0)
                Text(story.pages[page].scene).font(.system(size: 140)).padding(30)
                    .background(Circle().fill(Theme.plate))
                FlowLayout(spacing: 14, lineSpacing: 16) {
                    ForEach(words) { w in
                        let now = spoken.map { NSIntersectionRange($0, w.range).length > 0 } ?? false
                        let said = heard.indices.contains(w.id) && heard[w.id]
                        Text(w.text).font(Theme.font(48))
                            .foregroundStyle(now ? Theme.onColor : said ? Theme.good : Theme.ink)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(RoundedRectangle(cornerRadius: 12).fill(now ? Subject.english.color : .clear))
                            .onTapGesture { Speech.shared.say(w.text.trimmingCharacters(in: .punctuationCharacters)) }
                    }
                }
                .padding(.horizontal, 20)
                Text(message).font(Theme.font(26, .semibold)).foregroundStyle(Theme.ink).frame(minHeight: 36)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 32).fill(Theme.card))

            HStack(spacing: 20) {
                Button("◀") { go(page - 1) }.buttonStyle(BigButtonStyle(color: Theme.deep))
                    .disabled(page == 0).opacity(page == 0 ? 0.35 : 1)
                Button("🔊 Read to me") { readPage() }.buttonStyle(BigButtonStyle(color: Subject.english.color))
                if store.speakingOn {
                    Button(listener.listening ? "👂 Listening…" : "🎤 I'll read it!") { readMyself() }
                        .buttonStyle(BigButtonStyle(color: Theme.accent)).disabled(listener.listening)
                }
                if page + 1 < story.pages.count {
                    Button("▶") { go(page + 1) }.buttonStyle(BigButtonStyle(color: Theme.deep))
                } else {
                    Button("Questions ▶") { Speech.shared.stop(); onDone() }.buttonStyle(BigButtonStyle(color: Theme.good))
                }
            }
        }
        .padding(24)
        .task(id: page) { readPage() }
        .onDisappear { Speech.shared.stop(); listener.cancel() }
    }

    private func go(_ p: Int) {
        guard story.pages.indices.contains(p) else { return }
        listener.cancel()
        page = p; heard = []; message = ""; spoken = nil
    }

    private func readPage() {
        listener.cancel()
        Speech.shared.readAlong(story.pages[page].text,
                                onWord: { spoken = $0 },
                                onFinish: { spoken = nil })
    }

    private func readMyself() {
        Speech.shared.stop(); spoken = nil
        message = "Read the words out loud…"
        let text = story.pages[page].text
        listener.start(hints: SpeakMatch.words(text), maxSeconds: 10) { said in
            let target = SpeakMatch.words(text).joined(separator: " ")
            let marks = SpeakMatch.matches(target: target, heard: said)
            // Map matches back onto the on-screen words (same order; punctuation-only chunks have no word).
            var k = 0
            heard = words.map { w in
                guard !SpeakMatch.words(w.text).isEmpty, k < marks.count else { return false }
                defer { k += 1 }; return marks[k]
            }
            let share = marks.isEmpty ? 0 : Double(marks.filter { $0 }.count) / Double(marks.count)
            if share >= 0.7 {
                message = "⭐ Great reading!"; Chime.shared.play(correct: true); Speech.shared.say("Great reading!")
                var d = store.today; d.spoken += 1; store.today = d; store.save()
            } else {
                message = said.isEmpty ? "I didn't hear you. Try again, nice and loud! 🎤" : "Good try! Tap 🔊 to listen, then read again."
            }
        }
    }
}
