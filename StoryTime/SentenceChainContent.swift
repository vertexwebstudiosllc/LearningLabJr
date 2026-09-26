import Foundation
import Combine

struct SentenceStoryWord: Identifiable, Equatable {
    let id: String
    let title: String
    let art: String
}
struct SentenceStoryPage: Identifiable {
    let id = UUID()
    let words: [SentenceStoryWord]
    var sentence: String { words.map(\.title).joined(separator: " ") + "." }
}

@MainActor
final class SentenceChainSession: ObservableObject {
    nonisolated deinit {}
    static let groups: [[SentenceStoryWord]] = [
        [.init(id: "bunny", title: "Bunny", art: "bunny"), .init(id: "dog", title: "Dog", art: "dog"), .init(id: "cat", title: "Cat", art: "cat")],
        [.init(id: "finds", title: "finds", art: "magnifyingglass"), .init(id: "carries", title: "carries", art: "hand.raised.fill"), .init(id: "looks", title: "looks at", art: "eye.fill")],
        [.init(id: "apple", title: "an apple", art: "apple"), .init(id: "ball", title: "a ball", art: "ball"), .init(id: "book", title: "a book", art: "book")]
    ]
    static let questions = ["Choose who is in your sentence.", "Choose what they do.", "Choose the thing in your sentence."]
    @Published private(set) var pages: [SentenceStoryPage] = []
    @Published private(set) var draft: [SentenceStoryWord] = []
    @Published private(set) var building = true
    @Published private(set) var generation = UUID()
    var ready: Bool { draft.count == 3 }
    var draftSentence: String { draft.map(\.title).joined(separator: " ") + "." }
    var prompt: String {
        if !building { return pages.last?.sentence ?? Self.questions[0] }
        return ready ? draftSentence : Self.questions[draft.count]
    }
    var choices: [SentenceStoryWord] { building && !ready ? Self.groups[draft.count] : [] }
    var lines: [String] { pages.map(\.sentence) }
    func choose(_ id: String, generation token: UUID) {
        guard token == generation, let choice = choices.first(where: { $0.id == id }) else { return }
        draft.append(choice); generation = UUID()
    }
    func undoWord() {
        guard building, !draft.isEmpty else { return }
        draft.removeLast(); generation = UUID()
    }
    func addSentence() {
        guard building, ready else { return }
        pages.append(.init(words: draft)); draft = []; building = false; generation = UUID()
    }
    func keepAdding() {
        guard !building else { return }
        building = true; draft = []; generation = UUID()
    }
}
