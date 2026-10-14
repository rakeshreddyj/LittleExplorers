import Combine
import SwiftUI

@main
struct LittleExplorersApp: App {
    @StateObject private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var auth: AuthStore
    @ObservedObject private var palette = Palette.shared
    @State private var store: KidStore?

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            if auth.session == nil {
                SignInView().id(palette.evening)
            } else if let store {
                KidRootView(onSwitchChild: { choose(nil) }).environmentObject(store)
                    .id(store.profile.id)
            } else {
                ProfilePickerView { choose($0) }.id(palette.evening)
            }
        }
        .preferredColorScheme(palette.evening ? .dark : .light)
        .animation(.easeInOut(duration: 0.6), value: palette.evening)
        .onAppear {
            palette.refresh()
            if store == nil, auth.session != nil, let p = cachedProfile(),
               UserDefaults.standard.integer(forKey: "profile_id") == p.id { store = KidStore(profile: p) }
        }
        .onChange(of: auth.session == nil) { _, signedOut in if signedOut { store = nil } }
    }

    private func choose(_ p: KidProfile?) {
        guard let p else { UserDefaults.standard.removeObject(forKey: "profile_id"); store = nil; return }
        UserDefaults.standard.set(p.id, forKey: "profile_id")
        cacheProfile(p)
        store = KidStore(profile: p)
    }
}

enum Screen: Equatable {
    case home, quiz(RoundMode, Int), roundEnd(stars: Int, sticker: String, mode: RoundMode), brainBreak(eye: Bool), done, stickers
}

struct KidRootView: View {
    @EnvironmentObject var store: KidStore
    @Environment(\.scenePhase) private var phase
    @ObservedObject private var palette = Palette.shared
    let onSwitchChild: () -> Void
    @State private var screen: Screen = .home
    @State private var gate = false
    @State private var parent = false
    @State private var roundCounter = 0
    private let clock = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            switch screen {
            case .home:
                HomeView(start: begin, openStickers: { screen = .stickers }, openGrownUps: { gate = true })
            case .quiz(let mode, _):
                QuizView(mode: mode,
                         onFinish: { stars in
                             let sticker = store.finishRound(mode: mode, stars: stars)
                             screen = .roundEnd(stars: stars, sticker: sticker, mode: mode)
                         },
                         onQuit: { screen = .home })
            case .roundEnd(let stars, let sticker, _):
                RoundEndView(stars: stars, sticker: sticker) {
                    if store.isTimeUp { screen = .done }
                    else if store.eyeBreakDue { screen = .brainBreak(eye: true) }
                    // Every second round: alternate movement and eye breaks.
                    else if store.today.rounds.isMultiple(of: 2) { screen = .brainBreak(eye: store.today.rounds.isMultiple(of: 4)) }
                    else { screen = .home }
                }
            case .brainBreak(let eye):
                BreakView(eye: eye) { if eye { store.tookEyeBreak() }; screen = .home }
            case .done:
                DoneForTodayView(openGrownUps: { gate = true }, onUnlocked: { screen = .home })
            case .stickers:
                StickerBookView { screen = .home }
            }
        }
        .id(palette.evening)   // only flips between rounds, see below
        .animation(.easeInOut(duration: 0.25), value: screen)
        .onAppear {
            if store.isTimeUp { screen = .done }
            #if DEBUG
            if !(ProcessInfo.processInfo.environment["LE_SKILL"] ?? "").isEmpty { screen = .quiz(.adventure, 0) }
            #endif
            Task { await store.sync() }
        }
        .onReceive(clock) { _ in
            guard phase == .active, !gate, !parent else { return }
            if case .quiz = screen {} else { palette.refresh() }   // never switch palette mid-question
            switch screen {
            case .home, .quiz, .roundEnd, .stickers:
                store.tick(5)
                // Never cut a round off mid-way; the limit is checked between rounds.
                if store.isTimeUp, screen == .home || screen == .stickers { screen = .done }
            default: break
            }
        }
        .onChange(of: phase) { _, p in
            if p == .active { Task { await store.sync(); if store.isTimeUp && screen == .home { screen = .done } } }
            if p == .background { store.save() }
        }
        .sheet(isPresented: $gate) {
            ParentGateView(onPass: { gate = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { parent = true } },
                           onCancel: { gate = false })
        }
        .sheet(isPresented: $parent, onDismiss: {
            if screen == .done && !store.isTimeUp { screen = .home }
        }) {
            ParentView(onClose: { parent = false }, onSwitchChild: { parent = false; onSwitchChild() })
                .environmentObject(store)
        }
    }

    private func begin(_ mode: RoundMode) {
        if store.isTimeUp { screen = .done; return }
        roundCounter += 1
        screen = .quiz(mode, roundCounter)
    }
}
