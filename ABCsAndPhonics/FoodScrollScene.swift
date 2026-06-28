//
//  FoodScrollScene.swift
//  LearningLabJr
//

import SpriteKit
import UIKit

private struct FoodScrollOption {
    let image: String
    let name: String
}

private enum FoodScrollOptionsLoader {
    private static let knownAssetNames: [String: String] = [
        "broccoli": "brocoli"
    ]

    private static let fallbackOptions: [FoodScrollOption] = [
        FoodScrollOption(image: "carrot", name: "Carrot"),
        FoodScrollOption(image: "onion", name: "Onion"),
        FoodScrollOption(image: "tomato", name: "Tomato"),
        FoodScrollOption(image: "brocoli", name: "Broccoli")
    ]

    static func loadOptions() -> [FoodScrollOption] {
        guard let csv = loadCategoriesText() else {
            return availableOptions(from: fallbackOptions)
        }

        let rows = parseCSV(csv)
        guard let headers = rows.first, rows.count > 1 else {
            return availableOptions(from: fallbackOptions)
        }

        let normalizedHeaders = headers.map(normalizeHeader)
        let imageIndex = 0
        guard let foodIndex = normalizedHeaders.firstIndex(of: "food") else {
            return availableOptions(from: fallbackOptions)
        }

        let inAppIndex = normalizedHeaders.firstIndex(of: "inapp")
        let nameIndex = normalizedHeaders.firstIndex(of: "name")

        let options = rows.dropFirst().compactMap { row -> FoodScrollOption? in
            guard row.indices.contains(imageIndex),
                  row.indices.contains(foodIndex),
                  isMarked(row[foodIndex]) else {
                return nil
            }

            if let inAppIndex,
               row.indices.contains(inAppIndex),
               !isMarked(row[inAppIndex]) {
                return nil
            }

            let csvImage = row[imageIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !csvImage.isEmpty else { return nil }

            let image = knownAssetNames[csvImage.lowercased()] ?? csvImage
            let name: String
            if let nameIndex, row.indices.contains(nameIndex) {
                let value = row[nameIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                name = value.isEmpty ? displayName(from: csvImage) : value
            } else {
                name = displayName(from: csvImage)
            }

            return FoodScrollOption(image: image, name: name)
        }

        let available = availableOptions(from: options)
        return available.isEmpty ? availableOptions(from: fallbackOptions) : available
    }

    private static func availableOptions(from options: [FoodScrollOption]) -> [FoodScrollOption] {
        options.filter { SKTexture(imageNamed: $0.image).size() != .zero }
    }

    private static func loadCategoriesText() -> String? {
        let resourceNames = [
            ("LearningLabAppCategories", "csv"),
            ("LearningLabAppCategories", "tsv"),
            ("LearningLabAppCategories", "txt")
        ]

        for resource in resourceNames {
            guard let url = Bundle.main.url(forResource: resource.0, withExtension: resource.1),
                  let text = try? String(contentsOf: url, encoding: .utf8) else {
                continue
            }

            return text
        }

        return nil
    }

    private static func parseCSV(_ text: String) -> [[String]] {
        let delimiter: Character = text.contains("\t") ? "\t" : ","
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var isQuoted = false
        var index = text.startIndex

        while index < text.endIndex {
            let character = text[index]
            let nextIndex = text.index(after: index)

            if character == "\"" {
                if isQuoted, nextIndex < text.endIndex, text[nextIndex] == "\"" {
                    field.append("\"")
                    index = text.index(after: nextIndex)
                    continue
                } else {
                    isQuoted.toggle()
                }
            } else if character == delimiter, !isQuoted {
                row.append(field)
                field = ""
            } else if character == "\n", !isQuoted {
                row.append(field)
                rows.append(row)
                row = []
                field = ""
            } else if character != "\r" {
                field.append(character)
            }

            index = nextIndex
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }

        return rows
    }

    private static func normalizeHeader(_ header: String) -> String {
        header
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private static func isMarked(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "x" || normalized == "yes" || normalized == "true" || normalized == "1"
    }

    private static func displayName(from image: String) -> String {
        image
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + String($0.dropFirst()) }
            .joined(separator: " ")
    }
}

final class FoodScrollScene: SKScene {
    private let maxCount = 10

    private var radius: CGFloat = 300
    private var rotationAngle: CGFloat = 0
    private var angularVelocity: CGFloat = 0
    private var lastTime: TimeInterval = 0
    private var cardSize = CGSize(width: 200, height: 260)

    private let container = SKNode()
    private var slots: [CardSlot] = []
    private weak var panGesture: UIPanGestureRecognizer?

    private struct CardSlot {
        let node: FoodScrollCard
        let baseAngle: CGFloat
    }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0)
        configureLayout()
        addBackground()
        addChild(container)
        buildCards()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(pan)
        panGesture = pan

        projectSlots()
    }

    override func willMove(from view: SKView) {
        if let panGesture {
            view.removeGestureRecognizer(panGesture)
        }
    }

    private func configureLayout() {
        let shortestSide = min(size.width, size.height)
        cardSize = CGSize(
            width: min(220, max(168, shortestSide * 0.46)),
            height: min(280, max(220, size.height * 0.32))
        )
        radius = max(cardSize.height * 0.92, size.height * 0.36)
    }

    private func addBackground() {
        let background = SKSpriteNode(imageNamed: "PlayfulBackground")
        if background.texture?.size() == .zero {
            return
        }

        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -10
        addChild(background)
    }

    private func buildCards() {
        slots.removeAll()
        container.removeAllChildren()

        var combos: [(FoodScrollOption, Int)] = []
        for option in FoodScrollOptionsLoader.loadOptions() {
            for count in 1...maxCount {
                combos.append((option, count))
            }
        }

        guard !combos.isEmpty else { return }

        let step = 2 * CGFloat.pi / CGFloat(combos.count)
        for (index, combo) in combos.enumerated() {
            let card = FoodScrollCard(cardSize: cardSize)
            card.configure(food: combo.0, count: combo.1)
            container.addChild(card)
            slots.append(CardSlot(node: card, baseAngle: CGFloat(index) * step))
        }
    }

    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch gesture.state {
        case .began:
            angularVelocity = 0
        case .changed:
            let dy = -gesture.translation(in: view).y
            gesture.setTranslation(.zero, in: view)
            rotationAngle += dy / radius
        case .ended, .cancelled:
            let velocity = -gesture.velocity(in: view).y
            angularVelocity = velocity / radius * 0.02
        default:
            break
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if lastTime == 0 {
            lastTime = currentTime
            return
        }

        let dt = currentTime - lastTime
        lastTime = currentTime

        if abs(angularVelocity) > 0.01 {
            rotationAngle += angularVelocity * CGFloat(dt)
            angularVelocity *= pow(0.9, CGFloat(dt * 60))
        }

        projectSlots()
    }

    private func projectSlots() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        for slot in slots {
            let angle = slot.baseAngle + rotationAngle
            let depth = cos(angle)
            let scale = 0.42 + 0.58 * max(0, depth)
            let y = center.y + radius * sin(angle)

            slot.node.position = CGPoint(x: center.x, y: y)
            slot.node.setScale(scale)
            slot.node.alpha = 0.22 + 0.78 * max(0, depth)
            slot.node.zPosition = scale * 100
        }
    }
}

private final class FoodScrollCard: SKNode {
    private let cardSize: CGSize
    private let background: SKShapeNode
    private let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var images: [SKSpriteNode] = []

    init(cardSize: CGSize) {
        self.cardSize = cardSize
        background = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
        super.init()

        background.fillColor = .white
        background.strokeColor = UIColor(red: 0.18, green: 0.45, blue: 0.78, alpha: 1.0)
        background.lineWidth = 3
        background.alpha = 0.94
        addChild(background)

        label.fontSize = min(24, cardSize.width * 0.11)
        label.fontColor = UIColor(red: 0.08, green: 0.18, blue: 0.32, alpha: 1.0)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: cardSize.height / 2 - 26)
        addChild(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(food: FoodScrollOption, count: Int) {
        label.text = "\(count) \(displayName(for: food.name, count: count))"
        images.forEach { $0.removeFromParent() }
        images.removeAll()

        let perRow = 3
        let spacing = cardSize.width * 0.045
        let imageSide = min(54, cardSize.width * 0.25)
        let topY = cardSize.height / 2 - 68

        for index in 0..<count {
            let row = index / perRow
            let col = index % perRow
            let itemsInRow = min(perRow, count - row * perRow)
            let rowWidth = CGFloat(itemsInRow) * imageSide + CGFloat(itemsInRow - 1) * spacing
            let startX = -rowWidth / 2 + imageSide / 2

            let sprite = SKSpriteNode(imageNamed: food.image)
            sprite.size = CGSize(width: imageSide, height: imageSide)
            sprite.position = CGPoint(
                x: startX + CGFloat(col) * (imageSide + spacing),
                y: topY - CGFloat(row) * (imageSide + spacing)
            )
            addChild(sprite)
            images.append(sprite)
        }
    }

    private func displayName(for name: String, count: Int) -> String {
        guard count != 1 else { return name }

        let lowercased = name.lowercased()
        if lowercased.hasSuffix("s") {
            return name
        }

        return "\(name)s"
    }
}
