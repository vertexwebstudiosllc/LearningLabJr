import AVFoundation
import Foundation

/// A text lookup keeps every game's existing repeat, mute, and timing behavior.
/// The shipped app never contacts AWS or contains AWS credentials.
struct NarrationAudioCatalog {
    struct Clip: Codable {
        let text: String
        let file: String
        let spokenText: String
        let voice: String
        let engine: String
        let category: String
    }

    struct Manifest: Codable {
        let schemaVersion: Int
        let clips: [Clip]
    }

    static let shared = NarrationAudioCatalog(bundle: .main)
    private let clips: [String: Clip]
    private let bundle: Bundle

    static func normalized(_ text: String) -> String {
        text.precomposedStringWithCanonicalMapping
            .split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    init(bundle: Bundle = .main, manifest: Manifest? = nil) {
        self.bundle = bundle
        let decoded = manifest ?? Self.loadManifest(bundle: bundle)
        var lookup: [String: Clip] = [:]
        if decoded?.schemaVersion == 1 {
            for clip in decoded?.clips ?? [] where Self.isSafeFilename(clip.file) {
                lookup[Self.normalized(clip.text)] = clip
            }
        }
        clips = lookup
    }

    var count: Int { clips.count }

    func clip(for text: String) -> Clip? { clips[Self.normalized(text)] }

    func url(for text: String) -> URL? {
        guard let clip = clip(for: text) else { return nil }
        let name = String(clip.file.dropLast(4))
        // Synchronized Xcode resource groups can flatten folders at build time.
        return bundle.url(forResource: name, withExtension: "mp3")
            ?? bundle.url(forResource: name, withExtension: "mp3", subdirectory: "NarrationAudio")
    }

    static func isSafeFilename(_ filename: String) -> Bool {
        filename.hasPrefix("llj-") && filename.hasSuffix(".mp3")
            && !filename.contains("/") && !filename.contains("\\")
            && !filename.contains("..")
    }

    private static func loadManifest(bundle: Bundle) -> Manifest? {
        guard let url = bundle.url(forResource: "NarrationAudioManifest", withExtension: "json")
                ?? bundle.url(forResource: "NarrationAudioManifest", withExtension: "json", subdirectory: "NarrationAudio"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Manifest.self, from: data)
    }
}

/// Guards against a delayed delegate callback ending a newer recording.
@MainActor
final class RecordedNarrationPlayer: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var completion: (() -> Void)?

    @discardableResult
    func play(url: URL, onFinish: @escaping () -> Void) -> Bool {
        stop()
        guard let audio = try? AVAudioPlayer(contentsOf: url) else { return false }
        audio.delegate = self
        audio.volume = 1
        player = audio
        completion = onFinish
        guard audio.prepareToPlay(), audio.play() else { stop(); return false }
        return true
    }

    func stop() {
        completion = nil
        player?.delegate = nil
        player?.stop()
        player = nil
    }

    private func finish(_ token: ObjectIdentifier) {
        guard let player, ObjectIdentifier(player) == token else { return }
        let callback = completion
        stop()
        callback?()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let token = ObjectIdentifier(player)
        Task { @MainActor in self.finish(token) }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let token = ObjectIdentifier(player)
        Task { @MainActor in self.finish(token) }
    }
}
