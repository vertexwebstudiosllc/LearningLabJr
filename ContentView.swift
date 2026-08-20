import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("parents.backgroundMusicEnabled") private var backgroundMusicEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var timer = SessionTimerManager.shared

    var body: some View {
        ZStack {
            if !timer.isLocked {
                NavigationStack {
                    LearningLabHomeView()
                }
            }

            SessionTimerOverlay()
                .allowsHitTesting(timer.isLocked)
        }
        .onAppear {
            BackgroundMusicManager.shared.setEnabled(backgroundMusicEnabled)
        }
        .onChange(of: backgroundMusicEnabled) { _, isEnabled in
            BackgroundMusicManager.shared.setEnabled(isEnabled)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { timer.refresh() }
            updateAudio(active: phase == .active && !timer.isLocked)
        }
        .onChange(of: timer.isLocked) { _, locked in
            updateAudio(active: !locked && scenePhase == .active)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)) { _ in
            if UIAccessibility.isVoiceOverRunning { GameNarrator.stopAll() }
        }
    }

    private func updateAudio(active: Bool) {
        BackgroundMusicManager.shared.setForeground(active)
        if !active {
            GameNarrator.stopAll()
            ItemSoundManager.shared.stop()
        }
    }
}

#Preview {
    ContentView()
}
