import AuthenticationServices
import SwiftUI

/// A sum young children can't do yet keeps them out of the grown-up area.
struct ParentGateView: View {
    let onPass: () -> Void
    let onCancel: () -> Void
    @State private var a = rnd(6, 9)
    @State private var b = rnd(6, 9)
    @State private var entry = ""
    @State private var wrong = false

    var body: some View {
        VStack(spacing: 22) {
            Text("For grown-ups").font(Theme.font(34)).foregroundStyle(Theme.ink)
            Text("What is \(a) × \(b)?").font(Theme.font(30, .semibold)).foregroundStyle(Theme.ink)
            Text(entry.isEmpty ? " " : entry).font(Theme.font(48)).frame(width: 200, height: 70)
                .background(RoundedRectangle(cornerRadius: 16).fill(wrong ? Theme.soft.opacity(0.15) : Theme.card))
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(90), spacing: 12), count: 3), spacing: 12) {
                ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "⌫", "0", "OK"], id: \.self) { k in
                    Button { press(k) } label: {
                        Text(k).font(Theme.font(30)).foregroundStyle(Theme.ink).frame(width: 90, height: 70)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    }.buttonStyle(.plain)
                }
            }
            Button("Cancel", action: onCancel).font(Theme.font(20)).foregroundStyle(Theme.muted)
        }
        .padding(40)
    }

    private func press(_ k: String) {
        wrong = false
        switch k {
        case "⌫": entry = String(entry.dropLast())
        case "OK":
            if Int(entry) == a * b { onPass() } else { wrong = true; entry = ""; a = rnd(6, 9); b = rnd(6, 9) }
        default: if entry.count < 3 { entry += k }
        }
    }
}

struct ParentView: View {
    @EnvironmentObject var store: KidStore
    @EnvironmentObject var auth: AuthStore
    let onClose: () -> Void
    let onSwitchChild: () -> Void
    @State private var syncing = false
    @State private var soundOn = Speech.shared.enabled
    @AppStorage("eye_mode") private var eyeMode = EyeMode.auto.rawValue
    @AppStorage("speaking_on") private var speakingOn = false
    @AppStorage("speech_online") private var speechOnline = false
    @ObservedObject private var listener = Listener.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Today") {
                    LabeledContent("Child", value: "\(store.profile.name) · \(store.profile.grade == "C1" ? "Class 1" : "UKG")")
                    LabeledContent("Time used", value: "\(store.today.secs / 60) of \(store.limitSecs / 60) min")
                    LabeledContent("Rounds", value: "\(store.today.rounds)  (adventure \(store.today.adventure)/\(store.profile.plan_rounds))")
                    LabeledContent("First-try correct", value: "\(store.today.correct) of \(store.today.questions)")
                }
                Section {
                    Text("Change the daily limit, class, rounds per day and languages, or add bonus minutes, from **HomeBuddy → Today → Kids**. The iPad picks up changes when you tap Sync.")
                        .font(.callout)
                    Button(syncing ? "Syncing…" : "Sync now") {
                        syncing = true
                        Task { await store.sync(); syncing = false }
                    }
                    if let e = store.syncError { Text("Last sync failed: \(e)").font(.footnote).foregroundStyle(.red) }
                } header: { Text("Settings") }
                Section {
                    Picker("Colours", selection: $eyeMode) {
                        Text("Auto (warm after 6 pm)").tag(EyeMode.auto.rawValue)
                        Text("Always daytime").tag(EyeMode.day.rawValue)
                        Text("Always warm & dim").tag(EyeMode.evening.rawValue)
                    }
                    .onChange(of: eyeMode) { _, _ in Palette.shared.refresh() }
                    Text("Built in: soft low-glare colours, an eye break (look far away) at least every 8 minutes, and a reminder to hold the iPad at arm's length. On the iPad, also turn on **Settings → Screen Time → Screen Distance** (warns if the iPad is held too close) and **Display & Brightness → Night Shift**, and keep brightness similar to the room.")
                        .font(.footnote).foregroundStyle(.secondary)
                } header: { Text("Eye comfort") }
                Section {
                    Toggle("Speaking practice", isOn: $speakingOn)
                        .onChange(of: speakingOn) { _, on in if on { Task { await listener.requestPermission() } } }
                    if speakingOn {
                        switch listener.status {
                        case .ready:
                            Label(listener.onDevice ? "Ready — speech is recognised on this iPad only" : "Ready — using Apple's online recognition",
                                  systemImage: "checkmark.circle").foregroundStyle(.green)
                        case .denied:
                            Text("Microphone or Speech Recognition is turned off. Allow both for Little Explorers in iPad **Settings → Privacy & Security**.")
                                .font(.footnote).foregroundStyle(.orange)
                        case .unsupported:
                            Text("This iPad can't recognise English speech offline. You can allow Apple's online recognition below (audio is sent to Apple to be turned into text).")
                                .font(.footnote).foregroundStyle(.orange)
                        case .notAsked:
                            Button("Allow microphone") { Task { await listener.requestPermission() } }
                        }
                        Toggle("Allow online recognition if needed", isOn: $speechOnline)
                            .onChange(of: speechOnline) { _, _ in listener.refresh() }
                    }
                    Text("Adds a 🗣️ Speaking tile (say the word, repeat after me, answer aloud) and lets her read story pages aloud. Nothing is recorded or kept.")
                        .font(.footnote).foregroundStyle(.secondary)
                } header: { Text("English speaking") }
                Section("Voices") {
                    Toggle("Read questions aloud", isOn: $soundOn).onChange(of: soundOn) { _, v in Speech.shared.enabled = v }
                    ForEach([("English (India)", "en"), ("Telugu", "te"), ("Hindi", "hi")], id: \.1) { name, code in
                        LabeledContent(name, value: Speech.shared.hasVoice(code) ? "Installed ✓" : "Not installed")
                    }
                    if !Speech.shared.hasVoice("te") || !Speech.shared.hasVoice("hi") {
                        Text("Missing voices can be added in iPad Settings → Accessibility → Spoken Content → Voices. Without one, the app shows the English spelling (romanisation) instead.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Section("Account") {
                    LabeledContent("Signed in as", value: auth.session?.email ?? "")
                    Button("Switch child", action: onSwitchChild)
                    Button("Sign out", role: .destructive) { auth.signOut() }
                }
            }
            .navigationTitle("Grown-ups")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done", action: onClose) } }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var auth: AuthStore
    @State private var showCode = false
    @State private var code = ""

    var body: some View {
        VStack(spacing: 28) {
            Text("🦉").font(.system(size: 140))
            Text("Little Explorers").font(Theme.font(56)).foregroundStyle(Theme.ink)
            Text("Grown-ups: sign in once with your HomeBuddy account.\nYour child won't need to sign in again.")
                .font(Theme.font(22, .medium)).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
            SignInWithAppleButton(.signIn) { $0.requestedScopes = [.fullName, .email] }
                onCompletion: { r in Task { await auth.signInWithApple(r) } }
                .signInWithAppleButtonStyle(Theme.evening ? .white : .black).frame(width: 320, height: 56)
            if showCode {
                HStack {
                    SecureField("Access code", text: $code).textFieldStyle(.roundedBorder).frame(width: 220)
                    Button("Go") { Task { await auth.signIn(code: code) } }.buttonStyle(.borderedProminent)
                }
            } else {
                Button("Have an access code?") { showCode = true }.foregroundStyle(Theme.muted)
            }
            if let e = auth.error { Text(e).foregroundStyle(.red).multilineTextAlignment(.center) }
        }
        .padding(40)
    }
}

/// Picks (or, the first time, creates) the child profile this iPad is for.
struct ProfilePickerView: View {
    let onPick: (KidProfile) -> Void
    @EnvironmentObject var auth: AuthStore
    @State private var profiles: [KidProfile]?
    @State private var name = ""
    @State private var grade = "UKG"
    @State private var error: String?
    @State private var busy = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Who is learning on this iPad?").font(Theme.font(40)).foregroundStyle(Theme.ink)
            if let profiles {
                ForEach(profiles) { p in
                    Button { onPick(p) } label: {
                        Text("\(p.name) · \(p.grade == "C1" ? "Class 1" : "UKG")").font(Theme.font(30)).foregroundStyle(Theme.onColor)
                            .frame(width: 420, height: 80).background(RoundedRectangle(cornerRadius: 24).fill(Subject.english.color))
                    }.buttonStyle(.plain)
                }
                VStack(spacing: 14) {
                    Text(profiles.isEmpty ? "Add your child" : "Or add another child").font(Theme.font(22, .semibold)).foregroundStyle(Theme.muted)
                    TextField("Child's name", text: $name).textFieldStyle(.roundedBorder).font(.title2).frame(width: 360)
                    Picker("Class", selection: $grade) { Text("UKG").tag("UKG"); Text("Class 1").tag("C1") }
                        .pickerStyle(.segmented).frame(width: 360)
                    Button(busy ? "Adding…" : "Add") { Task { await create() } }
                        .buttonStyle(BigButtonStyle()).disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || busy)
                }
                .padding(.top, 20)
            } else {
                ProgressView().scaleEffect(1.5)
            }
            if let error { Text(error).foregroundStyle(.red) }
            Button("Sign out") { auth.signOut() }.foregroundStyle(Theme.muted).padding(.top, 20)
        }
        .padding(40)
        .task { await load() }
    }

    private func load() async {
        do { profiles = try await APIClient.shared.profiles(); error = nil }
        catch { self.error = error.localizedDescription; profiles = profiles ?? [] }
    }

    private func create() async {
        busy = true; defer { busy = false }
        do { onPick(try await APIClient.shared.createProfile(name: name.trimmingCharacters(in: .whitespaces), grade: grade)) }
        catch { self.error = error.localizedDescription }
    }
}
