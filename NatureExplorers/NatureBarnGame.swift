import SwiftUI
import SpriteKit
import Combine

@MainActor
final class BarnyardSession: ObservableObject {
    static let savedDeckKey = "nature.barnyard.discoveryDeck"
    let scene: BarnyardPeekabooScene
    @Published private(set) var play: BarnyardPlay
    private let narrator = GameNarrator()
    private let defaults: UserDefaults
    nonisolated deinit {}

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let deck = defaults.data(forKey: Self.savedDeckKey)
            .flatMap { try? JSONDecoder().decode(BarnyardDeck.self, from: $0) } ?? BarnyardDeck()
        scene = BarnyardPeekabooScene(size: CGSize(width: 900, height: 1000), deck: deck)
        play = scene.play
        scene.onChange = { [weak self] play in
            guard let self else { return }
            self.play = play
            if play.phase == .opening || play.phase == .closing { self.narrator.stop() }
            if play.phase == .closed {
                self.defaults.set(try? JSONEncoder().encode(play.deck), forKey: Self.savedDeckKey)
            }
        }
        scene.onIntroduce = { [weak self] visitor in self?.narrator.speak(visitor.introduction) }
    }
    var status: String {
        switch play.phase {
        case .closed: "Barn closed. Tap to open the doors."
        case .opening: "Opening the barn doors…"
        case .open: "Peekaboo! Tap to meet our visitor."
        case .introduced: "Tap the barn to find another surprise."
        case .closing: "Closing the barn doors…"
        }
    }
    var actionTitle: String {
        switch play.phase {
        case .closed: "Open the barn"
        case .opening: "Opening…"
        case .open: "Meet our visitor"
        case .introduced: "Another surprise"
        case .closing: "Closing…"
        }
    }
    var busy: Bool { play.phase == .opening || play.phase == .closing }
    func activate() { if !busy { narrator.stop(); scene.activate() } }
    func repeatIntroduction() { if play.phase == .introduced { narrator.speak(play.current.introduction) } }
    func pretend() { if play.phase == .introduced { narrator.speak(play.current.playPrompt) } }
    func stop() { narrator.stop() }
}

struct NatureBarnGame: View {
    @StateObject private var session = BarnyardSession()
    @ObservedObject private var timer = SessionTimerManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingPlayPrompt = false

    var body: some View {
        ToddlerGameScaffold(title: "Peekaboo Barnyard", prompt: BarnyardDiscovery.prompt, accent: .orange) {
            SpriteView(scene: session.scene, isPaused: scenePhase != .active || timer.isLocked)
                .aspectRatio(0.9, contentMode: .fit)
                .frame(maxWidth: 480)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Peekaboo Barnyard")
                .accessibilityValue(session.status)
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { session.activate() }
                .accessibilityIdentifier("barnyard.canvas")
            Text(session.status).font(.headline).multilineTextAlignment(.center)
                .accessibilityIdentifier("barnyard.status")
            Text("Surprise \(session.play.position) of \(BarnyardDiscovery.bank.count)")
                .font(.subheadline).foregroundStyle(.secondary)
                .accessibilityIdentifier("barnyard.progress")
            if session.play.phase == .introduced {
                Text(session.play.current.name).font(.title2.bold())
                    .accessibilityIdentifier("barnyard.name")
                Text(showingPlayPrompt ? session.play.current.playPrompt : session.play.current.introduction)
                    .multilineTextAlignment(.center).accessibilityIdentifier("barnyard.discovery")
                HStack {
                    Button("Hear again") { showingPlayPrompt = false; session.repeatIntroduction() }
                        .frame(maxWidth: .infinity, minHeight: 48).accessibilityIdentifier("barnyard.repeat")
                    Button("Let's pretend") { showingPlayPrompt = true; session.pretend() }
                        .frame(maxWidth: .infinity, minHeight: 48).accessibilityIdentifier("barnyard.pretend")
                }.font(.headline)
            }
            ToddlerActionButton(title: session.actionTitle, systemImage: "hand.tap.fill", color: .orange) { session.activate() }
                .disabled(session.busy || timer.isLocked || scenePhase != .active)
                .accessibilityIdentifier("barnyard.activate")
        }
        .onAppear { session.scene.reduceMotion = reduceMotion; session.scene.isPaused = scenePhase != .active || timer.isLocked }
        .onChange(of: reduceMotion) { _, value in session.scene.reduceMotion = value }
        .onChange(of: session.play.phase) { _, phase in if phase != .introduced { showingPlayPrompt = false } }
        .onChange(of: scenePhase) { _, phase in if phase != .active { session.stop() } }
        .onChange(of: timer.isLocked) { _, locked in if locked { session.stop() } }
        .onDisappear { session.stop(); session.scene.isPaused = true }
    }
}
