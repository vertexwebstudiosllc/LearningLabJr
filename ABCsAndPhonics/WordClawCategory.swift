import SwiftUI

enum WordClawCategory: String, CaseIterable, Identifiable {
    case sports, animals, nature, things
    var id: String { rawValue }
    var title: String {
        switch self { case .sports: "Sports"; case .animals: "Animals"; case .nature: "Nature & space"; case .things: "Everyday things" }
    }
    var symbol: String {
        switch self { case .sports: "basketball.fill"; case .animals: "pawprint.fill"; case .nature: "leaf.fill"; case .things: "lamp.table.fill" }
    }
    var options: [ClawImageOption] {
        let words: [String]
        switch self {
        case .sports: return ClawImageOptionsLoader.loadOptions()
        case .animals: words = ["Cat", "Dog", "Cow", "Duck", "Hen", "Crab", "Seal", "Fish"]
        case .nature: words = ["Flower", "Tree", "Leaf", "Butterfly", "Moon", "Star", "Earth", "Rocket"]
        case .things: words = ["Book", "Cup", "Bowl", "Spoon", "Teddy bear", "Bell", "Clock", "Lamp"]
        }
        return words.map { ClawImageOption(image: "vocabulary:" + $0.lowercased(), name: $0) }
    }
}
