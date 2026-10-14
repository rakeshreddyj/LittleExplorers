import AVFoundation
import Speech

/// Listens to the child speak and turns it into text. Uses on-device recognition only, so the child's voice never
/// leaves the iPad, unless a grown-up allows Apple's online recognition for an iPad that can't do it offline.
@MainActor
final class Listener: ObservableObject {
    static let shared = Listener()

    enum Status: Equatable { case notAsked, denied, unsupported, ready }

    @Published private(set) var status: Status = .notAsked
    @Published private(set) var listening = false
    @Published private(set) var transcript = ""

    var ready: Bool { status == .ready }
    var onDevice: Bool { recognizer?.supportsOnDeviceRecognition ?? false }

    private let engine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var onDone: ((String) -> Void)?
    private var lastChange = Date()
    private var startedAt = Date()

    private var allowOnline: Bool { UserDefaults.standard.bool(forKey: "speech_online") }

    private init() { refresh() }

    /// Indian English first, then other English voices; must work offline unless online is allowed.
    private func pickRecognizer() -> SFSpeechRecognizer? {
        for id in ["en-IN", "en-US", "en-GB"] {
            if let r = SFSpeechRecognizer(locale: Locale(identifier: id)), r.isAvailable,
               r.supportsOnDeviceRecognition || allowOnline { return r }
        }
        return nil
    }

    func refresh() {
        let speech = SFSpeechRecognizer.authorizationStatus()
        let mic = AVAudioApplication.shared.recordPermission
        if speech == .denied || speech == .restricted || mic == .denied { status = .denied; return }
        if speech != .authorized || mic != .granted { status = .notAsked; return }
        recognizer = pickRecognizer()
        status = recognizer == nil ? .unsupported : .ready
    }

    /// Asked from the grown-up screen, so the system prompts appear for the parent, not the child.
    func requestPermission() async {
        _ = await withCheckedContinuation { (c: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { c.resume(returning: $0) }
        }
        _ = await AVAudioApplication.requestRecordPermission()
        refresh()
    }

    /// Starts listening. Stops by itself after a short pause once something was heard, or after `maxSeconds`.
    func start(hints: [String], maxSeconds: Double = 7, onDone: @escaping (String) -> Void) {
        guard ready, let recognizer, !listening else { return }
        Speech.shared.stop()
        transcript = ""
        self.onDone = onDone
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch { finish(); return }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        req.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        req.contextualStrings = hints
        req.addsPunctuation = false
        request = req

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in req.append(buffer) }
        engine.prepare()
        do { try engine.start() } catch { finish(); return }

        listening = true
        startedAt = Date(); lastChange = Date()
        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            Task { @MainActor in
                guard let self, self.listening else { return }
                if let result {
                    let text = result.bestTranscription.formattedString
                    if text != self.transcript { self.transcript = text; self.lastChange = Date() }
                    if result.isFinal { self.finish() }
                } else if error != nil {
                    self.finish()
                }
            }
        }
        Task { [weak self] in
            while let self, self.listening {
                try? await Task.sleep(for: .milliseconds(200))
                let quiet = Date().timeIntervalSince(self.lastChange)
                let total = Date().timeIntervalSince(self.startedAt)
                if (!self.transcript.isEmpty && quiet > 1.4) || total > maxSeconds { self.finish() }
            }
        }
    }

    func cancel() { onDone = nil; finish() }
    func reset() { cancel(); transcript = "" }

    private func finish() {
        guard listening || task != nil || engine.isRunning else { onDone?(transcript); onDone = nil; return }
        listening = false
        if engine.isRunning { engine.stop() }
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil; request = nil
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
        let done = onDone; onDone = nil
        done?(transcript)
    }
}
