import AVFoundation
import Combine
import SwiftUI
import UIKit

/// A value description lets voice selection be tested without speech hardware or downloads.
struct NarrationVoiceDescriptor: Identifiable, Equatable {
    enum Gender { case female, male, unspecified }
    let id: String
    let name: String
    let language: String
    /// AVSpeechSynthesisVoiceQuality raw value: standard 1, enhanced 2, premium 3.
    let quality: Int
    let gender: Gender
    var isNovelty = false
    var isPersonal = false

    var qualityLabel: String {
        switch quality {
        case 3...: "Highest quality"
        case 2: "High quality"
        default: "Standard quality"
        }
    }
}

/// Ranks actual available voices; no identifier here implies a voice has been downloaded.
enum NarrationVoiceSelection {
    private static let noveltyNames: Set<String> = [
        "albert", "bad news", "bahh", "bells", "boing", "bubbles", "cellos",
        "fred", "good news", "jester", "organ", "ralph", "superstar",
        "trinoids", "whisper", "wobble", "zarvox"
    ]

    static func isSuitable(_ voice: NarrationVoiceDescriptor) -> Bool {
        let language = voice.language.replacingOccurrences(of: "_", with: "-").lowercased()
        let baseName = voice.name.split(separator: "(", maxSplits: 1).first.map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return (language == "en" || language.hasPrefix("en-"))
            && !voice.isNovelty && !voice.isPersonal && !noveltyNames.contains(baseName)
    }

    static func ranked(_ voices: [NarrationVoiceDescriptor]) -> [NarrationVoiceDescriptor] {
        voices.filter { isSuitable($0) }.sorted { left, right in
            let leftScore = score(left)
            let rightScore = score(right)
            if leftScore != rightScore { return leftScore > rightScore }
            // A stable tie-breaker prevents the selected automatic voice from changing
            // just because the system returns the same installed voices in a new order.
            return left.id < right.id
        }
    }

    static func selectedIdentifier(in voices: [NarrationVoiceDescriptor], preferredIdentifier: String) -> String? {
        let suitable = ranked(voices)
        if suitable.contains(where: { $0.id == preferredIdentifier }) { return preferredIdentifier }
        return suitable.first?.id
    }

    private static func score(_ voice: NarrationVoiceDescriptor) -> Int {
        let language = voice.language.replacingOccurrences(of: "_", with: "-").lowercased()
        let americanEnglish = language == "en-us" ? 100 : 0
        let quality = min(3, max(1, voice.quality)) * 1_000
        let warmFemalePreference = voice.gender == .female ? 30 : voice.gender == .unspecified ? 10 : 0
        return americanEnglish + quality + warmFemalePreference
    }
}

@MainActor
enum NarrationVoice {
    static let preferenceKey = "parents.narrationVoiceIdentifier"
    static let previewText = "Hi, friend! Let's look together. Can you find the little duck? There it is! You found it."

    static func installedVoices() -> [AVSpeechSynthesisVoice] {
        // Use installed Apple voices, without third-party speech-provider extensions.
        // voiceWithIdentifier returns nil for a voice that isn't downloaded.
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.identifier.hasPrefix("com.apple.") }
            .compactMap { AVSpeechSynthesisVoice(identifier: $0.identifier) }
    }

    static func descriptor(for voice: AVSpeechSynthesisVoice) -> NarrationVoiceDescriptor {
        let gender: NarrationVoiceDescriptor.Gender
        switch voice.gender {
        case .female: gender = .female
        case .male: gender = .male
        default: gender = .unspecified
        }
        return NarrationVoiceDescriptor(
            id: voice.identifier, name: voice.name, language: voice.language,
            quality: voice.quality.rawValue, gender: gender,
            isNovelty: voice.voiceTraits.contains(.isNoveltyVoice),
            isPersonal: voice.voiceTraits.contains(.isPersonalVoice)
        )
    }

    static func availableChoices() -> [NarrationVoiceDescriptor] {
        NarrationVoiceSelection.ranked(installedVoices().map(descriptor))
    }

    @discardableResult
    static func configure(_ utterance: AVSpeechUtterance, preferredIdentifier: String? = nil) -> Bool {
        let preferred = preferredIdentifier ?? UserDefaults.standard.string(forKey: preferenceKey) ?? ""
        let voices = installedVoices()
        let selected = NarrationVoiceSelection.selectedIdentifier(in: voices.map(descriptor), preferredIdentifier: preferred)
        guard let voice = voices.first(where: { $0.identifier == selected }) else { return false }
        utterance.voice = voice
        // A slightly relaxed conversational pace and small pitch lift preserve the
        // installed voice's natural character. This is not an imitation of a person.
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.035
        utterance.volume = 1
        utterance.preUtteranceDelay = 0.08
        utterance.postUtteranceDelay = 0.12
        return true
    }
}

/// A Form section for Parents Corner. Selecting a voice never enables game narration.
struct NarrationVoiceSettings: View {
    @AppStorage(NarrationVoice.preferenceKey) private var preferredIdentifier = ""
    @State private var voices: [NarrationVoiceDescriptor] = []
    @StateObject private var preview = NarrationVoicePreview()
    @Environment(\.scenePhase) private var scenePhase

    private var selected: NarrationVoiceDescriptor? {
        let id = NarrationVoiceSelection.selectedIdentifier(in: voices, preferredIdentifier: preferredIdentifier)
        return voices.first(where: { $0.id == id })
    }

    private var pickerSelection: Binding<String> {
        Binding(
            get: { voices.contains(where: { $0.id == preferredIdentifier }) ? preferredIdentifier : "" },
            set: { preferredIdentifier = $0 }
        )
    }

    var body: some View {
        Section("A friendly learning voice") {
            Picker("Narrator", selection: pickerSelection) {
                Text("Automatic · best available").tag("")
                ForEach(voices) { voice in
                    Text("\(voice.name) · \(voice.qualityLabel) · \(Locale.current.localizedString(forIdentifier: voice.language) ?? voice.language)")
                        .tag(voice.id)
                }
            }
            if let selected {
                Text("Using \(selected.name) · \(selected.qualityLabel.lowercased())")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                Text("No English voice is currently available. Add an English voice in your device's Accessibility speech settings.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            Button {
                if preview.isSpeaking { preview.stop() }
                else { preview.play(identifier: preferredIdentifier) }
            } label: {
                Label(preview.isSpeaking ? "Stop voice preview" : "Hear a friendly sample",
                      systemImage: preview.isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                    .frame(minHeight: 56)
            }
            .disabled(voices.isEmpty)
            .accessibilityHint("Plays a short sample, even when spoken game directions are turned off")

            if let message = preview.message {
                Text(message).font(.footnote).foregroundStyle(.secondary)
            }
            if !preferredIdentifier.isEmpty && !voices.contains(where: { $0.id == preferredIdentifier }) {
                Text("Your previous voice is unavailable, so we're using the best available voice.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Text("Warm, clear speech with a gentle pace. Only Apple voices available on this device appear here. For more natural speech, add an Enhanced or Premium English voice in your device's Accessibility speech settings. Once installed, narration works offline.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .onAppear(perform: refresh)
        .onChange(of: preferredIdentifier) { _, _ in preview.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() } else { preview.stop() }
        }
        .onReceive(NotificationCenter.default.publisher(for: AVSpeechSynthesizer.availableVoicesDidChangeNotification)) { _ in
            preview.stop()
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)) { _ in
            if UIAccessibility.isVoiceOverRunning { preview.stop() }
        }
        .onDisappear { preview.stop() }
    }

    private func refresh() { voices = NarrationVoice.availableChoices() }
}

/// Preview is an explicit parent action. It bypasses only the game-mute preference.
@MainActor
private final class NarrationVoicePreview: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking = false
    @Published private(set) var message: String?
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: ObjectIdentifier?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func play(identifier: String) {
        stop()
        message = nil
        guard !UIAccessibility.isVoiceOverRunning else {
            message = "VoiceOver is on. Narration stays quiet while VoiceOver reads the controls."
            return
        }
        guard UIApplication.shared.applicationState == .active, !SessionTimerManager.shared.isLocked else { return }
        let utterance = AVSpeechUtterance(string: NarrationVoice.previewText)
        guard NarrationVoice.configure(utterance, preferredIdentifier: identifier) else {
            message = "This voice is unavailable. Choose another installed English voice."
            return
        }
        GameNarrator.stopAll()
        ItemSoundManager.shared.stop()
        currentUtterance = ObjectIdentifier(utterance)
        isSpeaking = true
        BackgroundMusicManager.shared.setNarrating(true)
        synthesizer.speak(utterance)
    }

    func stop() {
        currentUtterance = nil
        synthesizer.stopSpeaking(at: .immediate)
        if isSpeaking { BackgroundMusicManager.shared.setNarrating(false) }
        isSpeaking = false
    }

    private func finish(_ token: ObjectIdentifier) {
        guard currentUtterance == token else { return }
        currentUtterance = nil
        isSpeaking = false
        BackgroundMusicManager.shared.setNarrating(false)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let token = ObjectIdentifier(utterance)
        Task { @MainActor in self.finish(token) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let token = ObjectIdentifier(utterance)
        Task { @MainActor in self.finish(token) }
    }
}
