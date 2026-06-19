import SwiftUI

struct ContentView: View {
    @AppStorage("parents.backgroundMusicEnabled") private var backgroundMusicEnabled = true

    var body: some View {
        ZStack {
            NavigationStack {
                LearningLabHomeView()
            }

            SessionTimerOverlay()
        }
        .onAppear {
            BackgroundMusicManager.shared.setEnabled(backgroundMusicEnabled)
        }
        .onChange(of: backgroundMusicEnabled) { isEnabled in
            BackgroundMusicManager.shared.setEnabled(isEnabled)
        }
    }
}

#Preview {
    ContentView()
}
