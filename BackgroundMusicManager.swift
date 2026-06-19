import AVFoundation
import Foundation

@MainActor
final class BackgroundMusicManager: NSObject, AVAudioPlayerDelegate {
    static let shared = BackgroundMusicManager()

    private let trackDuration: TimeInterval = 120
    private let trackNames = [
        "peekaboo_bounce_loop_112bpm",
        "storytime_sparkle_loop_78bpm",
        "sunny_playroom_loop_100bpm"
    ]

    private var player: AVAudioPlayer?
    private var rotationTask: Task<Void, Never>?
    private var currentTrackIndex = 0
    private var isEnabled = false

    private override init() {
        super.init()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled

        if enabled {
            startIfNeeded()
        } else {
            stop()
        }
    }

    private func startIfNeeded() {
        guard player?.isPlaying != true else { return }
        playTrack(at: currentTrackIndex)
    }

    private func stop() {
        rotationTask?.cancel()
        rotationTask = nil
        player?.stop()
        player = nil
    }

    private func playTrack(at index: Int) {
        guard isEnabled, !trackNames.isEmpty else { return }

        rotationTask?.cancel()
        rotationTask = nil

        currentTrackIndex = index % trackNames.count
        let trackName = trackNames[currentTrackIndex]

        guard let url = Bundle.main.url(forResource: trackName, withExtension: "wav", subdirectory: "Noises")
            ?? Bundle.main.url(forResource: trackName, withExtension: "wav") else {
            print("Missing background music file: \(trackName).wav")
            return
        }

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = 0.42
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
            scheduleNextTrack()
        } catch {
            print("Failed to play background music: \(error)")
        }
    }

    private func scheduleNextTrack() {
        let duration = trackDuration
        rotationTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            await MainActor.run {
                guard let self, self.isEnabled else { return }
                self.currentTrackIndex = (self.currentTrackIndex + 1) % self.trackNames.count
                self.playTrack(at: self.currentTrackIndex)
            }
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard isEnabled else { return }
            currentTrackIndex = (currentTrackIndex + 1) % trackNames.count
            playTrack(at: currentTrackIndex)
        }
    }
}
