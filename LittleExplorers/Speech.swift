import AVFoundation

/// Reads questions aloud so children who can't read yet can still play. Uses Indian English, Telugu and Hindi voices
/// when the iPad has them; a language with no voice is simply skipped (the romanisation is on screen instead).
@MainActor
final class Speech {
    static let shared = Speech()
    private let synth = AVSpeechSynthesizer()
    var enabled = true

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
    }

    private func voice(for lang: String) -> AVSpeechSynthesisVoice? {
        let prefs: [String] = switch lang {
        case "te": ["te-IN"]
        case "hi": ["hi-IN"]
        default: ["en-IN", "en-GB", "en-US"]
        }
        let all = AVSpeechSynthesisVoice.speechVoices()
        for p in prefs {
            let matches = all.filter { $0.language == p }
            if let best = matches.max(by: { $0.quality.rawValue < $1.quality.rawValue }) { return best }
        }
        return nil
    }

    func hasVoice(_ lang: String) -> Bool { voice(for: lang) != nil }

    func say(_ parts: [Utter]) {
        guard enabled else { return }
        synth.stopSpeaking(at: .immediate)
        for p in parts where !p.text.isEmpty {
            guard let v = voice(for: p.lang) else { continue }
            let u = AVSpeechUtterance(string: p.text)
            u.voice = v
            u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
            u.pitchMultiplier = 1.1
            u.postUtteranceDelay = 0.15
            synth.speak(u)
        }
    }

    func say(_ text: String) { say([.en(text)]) }
    func stop() { synth.stopSpeaking(at: .immediate) }
}

/// Soft two-note chime for right answers and a low, gentle tone for wrong ones — no harsh buzzers.
@MainActor
final class Chime {
    static let shared = Chime()
    private var players: [AVAudioPlayer] = []
    private lazy var good = wav([523.25, 783.99])
    private lazy var soft = wav([261.63])

    func play(correct: Bool) {
        guard Speech.shared.enabled, let p = try? AVAudioPlayer(data: correct ? good : soft) else { return }
        p.volume = 0.5
        players.removeAll { !$0.isPlaying }
        players.append(p)
        p.play()
    }

    private func wav(_ notes: [Double]) -> Data {
        let rate = 44_100, noteLen = 0.16
        var samples: [Int16] = []
        for f in notes {
            let n = Int(Double(rate) * noteLen)
            for i in 0..<n {
                let t = Double(i) / Double(rate)
                let env = min(1, t * 60) * exp(-t * 9)
                samples.append(Int16(sin(2 * .pi * f * t) * env * 12_000))
            }
        }
        var d = Data()
        func put<T>(_ v: T) { withUnsafeBytes(of: v) { d.append(contentsOf: $0) } }
        let bytes = samples.count * 2
        d.append(contentsOf: Array("RIFF".utf8)); put(UInt32(36 + bytes).littleEndian)
        d.append(contentsOf: Array("WAVEfmt ".utf8)); put(UInt32(16).littleEndian); put(UInt16(1).littleEndian)
        put(UInt16(1).littleEndian); put(UInt32(rate).littleEndian); put(UInt32(rate * 2).littleEndian)
        put(UInt16(2).littleEndian); put(UInt16(16).littleEndian)
        d.append(contentsOf: Array("data".utf8)); put(UInt32(bytes).littleEndian)
        samples.forEach { put($0.littleEndian) }
        return d
    }
}
