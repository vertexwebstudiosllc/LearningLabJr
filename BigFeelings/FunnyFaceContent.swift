import SwiftUI

enum StudioEmotion: String, CaseIterable, Identifiable {
    case happy, sad, mad, worried, surprised, calm
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var face: StudioFaceDesign {
        switch self {
        case .happy: return .init(eyebrows: 0, eyes: 0, mouth: 0)
        case .sad: return .init(eyebrows: 1, eyes: 0, mouth: 1)
        case .mad: return .init(eyebrows: 2, eyes: 0, mouth: 2)
        case .worried: return .init(eyebrows: 1, eyes: 2, mouth: 3)
        case .surprised: return .init(eyebrows: 3, eyes: 1, mouth: 4)
        case .calm: return .init(eyebrows: 0, eyes: 3, mouth: 5)
        }
    }
}

enum StudioFeature: String, CaseIterable, Identifiable {
    case eyebrows, eyes, mouth, glasses, hat
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var styles: [String] {
        switch self {
        case .eyebrows: return ["Relaxed", "Raised in the middle", "Pointing down in the middle", "High up"]
        case .eyes: return ["Open", "Wide", "Looking sideways", "Gently closed"]
        case .mouth: return ["Big smile", "Big frown", "Little frown", "Wiggly", "Round and open", "Little smile"]
        case .glasses: return ["No glasses", "Round glasses", "Star glasses"]
        case .hat: return ["No hat", "Party hat", "Top hat"]
        }
    }
    var symbol: String {
        switch self {
        case .eyebrows: return "eyebrow"
        case .eyes: return "eye.fill"
        case .mouth: return "mouth.fill"
        case .glasses: return "eyeglasses"
        case .hat: return "party.popper.fill"
        }
    }
}

struct StudioFaceDesign: Equatable {
    var eyebrows: Int
    var eyes: Int
    var mouth: Int
    var glasses = 0
    var hat = 0

    subscript(feature: StudioFeature) -> Int {
        get {
            switch feature {
            case .eyebrows: return eyebrows
            case .eyes: return eyes
            case .mouth: return mouth
            case .glasses: return glasses
            case .hat: return hat
            }
        }
        set {
            switch feature {
            case .eyebrows: eyebrows = newValue
            case .eyes: eyes = newValue
            case .mouth: mouth = newValue
            case .glasses: glasses = newValue
            case .hat: hat = newValue
            }
        }
    }
    var description: String {
        StudioFeature.allCases.map { "\($0.name): \($0.styles[self[$0]])" }.joined(separator: ". ")
    }
}

struct StudioRound {
    let emotion: StudioEmotion
    let target: StudioFaceDesign
    let startingFace: StudioFaceDesign
    let features: [StudioFeature]
}

struct StudioPlay {
    enum Phase { case matching, found }
    let rounds: [StudioRound]
    private(set) var index = 0
    private(set) var phase: Phase = .matching
    private(set) var face: StudioFaceDesign
    var complete: Bool { index == rounds.count }
    var current: StudioRound { rounds[min(index, rounds.count - 1)] }
    var matchedFeatures: [StudioFeature] { current.features.filter { face[$0] == current.target[$0] } }
    var prompt: String {
        if complete { return "We did it together! You can play again or choose all done." }
        if phase == .found { return "You matched the funny face! Every part looks just like the example." }
        if current.features.contains(.hat) { return "Match the example face. Tap your eyebrows, eyes, mouth, glasses, and hat to change them." }
        if current.features.contains(.glasses) { return "Now try some silly glasses! Tap each part of your face to match the example." }
        return "Let's match a funny face! Look at the example, then tap your eyebrows, eyes, and mouth to change them."
    }
    init(previousFirst: String = "", previousLast: String = "") {
        var deck = StudioEmotion.allCases.shuffled()
        if [previousFirst, previousLast].contains(deck[0].rawValue),
           let other = deck.indices.dropFirst().first(where: { ![previousFirst, previousLast].contains(deck[$0].rawValue) }) {
            deck.swapAt(0, other)
        }
        rounds = deck.enumerated().map { index, emotion in
            var target = emotion.face
            var features: [StudioFeature] = [.eyebrows, .eyes, .mouth]
            if index >= 2 {
                features.append(.glasses)
                target.glasses = index.isMultiple(of: 2) ? 1 : 2
            }
            if index >= 4 {
                features.append(.hat)
                target.hat = index.isMultiple(of: 2) ? 1 : 2
            }
            var startingFace = target
            for feature in features {
                startingFace[feature] = (target[feature] + Int.random(in: 1..<feature.styles.count)) % feature.styles.count
            }
            return StudioRound(emotion: emotion, target: target, startingFace: startingFace, features: features)
        }
        face = rounds[0].startingFace
    }
    mutating func change(_ feature: StudioFeature, for emotion: StudioEmotion, from expectedStyle: Int) {
        guard !complete, phase == .matching, current.emotion == emotion,
              current.features.contains(feature), face[feature] == expectedStyle else { return }
        face[feature] = (face[feature] + 1) % feature.styles.count
        if face == current.target { phase = .found }
    }
    mutating func advance(from emotion: StudioEmotion) {
        guard !complete, phase == .found, current.emotion == emotion else { return }
        index += 1
        if !complete { face = current.startingFace; phase = .matching }
    }
}
