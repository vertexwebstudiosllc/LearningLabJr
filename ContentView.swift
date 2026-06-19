import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            NavigationStack {
                LearningLabHomeView()
            }

            SessionTimerOverlay()
        }
    }
}

#Preview {
    ContentView()
}
