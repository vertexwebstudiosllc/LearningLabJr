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
    private var isForeground = true
    private var isNarrating = false
    private var movementOwner: UUID?
    private var movementCue: WiggleCue?
    private var movementEnabled = true

    // Activity music is explicitly started in the movement game. The ambient
    // music preference is retained and restored on exit, never changed here.
    var isPlayingMovementMusic: Bool { movementOwner != nil && player?.isPlaying == true }
    var isPlayingAmbientMusic: Bool { movementOwner == nil && player?.isPlaying == true }
    var movementPlaybackRate: Float? { movementOwner == nil ? nil : player?.rate }
    var playbackVolume: Float? { player?.volume }

    func beginMovementGame(owner: UUID) {
        stop()
        movementOwner = owner; movementCue = nil; movementEnabled = true
    }

    func setMovementGame(owner: UUID, cue: WiggleCue?, enabled: Bool) {
        guard movementOwner == owner else { return }
        movementCue = cue; movementEnabled = enabled
        syncMovementMusic()
    }

    func endMovementGame(owner: UUID) {
        guard movementOwner == owner else { return }
        stop(); movementOwner = nil; movementCue = nil
        if isEnabled && isForeground { startIfNeeded() }
    }

    private var desiredVolume: Float { isNarrating ? 0.035 : movementOwner == nil ? 0.16 : 0.22 }

    private func syncMovementMusic() {
        guard movementOwner != nil else { return }
        guard isForeground, movementEnabled, let cue = movementCue, cue != .stop else {
            player?.pause()
            return
        }
        if player == nil {
            guard let url = Bundle.main.url(forResource: "peekaboo_bounce_loop_112bpm", withExtension: "wav", subdirectory: "Noises")
                ?? Bundle.main.url(forResource: "peekaboo_bounce_loop_112bpm", withExtension: "wav") else { return }
            do {
                #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                #endif
                let music = try AVAudioPlayer(contentsOf: url)
                music.enableRate = true; music.numberOfLoops = -1
                music.prepareToPlay(); player = music
            } catch { print("Unable to play movement music: \(error)"); return }
        }
        player?.rate = cue.musicRate
        player?.volume = desiredVolume
        if player?.isPlaying != true {
            do {
                #if os(iOS)
                try AVAudioSession.sharedInstance().setActive(true)
                #endif
                player?.play()
            } catch { print("Unable to resume movement music: \(error)") }
        }
    }

    private override init() {
        super.init()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if movementOwner != nil { syncMovementMusic(); return }

        if enabled && isForeground {
            startIfNeeded()
        } else {
            stop()
        }
    }

    func setForeground(_ active: Bool) {
        isForeground = active
        if movementOwner != nil { syncMovementMusic(); return }
        if active && isEnabled { startIfNeeded() } else { stop() }
    }

    func setNarrating(_ narrating: Bool) {
        isNarrating = narrating
        player?.setVolume(desiredVolume, fadeDuration: 0.2)
    }

    private func startIfNeeded() {
        guard movementOwner == nil, player?.isPlaying != true else { return }
        playTrack(at: currentTrackIndex)
    }

    private func stop() {
        rotationTask?.cancel()
        rotationTask = nil
        player?.stop()
        player = nil
    }

    private func playTrack(at index: Int) {
        guard movementOwner == nil, isEnabled, isForeground, !trackNames.isEmpty else { return }

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
            audioPlayer.volume = desiredVolume
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
            do {
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            } catch { return }
            await MainActor.run {
                guard let self, self.movementOwner == nil, self.isEnabled, self.isForeground, !Task.isCancelled else { return }
                self.currentTrackIndex = (self.currentTrackIndex + 1) % self.trackNames.count
                self.playTrack(at: self.currentTrackIndex)
            }
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard movementOwner == nil, isEnabled, isForeground else { return }
            currentTrackIndex = (currentTrackIndex + 1) % trackNames.count
            playTrack(at: currentTrackIndex)
        }
    }
}
