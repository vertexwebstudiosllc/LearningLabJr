import SwiftUI

enum WiggleCue: String, CaseIterable {
    case wiggle, slow, stop
    var title: String { rawValue.capitalized }
    var color: Color {
        switch self { case .wiggle: return .green; case .slow: return .orange; case .stop: return .red }
    }
    var symbol: String {
        switch self { case .wiggle: return "figure.dance"; case .slow: return "tortoise.fill"; case .stop: return "hand.raised.fill" }
    }
    var seconds: ClosedRange<Int> {
        switch self { case .wiggle: return 8...12; case .slow: return 6...9; case .stop: return 4...6 }
    }
    var musicRate: Float { self == .slow ? 0.65 : 1 }
}

struct WiggleMovement: Identifiable {
    let id: String
    let name: String
    let words: [String]
    static let bank: [Self] = [
        .init(id: "fingers", name: "Dancing fingers", words: ["Wiggle! Dance your fingers!", "Slow! Move your fingers slowly.", "Stop! Rest your fingers."]),
        .init(id: "arms", name: "Waving arms", words: ["Wiggle! Wave your arms!", "Slow! Wave your arms slowly.", "Stop! Rest your arms."]),
        .init(id: "toes", name: "Wiggly toes", words: ["Wiggle! Wiggle your toes!", "Slow! Move your toes slowly.", "Stop! Rest your toes."]),
        .init(id: "shoulders", name: "Dancing shoulders", words: ["Wiggle! Wiggle your shoulders!", "Slow! Move your shoulders slowly.", "Stop! Rest your shoulders."]),
        .init(id: "hands", name: "Happy hands", words: ["Wiggle! Wave hello with your hands!", "Slow! Wave hello slowly.", "Stop! Rest your hands."]),
        .init(id: "dance", name: "Your little dance", words: ["Wiggle! Do your own little dance!", "Slow! Make your dance slow and gentle.", "Stop! Find a comfy still pose."]),
    ]
    func prompt(_ cue: WiggleCue) -> String { words[WiggleCue.allCases.firstIndex(of: cue)!] }
}

struct WiggleBeat {
    let movement: WiggleMovement
    let cue: WiggleCue
    let seconds: Int
    var prompt: String { movement.prompt(cue) }
}

struct WiggleMovementPlay {
    enum Phase { case ready, playing, paused, complete }
    let beats: [WiggleBeat]
    private(set) var phase: Phase = .ready
    private(set) var index = 0
    private(set) var token = UUID()
    var current: WiggleBeat { beats[min(index, beats.count - 1)] }
    var group: Int { min(index / 3 + 1, 6) }
    var prompt: String {
        switch phase {
        case .ready: return Self.invitation
        case .playing: return current.prompt
        case .paused: return Self.paused
        case .complete: return Self.finished
        }
    }
    init(previousFirst: String = "") {
        var movements = WiggleMovement.bank.shuffled()
        if movements[0].id == previousFirst { movements.swapAt(0, 1) }
        beats = movements.flatMap { movement in
            WiggleCue.allCases.map { cue in WiggleBeat(movement: movement, cue: cue, seconds: Int.random(in: cue.seconds)) }
        }
    }
    mutating func start() {
        guard phase == .ready else { return }
        phase = .playing; token = UUID()
    }
    mutating func pause() {
        guard phase == .playing else { return }
        phase = .paused; token = UUID()
    }
    mutating func resume() {
        guard phase == .paused else { return }
        phase = .playing; token = UUID()
    }
    mutating func elapsed(_ expected: UUID) {
        guard phase == .playing, token == expected else { return }
        index += 1; token = UUID()
        if index == beats.count { phase = .complete }
    }
    static let invitation = "Let's move together! Wiggle when I say wiggle. Move gently when I say slow. Hold still when I say stop. Sit or stand with your grown-up. Ready?"
    static let paused = "We are taking a little pause. Tap resume when you are ready to move again."
    static let finished = "We did it together! You can play again or choose all done."
    static var narration: [String] { [invitation, paused, finished] + WiggleMovement.bank.flatMap(\.words) }
}
