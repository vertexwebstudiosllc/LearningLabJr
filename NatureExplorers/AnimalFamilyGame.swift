import SwiftUI

struct AnimalFamily: Identifiable {
    let id: String
    let baby: String
    let sound: String
    var adultArt: String { "FamilyClean/\(id)" }
    var babyArt: String { "FamilyClean/\(baby)" }
    var discovery: String { "Together! A baby \(id) is called a \(baby)." }
    static let bank: [Self] = [
        .init(id: "cow", baby: "calf", sound: "Moo, moo!"),
        .init(id: "horse", baby: "foal", sound: "Neigh, neigh!"),
        .init(id: "sheep", baby: "lamb", sound: "Baa, baa!"),
        .init(id: "chicken", baby: "chick", sound: "Cluck, cluck!"),
        .init(id: "cat", baby: "kitten", sound: "Meow, meow!"),
        .init(id: "dog", baby: "puppy", sound: "Woof, woof!")
    ]
}

enum FamilyMatchKind: String, CaseIterable {
    case baby, grownUp, sound
    var title: String {
        switch self {
        case .baby: "Find the baby"
        case .grownUp: "Find the grown-up"
        case .sound: "Listen for a family"
        }
    }
}

struct FamilyMatchRound {
    let family: AnimalFamily
    let kind: FamilyMatchKind
    let choices: [AnimalFamily]
    var id: String { "\(kind.rawValue).\(family.id)" }
    var prompt: String {
        switch kind {
        case .baby: "Here's a grown-up \(family.id). Can you find its baby?"
        case .grownUp: "This little \(family.baby) is looking for its family. Find the grown-up \(family.id)."
        case .sound: "\(family.sound) Which animal family makes that sound?"
        }
    }
    var hint: String {
        switch kind {
        case .baby: "Let's look again. The \(family.id)'s baby is a \(family.baby)."
        case .grownUp: "Let's look again. A \(family.baby) grows into a \(family.id)."
        case .sound: "\(family.sound) That's a \(family.id) sound. Find the \(family.id) family."
        }
    }
}

struct AnimalFamilySession {
    let rounds: [FamilyMatchRound]
    private(set) var index = 0
    private(set) var solved = false
    var complete: Bool { index == rounds.count }
    var current: FamilyMatchRound { rounds[min(index, rounds.count - 1)] }
    static let completion = "You brought eighteen animal families together! What a caring animal helper!"
    var prompt: String { complete ? Self.completion : solved ? current.family.discovery : current.prompt }

    init(previousFirst: String = "") {
        var result: [FamilyMatchRound] = []
        var previous = previousFirst
        for kind in FamilyMatchKind.allCases {
            var families = AnimalFamily.bank.shuffled()
            if families[0].id == previous { families.swapAt(0, 1) }
            for family in families {
                let others = AnimalFamily.bank.filter { $0.id != family.id }.shuffled()
                let choices = ([family] + Array(others.prefix(kind == .baby ? 1 : 2))).shuffled()
                result.append(.init(family: family, kind: kind, choices: choices))
            }
            previous = families.last!.id
        }
        rounds = result
    }
    @discardableResult mutating func choose(_ id: String) -> Bool {
        guard !complete, !solved, current.choices.contains(where: { $0.id == id }), id == current.family.id else { return false }
        solved = true
        return true
    }
    mutating func next() {
        guard solved, !complete else { return }
        index += 1; solved = false
    }
}

struct AnimalFamilyGame: View {
    @AppStorage("nature.family.previousFirst") private var previousFirst = ""
    @State private var play = AnimalFamilySession()
    @State private var started = false
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Animal Families", prompt: play.prompt, accent: .teal,
                            completion: play.complete, onReplay: restart) {
            if !play.complete {
                Text("Round \(play.index + 1) of \(play.rounds.count)")
                    .font(.system(.subheadline, design: .rounded)).foregroundStyle(.secondary)
                    .accessibilityIdentifier("families.round")
                Text(play.current.kind.title).font(.system(.headline, design: .rounded))
                Button { narrator.speak(play.prompt) } label: {
                    Group {
                        if play.solved {
                            familyPicture(play.current.family)
                        } else if play.current.kind == .sound {
                            VStack(spacing: 8) {
                                Image(systemName: "ear.badge.waveform").font(.system(size: 60))
                                Text(play.current.family.sound).font(.system(.title2, design: .rounded, weight: .bold))
                                Text("Listen again").font(.headline)
                            }
                        } else {
                            Image(play.current.kind == .baby ? play.current.family.adultArt : play.current.family.babyArt)
                                .resizable().scaledToFit().padding(10)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 145)
                    .background(.teal.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(.plain).accessibilityLabel("Hear the clue again")
                .accessibilityIdentifier("families.clue.\(play.current.id)")
                if play.solved {
                    Label("Together!", systemImage: "heart.fill").font(.title2).foregroundStyle(.teal)
                    ToddlerActionButton(title: play.index == 17 ? "Finish helping" : "Next family", systemImage: "arrow.right") {
                        narrator.stop(); feedback = ""; play.next()
                    }.accessibilityIdentifier("families.next")
                } else {
                    // Two choices first, then three; each whole card is a generous tap target.
                    HStack(spacing: 10) {
                        ForEach(play.current.choices) { family in
                            Button {
                                if play.choose(family.id) { narrator.stop(); feedback = "" }
                                else { feedback = play.current.hint; narrator.speak(feedback) }
                            } label: {
                                VStack(spacing: 8) {
                                    if play.current.kind == .sound { familyPicture(family).frame(height: 78) }
                                    else {
                                        Image(play.current.kind == .baby ? family.babyArt : family.adultArt)
                                            .resizable().scaledToFit().frame(height: 90)
                                    }
                                    Text(play.current.kind == .baby ? family.baby.capitalized : family.id.capitalized)
                                        .font(.system(.headline, design: .rounded))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(8).frame(maxWidth: .infinity, minHeight: 134)
                                .background(.white, in: RoundedRectangle(cornerRadius: 22))
                                .overlay(RoundedRectangle(cornerRadius: 22).stroke(.teal.opacity(0.25), lineWidth: 2))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(play.current.kind == .baby ? family.baby : play.current.kind == .sound ? "\(family.id) and \(family.baby)" : family.id)
                            .accessibilityIdentifier("families.choice.\(family.id)")
                        }
                    }
                    if !feedback.isEmpty { Text(feedback).multilineTextAlignment(.center).accessibilityIdentifier("families.hint") }
                }
            }
        }
        .id(play.index)
        .onAppear { if !started { restart(); started = true } }
        .onDisappear { narrator.stop() }
    }
    private func familyPicture(_ family: AnimalFamily) -> some View {
        HStack(spacing: 0) {
            Image(family.adultArt).resizable().scaledToFit()
            Image(family.babyArt).resizable().scaledToFit().scaleEffect(0.72, anchor: .bottom)
        }.padding(8).accessibilityHidden(true)
    }
    private func restart() {
        narrator.stop(); feedback = ""
        play = AnimalFamilySession(previousFirst: previousFirst)
        previousFirst = play.rounds[0].family.id
    }
}
