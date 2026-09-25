import SwiftUI

struct BodyBuddy: Identifiable {
    enum Identity: String { case boy, girl }
    enum Hair: Int { case short, curls, long, buns, waves, braid }
    let id: String
    let name: String
    let identity: Identity
    let skin: UInt
    let hair: UInt
    let style: Hair
    let shirt: UInt
    var introduction: String { "Meet " + name + "." }
    static let bank: [BodyBuddy] = {
        let names = ["Maya", "Leo", "Amina", "Kai", "Zoe", "Noah", "Mei", "Sam", "Priya", "Eli", "Luna", "Omar", "Ada", "Ben", "Nia", "Luis", "Hana", "Theo"]
        let skins: [UInt] = [0x70452F, 0xF3CFAE, 0xB17A52, 0xE0A879, 0xEBC3A0, 0x986546]
        let hair: [UInt] = [0x292222, 0x9A542E, 0x30231D, 0x191D28, 0xC0662D, 0x362B29]
        let shirts: [UInt] = [0xCA4779, 0x287AB0, 0x218D82, 0xA66C13, 0x7852A8, 0x387F55]
        let styles = [1, 0, 2, 0, 3, 1, 2, 4, 5, 0, 4, 0, 3, 4, 1, 0, 5, 1]
        return names.enumerated().map { index, name in
            BodyBuddy(id: name.lowercased(), name: name, identity: index.isMultiple(of: 2) ? .girl : .boy,
                      skin: skins[(index + index / 6) % 6], hair: hair[(index + 2 * (index / 6)) % 6],
                      style: Hair(rawValue: styles[index])!, shirt: shirts[(index + index / 6) % 6])
        }
    }()
}

enum BuddyPart: String, CaseIterable {
    case head, eyes, ears, nose, mouth, hands, tummy, knees, feet
    var title: String { rawValue.capitalized }
    var hint: String { "Let's find the " + rawValue + ". Look for the glowing outline." }
}

struct BodyClue: Identifiable {
    let id: String
    let part: BuddyPart
    let question: String
    let response: String
    static let bank: [BodyClue] = [
        .init(id: "hat", part: .head, question: "Where would a hat go? Tap that part of our friend.", response: "You found the head! A hat goes on the head."),
        .init(id: "helmet", part: .head, question: "Where would a bicycle helmet go? Tap that part.", response: "That is the head. A helmet helps protect the head."),
        .init(id: "look", part: .eyes, question: "Which parts of the face can help us see a picture?", response: "You found the eyes! Eyes can help us see."),
        .init(id: "blink", part: .eyes, question: "Which parts of the face blink? Find them on our friend.", response: "Those are the eyes. Blink, blink!"),
        .init(id: "listen", part: .ears, question: "Which parts at the sides of the head can help us hear?", response: "You found the ears! Ears can help us hear sounds."),
        .init(id: "earmuffs", part: .ears, question: "Which parts of the head do earmuffs cover?", response: "Those are the ears. Earmuffs help keep ears warm."),
        .init(id: "smell", part: .nose, question: "Which part of the face can help us smell a flower?", response: "You found the nose! A nose can help us smell."),
        .init(id: "sniff", part: .nose, question: "Find the part between the eyes and the mouth.", response: "That is the nose, in the middle of the face."),
        .init(id: "bite", part: .mouth, question: "Where does a bite of a snack go? Tap that part of the face.", response: "You found the mouth! Food goes into the mouth."),
        .init(id: "smile", part: .mouth, question: "Which part of the face makes a smile?", response: "That is the mouth. Our friend has a smile!"),
        .init(id: "wave", part: .hands, question: "Which parts can wave hello? Tap one on our friend.", response: "You found a hand! Hands can wave hello."),
        .init(id: "mittens", part: .hands, question: "Which parts do mittens keep warm? Tap one.", response: "That is a hand. Mittens help keep hands warm."),
        .init(id: "rumble", part: .tummy, question: "Which part below the chest might rumble when we feel hungry?", response: "You found the tummy! Sometimes a tummy makes a rumble."),
        .init(id: "middle", part: .tummy, question: "Find the tummy in the middle of our friend, above the legs.", response: "That is the tummy, above the legs."),
        .init(id: "bend", part: .knees, question: "Find a bendy part in the middle of a leg.", response: "You found a knee! Knees help legs bend."),
        .init(id: "kneepads", part: .knees, question: "Where would knee pads go? Tap one spot on our friend.", response: "That is a knee. Knee pads help protect knees."),
        .init(id: "socks", part: .feet, question: "Which parts wear socks? Tap one on our friend.", response: "You found a foot! Socks go on feet."),
        .init(id: "toes", part: .feet, question: "Which parts have toes? Find one at the bottom of our friend.", response: "That is a foot. Toes are part of a foot!"),
    ]
    static let retry = "Good exploring! Listen to the clue and try another body part."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        bank.flatMap { [$0.question, $0.response] } + BuddyPart.allCases.map(\.hint)
        + BodyBuddy.bank.map(\.introduction) + [retry, completion]
    }
}

struct BodyClueRound {
    let clue: BodyClue
    let buddy: BodyBuddy
}

struct BodyCluePlay {
    let rounds: [BodyClueRound]
    private(set) var index = 0
    private(set) var solved = false
    private(set) var attempts = 0
    private(set) var hintShown = false
    var complete: Bool { index == rounds.count }
    var current: BodyClueRound { rounds[min(index, rounds.count - 1)] }
    var prompt: String { solved ? current.clue.response : current.clue.question }
    init(previousBuddy: String = "", previousClue: String = "") {
        var buddies = BodyBuddy.bank.shuffled()
        if buddies[0].id == previousBuddy { buddies.swapAt(0, Int.random(in: 1..<buddies.count)) }
        var first = BuddyPart.allCases.shuffled().map { part in BodyClue.bank.filter { $0.part == part }.randomElement()! }
        if first[0].id == previousClue { first.swapAt(0, Int.random(in: 1..<first.count)) }
        let used = Set(first.map(\.id))
        var second = BodyClue.bank.filter { !used.contains($0.id) }.shuffled()
        if second[0].part == first.last!.part { second.swapAt(0, Int.random(in: 1..<second.count)) }
        let clues = first + second
        rounds = zip(clues, buddies).map { BodyClueRound(clue: $0.0, buddy: $0.1) }
    }
    @discardableResult mutating func choose(_ part: BuddyPart, clue: String) -> Bool {
        guard !complete, !solved, clue == current.clue.id else { return false }
        if part == current.clue.part { solved = true; return true }
        attempts += 1
        if attempts >= 2 { hintShown = true }
        return false
    }
    mutating func showHint() {
        guard !complete, !solved else { return }
        hintShown = true
    }
    mutating func next() {
        guard !complete, solved else { return }
        index += 1
        if !complete { solved = false; attempts = 0; hintShown = false }
    }
}
