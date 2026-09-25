import SwiftUI

enum StudioEmotion: String, CaseIterable, Identifiable {
    case happy, sad, mad, worried, surprised, calm
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var clue: String {
        switch self {
        case .happy: return "Try a big smile with open eyes and relaxed eyebrows."
        case .sad: return "Try a downturned mouth with eyebrows raised in the middle."
        case .mad: return "Try eyebrows pointing down in the middle and a small frown."
        case .worried: return "Try eyebrows raised in the middle and a small, tight mouth."
        case .surprised: return "Try wide eyes, high eyebrows, and a round, open mouth."
        case .calm: return "Try gently closed eyes, relaxed eyebrows, and a little smile."
        }
    }
    var copyPrompt: String { "Can you copy our puppet's face? " + clue + " You can try with a grown-up, or watch together." }
    var retry: String { "Let's look at our pretend face again. " + clue + " Try another feeling word." }
    var success: String { "Our puppet is pretending to feel " + rawValue + ". You found its feeling word!" }
    var wordPrompt: String { "This feeling word is " + rawValue + "." }
    var alternatives: [StudioEmotion] {
        switch self {
        case .happy: return [.happy, .sad, .mad]
        case .sad: return [.sad, .happy, .calm]
        case .mad: return [.mad, .sad, .calm]
        case .worried: return [.worried, .calm, .happy]
        case .surprised: return [.surprised, .worried, .sad]
        case .calm: return [.calm, .happy, .mad]
        }
    }
    static func question(_ choices: [StudioEmotion]) -> String {
        "Which feeling is our puppet pretending? " + choices.map(\.name).joined(separator: ", ") + ". Tap the matching face and feeling word."
    }
    static var narration: [String] {
        allCases.flatMap { emotion in
            var lines = [emotion.copyPrompt, emotion.retry, emotion.success, emotion.wordPrompt]
            let options = emotion.alternatives
            for a in options {
                for b in options where b != a {
                    let c = options.first { $0 != a && $0 != b }!
                    lines.append(question([a, b, c]))
                }
            }
            return lines
        }
    }
}
struct StudioRound {
    let emotion: StudioEmotion
    let choices: [StudioEmotion]
}
struct StudioPlay {
    enum Phase { case copy, identify, found }
    let rounds: [StudioRound]
    private(set) var index = 0
    private(set) var phase: Phase = .copy
    private(set) var needsHelp = false
    var complete: Bool { index == rounds.count }
    var current: StudioRound { rounds[min(index, rounds.count - 1)] }
    var prompt: String {
        if complete { return "We did it together! You can play again or choose all done." }
        switch phase {
        case .copy: return current.emotion.copyPrompt
        case .identify: return needsHelp ? current.emotion.retry : StudioEmotion.question(current.choices)
        case .found: return current.emotion.success
        }
    }
    init(previousFirst: String = "", previousLast: String = "") {
        var deck = StudioEmotion.allCases.shuffled()
        if [previousFirst, previousLast].contains(deck[0].rawValue),
           let other = deck.indices.dropFirst().first(where: { ![previousFirst, previousLast].contains(deck[$0].rawValue) }) {
            deck.swapAt(0, other)
        }
        rounds = deck.map { StudioRound(emotion: $0, choices: $0.alternatives.shuffled()) }
    }
    mutating func copied(_ emotion: StudioEmotion) {
        guard !complete, phase == .copy, current.emotion == emotion else { return }
        phase = .identify
    }
    mutating func choose(_ answer: StudioEmotion, for emotion: StudioEmotion) {
        guard !complete, phase == .identify, current.emotion == emotion, current.choices.contains(answer) else { return }
        if answer == emotion { phase = .found; needsHelp = false }
        else { needsHelp = true }
    }
    mutating func advance(from emotion: StudioEmotion) {
        guard !complete, phase == .found, current.emotion == emotion else { return }
        index += 1; phase = .copy; needsHelp = false
    }
}
