import Foundation

enum GentleKind: String, CaseIterable { case flower, feather, flowers, teddy, turtle, pond, listening, kindwords }
struct GentleLevel: Identifiable {
    let kind: GentleKind
    let title: String
    let prompts: [String]
    let success: String
    var id: String { kind.rawValue }
    static let bank: [Self] = [
        .init(kind: .flower, title: "Flower breathing", prompts: ["Let's smell our pretend flower. Take an easy, comfortable breath in, or watch your grown-up. Tap when you are ready.", "Let your breath out comfortably, like a little breeze. There is no need to hold your breath. Tap when you are ready.", "Here is another flower. Try an easy breath in, or watch together. Go at your own pace.", "Let the air out gently. Your flower can rest with you. Tap whenever you are ready.", "One more pretend flower. Take a comfortable breath in, or just watch your grown-up.", "Let that breath out easily. Let your shoulders rest. Tap when you are ready."], success: "A flower and a little breeze are one way to practice a gentle moment together."),
        .init(kind: .feather, title: "Drifting feather", prompts: ["Watch our pretend feather. Move a finger slowly toward the first glowing cloud, then tap it.", "Our feather is floating. Move your finger toward the next glowing cloud at your own pace.", "Follow the feather to the last glowing cloud. Let your hand come to a gentle rest."], success: "Slow finger movements are another gentle thing we can try together."),
        .init(kind: .flowers, title: "Gentle hands", prompts: ["Let's practice gentle hands. Tap any flower bud softly to help it open. You do not need to press hard.", "Look at that flower opening. Choose another bud and try a light touch.", "One bud is waiting. Give it a gentle tap, then let your hands rest."], success: "Gentle hands can help us care for toys and people. Ask before touching another person."),
        .init(kind: .teddy, title: "Tuck in Teddy", prompts: ["Our pretend Teddy wants a cozy blanket. Move the blanket onto Teddy, or tap tuck Teddy in. Imagine placing it gently."], success: "Teddy has a cozy place to rest. We can offer care with gentle hands."),
        .init(kind: .turtle, title: "Slow turtle steps", prompts: ["Let's move like a slow turtle. Walk two fingers to the first glowing stepping stone, then tap it.", "Take a little pause if you like. Walk your fingers to the next glowing stone and tap.", "One more small step. Move to the last glowing stone, tap it, and let your fingers rest."], success: "We explored moving slowly and choosing when to pause."),
        .init(kind: .pond, title: "Quiet pond", prompts: ["Let's visit a pretend pond. Tap any lily pad gently and watch a circle appear in the water.", "Look at the circle in the water. Choose another lily pad for a gentle tap.", "One lily pad is waiting. Tap it, then take a moment to look at the quiet pond."], success: "Noticing colors and shapes can be a gentle way to spend a moment together."),
        .init(kind: .listening, title: "Listen together", prompts: ["Sit comfortably with your grown-up. If you like, notice a quiet sound around you. You can also look at our leaves.", "What did you notice? You can tell your grown-up, point to something, or just enjoy a quiet moment. Tap when you are ready."], success: "We took a moment to notice what was around us. Everyone may notice different things."),
        .init(kind: .kindwords, title: "Kind words", prompts: ["Gentle words can show care. Pick something our puppet could say. All three choices are kind."], success: "Kind words are one way to care for someone. We can ask what they need."),
    ]
    static var narration: [String] { bank.flatMap { $0.prompts + [$0.success] } + GentleWords.bank.map(\.narration) }
}
struct GentleWords: Identifiable {
    let id: String
    let title: String
    let narration: String
    static let bank: [Self] = [
        .init(id: "help", title: "Would you like help?", narration: "Would you like help? We can offer, then listen to the answer."),
        .init(id: "space", title: "Would you like some space?", narration: "Would you like some space? We can give someone room when they ask."),
        .init(id: "together", title: "Shall we sit together?", narration: "Shall we sit together? We can invite someone to join us, and let them choose."),
    ]
}
struct GentlePlay {
    private(set) var index = 0
    private(set) var step = 0
    private(set) var touched: Set<Int> = []
    private(set) var watched = false
    private(set) var word: GentleWords?
    var complete: Bool { index == GentleLevel.bank.count }
    var current: GentleLevel { GentleLevel.bank[min(index, GentleLevel.bank.count - 1)] }
    var finishedLevel: Bool { watched || step == current.prompts.count }
    var prompt: String {
        if complete { return "We did it together! You can play again or choose all done." }
        if let word { return word.narration }
        return finishedLevel ? current.success : current.prompts[step]
    }
    mutating func act(_ target: Int, in level: String, at expectedStep: Int) {
        guard !complete, !finishedLevel, current.id == level, step == expectedStep else { return }
        switch current.kind {
        case .flowers, .pond:
            guard (0..<3).contains(target), !touched.contains(target) else { return }
            touched.insert(target); step = touched.count
        case .kindwords: return
        default:
            guard target == step else { return }
            step += 1
        }
    }
    mutating func dropBlanket(_ items: [String], in level: String, at expectedStep: Int) -> Bool {
        guard items == ["gentle.teddy.blanket"], current.kind == .teddy,
              !complete, !finishedLevel, current.id == level, step == expectedStep else { return false }
        act(step, in: level, at: expectedStep)
        return finishedLevel
    }
    mutating func chooseWord(_ id: String) {
        guard !complete, !finishedLevel, current.kind == .kindwords,
              let choice = GentleWords.bank.first(where: { $0.id == id }) else { return }
        word = choice; step = 1
    }
    mutating func watch(_ level: String) {
        guard !complete, !finishedLevel, current.id == level else { return }
        watched = true
    }
    mutating func advance(_ level: String) {
        guard !complete, finishedLevel, current.id == level else { return }
        index += 1; step = 0; touched = []; watched = false; word = nil
    }
}
