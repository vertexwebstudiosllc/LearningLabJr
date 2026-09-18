import SpriteKit
import SwiftUI
import Combine

enum OriginalArcadeGame {
    case garage, claw

    var title: String { self == .garage ? "Vehicle Peekaboo" : "Word Claw" }
    var prompt: String {
        self == .garage
            ? "Tap the garage to open the door. Tap again to hear the vehicle's name!"
            : "Tap an item and watch the claw pick it up!"
    }
    var aspectRatio: CGFloat { self == .garage ? 1.5 : 1 }
}

@MainActor
private final class OriginalArcadeSession: ObservableObject {
    let kind: OriginalArcadeGame
    let scene: SKScene
    @Published var name = ""
    @Published var status: String
    private let narrator = GameNarrator()

    nonisolated deinit {}

    init(kind: OriginalArcadeGame) {
        self.kind = kind
        status = kind == .garage ? "Garage closed. Tap to open the door." : "Tap an item for the claw to pick it up."
        scene = kind == .garage
            ? VehiclePeekabooScene(size: CGSize(width: 900, height: 600))
            : ClawGameScene(size: CGSize(width: 720, height: 720))
        scene.scaleMode = .aspectFit
        if let garage = scene as? VehiclePeekabooScene {
            garage.onName = { [weak self] in self?.announce($0) }
            garage.onStatus = { [weak self] in self?.status = $0 }
        }
        if let claw = scene as? ClawGameScene {
            claw.onName = { [weak self] in self?.announce($0) }
            claw.onStatus = { [weak self] in self?.status = $0 }
        }
    }

    private func announce(_ text: String) {
        name = text
        narrator.speak(text)
    }

    func activate() {
        (scene as? VehiclePeekabooScene)?.activate()
        (scene as? ClawGameScene)?.pick()
    }

    func stop() { narrator.stop() }
}

struct OriginalArcadeGameView: View {
    @StateObject private var session: OriginalArcadeSession
    @ObservedObject private var timer = SessionTimerManager.shared
    @Environment(\.scenePhase) private var scenePhase

    init(kind: OriginalArcadeGame) {
        _session = StateObject(wrappedValue: OriginalArcadeSession(kind: kind))
    }

    var body: some View {
        ToddlerGameScaffold(title: session.kind.title, prompt: session.kind.prompt, accent: .orange) {
            VStack(spacing: 12) {
                SpriteView(scene: session.scene, isPaused: scenePhase != .active || timer.isLocked)
                    .aspectRatio(session.kind.aspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(session.kind.title)
                    .accessibilityValue(session.status)
                    .accessibilityIdentifier("original-arcade.canvas")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { session.activate() }
                Text(session.status).font(.headline).multilineTextAlignment(.center)
                    .accessibilityIdentifier("original-arcade.status")
                if !session.name.isEmpty {
                    Text(session.name).font(.title2.bold())
                        .accessibilityIdentifier("original-arcade.item-name")
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { session.stop() } }
        .onDisappear { session.stop(); session.scene.isPaused = true }
    }
}
