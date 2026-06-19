import SwiftUI

struct ContentView: View {
    @AppStorage("parents.backgroundMusicEnabled") private var backgroundMusicEnabled = false

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
