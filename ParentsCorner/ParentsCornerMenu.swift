import SwiftUI

struct ParentsCornerMenu: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject private var store = StoreManager.shared
    @ObservedObject private var timer = SessionTimerManager.shared
    @AppStorage("parents.soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("parents.voicePromptsEnabled") private var voicePromptsEnabled = true
    @AppStorage("parents.backgroundMusicEnabled") private var backgroundMusicEnabled = false
    @AppStorage("parents.sessionMinutes") private var sessionMinutes = 10.0
    @State private var showPaywall = false

    var body: some View {
        Form {
            Section {
                Text("Little discoveries, together")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text("Explore 72 activities across six learning areas. Start with one that interests your child and bring the idea into everyday play.")
                NavigationLink { ParentLearningGuide() } label: {
                    Label("What each game helps us explore", systemImage: "book.closed.fill")
                }
            }

            Section("A comfortable pace") {
                Toggle(isOn: $voicePromptsEnabled) { Label("Spoken directions", systemImage: "waveform") }
                Toggle(isOn: $soundEffectsEnabled) { Label("Item sounds", systemImage: "speaker.wave.2.fill") }
                Toggle(isOn: $backgroundMusicEnabled) { Label("Background music", systemImage: "music.note") }
                Text("Music starts off for new families. You can repeat directions inside each game. VoiceOver uses the accessible controls without competing game narration.")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            NarrationVoiceSettings()

            Section("Time to play") {
                HStack {
                    Text("Session length")
                    Spacer()
                    Text("\(Int(sessionMinutes)) minutes").monospacedDigit()
                }
                Slider(value: $sessionMinutes, in: 5...30, step: 5)
                    .accessibilityLabel("Session length")
                    .accessibilityValue("\(Int(sessionMinutes)) minutes")
                if timer.isRunning {
                    Label("\(timer.formattedTime) remaining", systemImage: "hourglass")
                    Button("End the timer") { timer.stop() }
                } else {
                    Button("Start a play session") { timer.start(minutes: Int(sessionMinutes)) }
                }
                Text("Choose a length that fits your family. The timer includes time spent outside the app. When it ends, activities close and a grown-up can start fresh.")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            Section("Premium") {
                Label(store.hasPremium ? "Premium is active" : "Some phonics activities need Premium",
                      systemImage: store.hasPremium ? "checkmark.seal.fill" : "lock.fill")
                if store.hasPremium {
                    Button("Manage subscription") { openSubscriptions() }
                } else {
                    Button("View Premium options") { showPaywall = true }
                }
                Button("Restore purchases") { Task { await store.restorePurchases() } }
                    .disabled(store.isPurchasing)
                if let message = store.statusMessage {
                    Text(message).font(.footnote).foregroundStyle(.secondary)
                }
            }

            Section("Our approach") {
                Label("No third-party ads or account required for play", systemImage: "hand.raised.fill")
                Label("Built-in activities work offline", systemImage: "wifi.slash")
                Text("Purchases and restoring subscriptions need the App Store. Settings stay on this device. The app does not record your child's voice or grade their feelings.")
                    .font(.footnote).foregroundStyle(.secondary)
                Link("AAP: choosing media for ages 2–4", destination: URL(string: "https://www.healthychildren.org/English/family-life/Media/Pages/kids-and-screen-time-5-cs-questions-for-toddlers-and-preschoolers.aspx")!)
                Link("ZERO TO THREE: everyday early math", destination: URL(string: "https://www.zerotothree.org/resource/lets-talk-about-math/")!)
            }
        }
        .tint(.teal)
        .navigationTitle("Parents Corner")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { PremiumPaywallView() }
        .onChange(of: voicePromptsEnabled) { _, enabled in
            if !enabled { GameNarrator.stopAll() }
        }
        .onChange(of: soundEffectsEnabled) { _, enabled in
            if !enabled { ItemSoundManager.shared.stop() }
        }
        .task { await store.updateCustomerProductStatus() }
    }

    private func openSubscriptions() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        openURL(url)
    }
}
