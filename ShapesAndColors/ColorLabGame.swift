import SwiftUI

struct LabPaint: Identifiable, Hashable {
    let id: String
    let name: String
    let red: Double
    let green: Double
    let blue: Double
    var color: Color { Color(red: red, green: green, blue: blue) }
    var ink: Color { 0.2126 * red + 0.7152 * green + 0.0722 * blue > 0.56 ? .black : .white }
    var selectionPrompt: String { "\(name) paint selected." }

    static let bank: [LabPaint] = [
        .init(id: "red", name: "Red", red: 0.92, green: 0.13, blue: 0.17),
        .init(id: "yellow", name: "Yellow", red: 1, green: 0.86, blue: 0.08),
        .init(id: "blue", name: "Blue", red: 0.08, green: 0.36, blue: 0.94),
        .init(id: "orange", name: "Orange", red: 1, green: 0.46, blue: 0.06),
        .init(id: "green", name: "Green", red: 0.12, green: 0.65, blue: 0.3),
        .init(id: "purple", name: "Purple", red: 0.55, green: 0.22, blue: 0.78),
        .init(id: "white", name: "White", red: 1, green: 1, blue: 1),
        .init(id: "black", name: "Black", red: 0.06, green: 0.06, blue: 0.08),
        .init(id: "gray", name: "Gray", red: 0.48, green: 0.48, blue: 0.5),
        .init(id: "pink", name: "Pink", red: 1, green: 0.42, blue: 0.72),
        .init(id: "brown", name: "Brown", red: 0.5, green: 0.28, blue: 0.13),
        .init(id: "peach", name: "Peach", red: 1, green: 0.74, blue: 0.53),
        .init(id: "dark-orange", name: "Dark orange", red: 0.65, green: 0.26, blue: 0.04),
        .init(id: "sky-blue", name: "Sky blue", red: 0.48, green: 0.77, blue: 1),
        .init(id: "navy", name: "Navy", red: 0.04, green: 0.1, blue: 0.32),
        .init(id: "dark-red", name: "Dark red", red: 0.45, green: 0.05, blue: 0.09),
        .init(id: "cream", name: "Cream", red: 1, green: 0.96, blue: 0.69),
        .init(id: "ochre", name: "Ochre", red: 0.61, green: 0.46, blue: 0.07),
        .init(id: "light-green", name: "Light green", red: 0.6, green: 0.86, blue: 0.58),
        .init(id: "dark-green", name: "Dark green", red: 0.04, green: 0.29, blue: 0.13),
        .init(id: "lavender", name: "Lavender", red: 0.79, green: 0.65, blue: 0.94),
        .init(id: "dark-purple", name: "Dark purple", red: 0.25, green: 0.08, blue: 0.38),
        .init(id: "light-pink", name: "Light pink", red: 1, green: 0.76, blue: 0.88),
        .init(id: "dark-pink", name: "Dark pink", red: 0.67, green: 0.18, blue: 0.39),
        .init(id: "tan", name: "Tan", red: 0.78, green: 0.62, blue: 0.44),
        .init(id: "dark-brown", name: "Dark brown", red: 0.25, green: 0.13, blue: 0.06),
    ]
    static func named(_ id: String) -> LabPaint { bank.first { $0.id == id }! }
}

struct LabRecipe: Identifiable {
    let first: String
    let second: String
    let output: String
    var id: String { output }
    var ingredients: Set<String> { [first, second] }
    var result: LabPaint { .named(output) }
    var success: String { "\(LabPaint.named(first).name) and \(LabPaint.named(second).name.lowercased()) make \(result.name.lowercased())!" }
    var suggestion: String { "Try \(LabPaint.named(first).name.lowercased()) and \(LabPaint.named(second).name.lowercased())." }
}

struct LabLevel {
    let title: String
    let paints: [String]
    let recipes: [LabRecipe]
    var prompt: String {
        let names = paints.map { LabPaint.named($0).name.lowercased() }
        return "Let's mix \(names[0]), \(names[1]), and \(names[2]). Choose two different paints, then stir."
    }
    static let levels: [LabLevel] = [
        .init(title: "First mixes", paints: ["red", "yellow", "blue"], recipes: [
            .init(first: "red", second: "yellow", output: "orange"),
            .init(first: "yellow", second: "blue", output: "green"),
            .init(first: "blue", second: "red", output: "purple"),
        ]),
        .init(title: "Orange shades", paints: ["orange", "white", "black"], recipes: [
            .init(first: "orange", second: "white", output: "peach"),
            .init(first: "orange", second: "black", output: "dark-orange"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Blue shades", paints: ["blue", "white", "black"], recipes: [
            .init(first: "blue", second: "white", output: "sky-blue"),
            .init(first: "blue", second: "black", output: "navy"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Red shades", paints: ["red", "white", "black"], recipes: [
            .init(first: "red", second: "white", output: "pink"),
            .init(first: "red", second: "black", output: "dark-red"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Yellow shades", paints: ["yellow", "white", "black"], recipes: [
            .init(first: "yellow", second: "white", output: "cream"),
            .init(first: "yellow", second: "black", output: "ochre"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Green shades", paints: ["green", "white", "black"], recipes: [
            .init(first: "green", second: "white", output: "light-green"),
            .init(first: "green", second: "black", output: "dark-green"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Purple shades", paints: ["purple", "white", "black"], recipes: [
            .init(first: "purple", second: "white", output: "lavender"),
            .init(first: "purple", second: "black", output: "dark-purple"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Pink shades", paints: ["pink", "white", "black"], recipes: [
            .init(first: "pink", second: "white", output: "light-pink"),
            .init(first: "pink", second: "black", output: "dark-pink"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
        .init(title: "Brown shades", paints: ["brown", "white", "black"], recipes: [
            .init(first: "brown", second: "white", output: "tan"),
            .init(first: "brown", second: "black", output: "dark-brown"),
            .init(first: "black", second: "white", output: "gray"),
        ]),
    ]
}

struct ColorLabSession {
    private(set) var levelIndex = 0
    private(set) var selected: [String] = []
    private(set) var discoveries: Set<String> = []
    private(set) var result: LabPaint?
    var level: LabLevel { LabLevel.levels[min(levelIndex, LabLevel.levels.count - 1)] }
    var finished: Bool { levelIndex == LabLevel.levels.count }
    var levelComplete: Bool { discoveries.count == level.recipes.count }
    static let completion = "You explored all the color levels! So many colors to discover!"
    static let levelSuccess = "You found all three mixtures! Let's try the next color level."
    static let chooseTwo = "Choose two different paint colors first."
    // Keep the spoken prompt stable while mixing so it cannot interrupt result narration.
    var prompt: String { finished ? Self.completion : level.prompt }
    var suggestion: String {
        level.recipes.first { !discoveries.contains($0.output) }?.suggestion ?? "All three mixtures discovered!"
    }
    mutating func select(_ id: String) {
        guard !finished, !levelComplete, level.paints.contains(id) else { return }
        result = nil
        if let index = selected.firstIndex(of: id) { selected.remove(at: index) }
        else {
            if selected.count == 2 { selected.removeFirst() }
            selected.append(id)
        }
    }
    @discardableResult
    mutating func mix() -> LabRecipe? {
        guard !finished, !levelComplete, selected.count == 2,
              let recipe = level.recipes.first(where: { $0.ingredients == Set(selected) }) else { return nil }
        result = recipe.result
        discoveries.insert(recipe.output)
        selected = []
        return recipe
    }
    mutating func next() {
        guard !finished, levelComplete else { return }
        levelIndex += 1
        if !finished { discoveries = []; selected = []; result = nil }
    }
}

struct ColorLabGame: View {
    let onReplay: () -> Void
    @State private var lab = ColorLabSession()
    @State private var note = "Predict what the paints might make."
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Little Color Lab", prompt: lab.prompt, accent: .purple, completion: lab.finished, onReplay: onReplay) {
            Text("Level \(min(lab.levelIndex + 1, LabLevel.levels.count)) of \(LabLevel.levels.count) · \(lab.level.title)")
                .font(.system(.headline, design: .rounded))
                .accessibilityIdentifier("shapes.lab.level")
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(lab.result?.color ?? Color.white)
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2))
                    Image(systemName: "paintbrush.pointed.fill").font(.system(size: 48))
                        .foregroundStyle(lab.result?.ink ?? Color.black)
                }.frame(width: 120, height: 120).accessibilityHidden(true)
                Text(lab.result?.name ?? "Mixing bowl").font(.headline)
                    .accessibilityIdentifier("shapes.lab.result")
            }
            Text(lab.suggestion).font(.subheadline).multilineTextAlignment(.center)
            HStack(spacing: 10) {
                ForEach(lab.level.paints, id: \.self) { id in
                    paintButton(LabPaint.named(id))
                }
            }
            if !lab.levelComplete {
                ToddlerActionButton(title: "Stir the paints", systemImage: "arrow.triangle.2.circlepath", color: .purple) {
                    guard let recipe = lab.mix() else { narrator.speak(ColorLabSession.chooseTwo); return }
                    note = recipe.success
                    narrator.speak(note)
                }.accessibilityIdentifier("shapes.lab.stir")
            }
            HStack(alignment: .top, spacing: 8) {
                ForEach(lab.level.recipes) { recipe in
                    VStack(spacing: 6) {
                        Circle().fill(recipe.result.color).frame(width: 42, height: 42)
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .overlay {
                                Image(systemName: lab.discoveries.contains(recipe.output) ? "checkmark" : "questionmark")
                                    .foregroundStyle(recipe.result.ink)
                            }
                        Text(recipe.result.name).font(.system(.caption, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(recipe.result.name), \(lab.discoveries.contains(recipe.output) ? "discovered" : "not mixed yet")")
                }
            }
            Text("\(lab.discoveries.count) of 3 mixtures discovered")
                .font(.subheadline).accessibilityIdentifier("shapes.lab.progress")
            SCNote(text: note)
            if lab.levelComplete && !lab.finished {
                ToddlerActionButton(title: lab.levelIndex == LabLevel.levels.count - 1 ? "Finish our color lab" : "Next color level", systemImage: "arrow.right", color: .purple) {
                    lab.next()
                    note = "Predict what the paints might make."
                }.accessibilityIdentifier("shapes.lab.next")
            }
        }
    }
    private func paintButton(_ paint: LabPaint) -> some View {
        Button {
            let wasSelected = lab.selected.contains(paint.id)
            lab.select(paint.id)
            if !wasSelected { narrator.speak(paint.selectionPrompt) }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: lab.selected.contains(paint.id) ? "checkmark.circle.fill" : "drop.fill")
                    .font(.system(size: 28))
                Text(paint.name).font(.system(.subheadline, design: .rounded, weight: .bold))
            }.foregroundStyle(paint.ink).frame(maxWidth: .infinity, minHeight: 85)
                .background(paint.color, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.4), lineWidth: 2))
        }.buttonStyle(.plain).disabled(lab.levelComplete)
            .accessibilityLabel("\(paint.name) paint")
            .accessibilityAddTraits(lab.selected.contains(paint.id) ? .isSelected : [])
            .accessibilityIdentifier("shapes.lab.paint.\(paint.id)")
    }
}
