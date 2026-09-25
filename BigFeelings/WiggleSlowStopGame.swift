import AVFoundation
import SwiftUI

struct WiggleSlowStopGame: View {
    let onReplay: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var sessionTimer = SessionTimerManager.shared
    @AppStorage("feelings.wiggle.lastFirst") private var lastFirst = ""
    @State private var play = WiggleMovementPlay()
    @State private var musicEnabled = true
    @State private var musicOwner = UUID()
    @State private var appeared = false
    @State private var visible = false
    private var active: Bool { visible && scenePhase == .active && !sessionTimer.isLocked }
    var body: some View {
        ToddlerGameScaffold(title: "Wiggle, Slow, Stop", prompt: play.prompt, accent: play.current.cue.color,
                            completion: play.phase == .complete, onReplay: onReplay) {
            if play.phase == .ready {
                WiggleMovementStage(cue: .wiggle, moving: false, reduceMotion: reduceMotion)
                Text("Listen, move, and freeze together").font(.title2.bold()).multilineTextAlignment(.center)
                musicButton
                ToddlerActionButton(title: musicEnabled ? "Start the music and move!" : "Start without music", systemImage: "play.fill", color: .green) { play.start() }
                    .accessibilityIdentifier("wiggle.start")
            } else if play.phase == .complete {
                WiggleMovementStage(cue: .stop, moving: false, reduceMotion: reduceMotion)
                Text("You listened, moved, and paused!").font(.title2.bold())
            } else {
                Text("Movement \(play.group) of 6").font(.headline).accessibilityIdentifier("wiggle.progress")
                Text(play.current.movement.name).font(.title2.bold())
                Text(play.phase == .paused ? "Paused" : play.current.cue.title)
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .accessibilityIdentifier(play.phase == .paused ? "wiggle.paused" : "wiggle.cue.\(play.index)")
                WiggleMovementStage(cue: play.current.cue, moving: play.phase == .playing && active, reduceMotion: reduceMotion)
                if play.phase == .paused {
                    ToddlerActionButton(title: "Resume", systemImage: "play.fill", color: .green) { if active { play.resume() } }.accessibilityIdentifier("wiggle.resume")
                } else {
                    Button { play.pause() } label: {
                        Label("Pause", systemImage: "pause.fill").font(.headline).frame(maxWidth: .infinity, minHeight: 60)
                    }.buttonStyle(.plain).background(.white, in: RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("wiggle.pause")
                }
                musicButton
                Text("The game changes the moves for you.").font(.subheadline)
            }
        }.onAppear {
            if !appeared {
                play = WiggleMovementPlay(previousFirst: lastFirst)
                lastFirst = play.beats[0].movement.id; appeared = true
            }
            visible = true
            BackgroundMusicManager.shared.beginMovementGame(owner: musicOwner)
            updateMusic()
        }.onDisappear {
            visible = false; play.pause()
            BackgroundMusicManager.shared.endMovementGame(owner: musicOwner)
        }.onChange(of: scenePhase) { _, phase in
            if phase != .active { play.pause(); updateMusic() }
        }.onChange(of: sessionTimer.isLocked) { _, locked in
            if locked { play.pause(); updateMusic() }
        }.onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { notification in
            if let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
               AVAudioSession.InterruptionType(rawValue: raw) == .began { play.pause(); updateMusic() }
        }.onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { notification in
            if let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
               AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable { play.pause(); updateMusic() }
        }.task(id: "\(play.token):\(active)") {
            updateMusic()
            guard active, play.phase == .playing else { return }
            let token = play.token
            do { try await Task.sleep(for: .seconds(play.current.seconds)) } catch { return }
            guard !Task.isCancelled, active else { return }
            play.elapsed(token)
        }
    }
    private var musicButton: some View {
        Button { musicEnabled.toggle(); updateMusic() } label: {
            Label(musicEnabled ? "Music on" : "Music off", systemImage: musicEnabled ? "music.note" : "speaker.slash.fill")
                .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
        }.buttonStyle(.plain).accessibilityValue(musicEnabled ? "On" : "Off").accessibilityIdentifier("wiggle.music")
    }
    private func updateMusic() {
        BackgroundMusicManager.shared.setMovementGame(owner: musicOwner, cue: active && play.phase == .playing ? play.current.cue : nil, enabled: musicEnabled)
    }
}
