import AVFoundation
import Foundation

@MainActor
final class BackgroundMusicManager: NSObject, AVAudioPlayerDelegate {
    static let shared = BackgroundMusicManager()

    private let trackNames = [
        "peekaboo_bounce_loop_112bpm",
        "storytime_sparkle_loop_78bpm",
        "sunny_playroom_loop_100bpm"
    ]

    private var player: AVAudioPlayer?
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
        player?.stop()
        player = nil
    }

    private func playTrack(at index: Int) {
        guard isEnabled, !trackNames.isEmpty else { return }

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
            audioPlayer.numberOfLoops = 0
            audioPlayer.volume = 0.28
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
        } catch {
            print("Failed to play background music: \(error)")
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
