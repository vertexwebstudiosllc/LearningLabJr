import Foundation
import SpriteKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private struct WordBuilderOption: Equatable {
    let imageName: String
    let displayName: String

    var spellingWord: String {
        displayName.filter { $0.isLetter }.uppercased()
    }
}

private enum WordBuilderOptionsLoader {
    static func loadOptions() -> [WordBuilderOption] {
        guard let url = Bundle.main.url(forResource: "LearningLabAppCategories", withExtension: "csv")
            ?? Bundle.main.url(forResource: "LearningLabAppCategories", withExtension: "txt")
            ?? Bundle.main.url(forResource: "LearningLabAppCategories", withExtension: "tsv"),
              let text = try? String(contentsOf: url) else {
            return fallbackOptions
        }

        let rows = parseRows(from: text)
        guard let header = rows.first else {
            return fallbackOptions
        }

        let normalizedHeader = header.map(normalizeHeader)
        let inAppIndex = normalizedHeader.firstIndex(of: "inapp")
        let nameIndex = normalizedHeader.firstIndex(of: "name")
        var seenImages = Set<String>()

        let options = rows.dropFirst().compactMap { row -> WordBuilderOption? in
            guard let imageName = row.first?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !imageName.isEmpty else {
                return nil
            }

            if let inAppIndex, !isMarked(row[safe: inAppIndex]) {
                return nil
            }

            guard seenImages.insert(imageName.lowercased()).inserted else {
                return nil
            }

            let name = row[safe: nameIndex ?? -1].flatMap { value -> String? in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            } ?? displayName(from: imageName)

            let option = WordBuilderOption(imageName: imageName, displayName: name)
            guard option.spellingWord.count >= 3 else {
                return nil
            }

            return option
        }

        let availableOptions = options.filter { option in
            SKTexture(imageNamed: option.imageName).size() != .zero
        }

        return availableOptions.isEmpty ? fallbackOptions : availableOptions
    }

    private static var fallbackOptions: [WordBuilderOption] {
        [
            WordBuilderOption(imageName: "cow", displayName: "Cow"),
            WordBuilderOption(imageName: "pig", displayName: "Pig"),
            WordBuilderOption(imageName: "horse", displayName: "Horse"),
            WordBuilderOption(imageName: "duck", displayName: "Duck"),
            WordBuilderOption(imageName: "apple", displayName: "Apple"),
            WordBuilderOption(imageName: "onion", displayName: "Onion")
        ]
    }

    private static func parseRows(from text: String) -> [[String]] {
        let delimiter: Character = text.contains("\t") ? "\t" : ","
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        var iterator = text.makeIterator()

        while let character = iterator.next() {
            if character == "\"" {
                if inQuotes, let next = iterator.next() {
                    if next == "\"" {
                        field.append(next)
                    } else {
                        inQuotes = false
                        if next == delimiter {
                            row.append(field)
                            field = ""
                        } else if next == "\n" || next == "\r" {
                            row.append(field)
                            field = ""
                            if !row.allSatisfy({ $0.isEmpty }) {
                                rows.append(row)
                            }
                            row = []
                        } else {
                            field.append(next)
                        }
                    }
                } else {
                    inQuotes.toggle()
                }
            } else if character == delimiter, !inQuotes {
                row.append(field)
                field = ""
            } else if (character == "\n" || character == "\r"), !inQuotes {
                row.append(field)
                field = ""
                if !row.allSatisfy({ $0.isEmpty }) {
                    rows.append(row)
                }
                row = []
            } else {
                field.append(character)
            }
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            if !row.allSatisfy({ $0.isEmpty }) {
                rows.append(row)
            }
        }

        return rows
    }

    private static func normalizeHeader(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private static func isMarked(_ value: String?) -> Bool {
        guard let value else { return false }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "x" || normalized == "yes" || normalized == "true" || normalized == "1"
    }

    private static func displayName(from imageName: String) -> String {
        let normalized = imageName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        var words: [String] = []
        var current = ""
        var previousWasLowercase = false

        for character in normalized {
            if character == " " {
                if !current.isEmpty {
                    words.append(current)
                    current = ""
                }
                previousWasLowercase = false
            } else {
                if previousWasLowercase, character.isUppercase {
                    words.append(current)
                    current = ""
                }
                current.append(character)
                previousWasLowercase = character.isLowercase
            }
        }

        if !current.isEmpty {
            words.append(current)
        }

        return words.map { word in
            word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

final class WordBuilderScene: SKScene {
    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)
    private var options: [WordBuilderOption] = WordBuilderOptionsLoader.loadOptions()
    private var currentOption: WordBuilderOption?
    private var currentLetters: [String] = []
    private var missingIndex: Int = 0
    private var correctLetter = ""
    private var isResolving = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.91, green: 0.97, blue: 0.98, alpha: 1)
        startRound()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        renderRound()
    }

    private func startRound() {
        guard !options.isEmpty else { return }

        let previousOption = currentOption
        var nextOption = options.randomElement() ?? options[0]
        if options.count > 1 {
            while nextOption == previousOption {
                nextOption = options.randomElement() ?? options[0]
            }
        }

        currentOption = nextOption
        currentLetters = nextOption.spellingWord.map(String.init)
        missingIndex = Int.random(in: 0..<currentLetters.count)
        correctLetter = currentLetters[missingIndex]
        isResolving = false
        renderRound()
    }

    private func renderRound(feedback: String? = nil, feedbackColor: SKColor = .clear, revealWord: Bool = false) {
        removeAllChildren()
        addBackground()

        guard let option = currentOption else { return }

        let safeWidth = max(size.width, 1)
        let safeHeight = max(size.height, 1)
        let centerX = safeWidth / 2

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Word Builder"
        title.fontSize = min(44, safeWidth * 0.075)
        title.fontColor = SKColor(red: 0.08, green: 0.28, blue: 0.38, alpha: 1)
        title.position = CGPoint(x: centerX, y: safeHeight * 0.9)
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        addChild(title)

        let imageCard = SKShapeNode(rectOf: CGSize(width: safeWidth * 0.52, height: safeHeight * 0.32), cornerRadius: 28)
        imageCard.fillColor = .white
        imageCard.strokeColor = SKColor(red: 0.64, green: 0.85, blue: 0.89, alpha: 1)
        imageCard.lineWidth = 5
        imageCard.position = CGPoint(x: centerX, y: safeHeight * 0.68)
        addChild(imageCard)

        let itemSprite = SKSpriteNode(imageNamed: option.imageName)
        fit(itemSprite, maxWidth: safeWidth * 0.44, maxHeight: safeHeight * 0.26)
        itemSprite.position = imageCard.position
        addChild(itemSprite)

        let wordCard = SKShapeNode(rectOf: CGSize(width: safeWidth * 0.7, height: safeHeight * 0.12), cornerRadius: 22)
        wordCard.fillColor = SKColor(red: 1, green: 0.98, blue: 0.83, alpha: 1)
        wordCard.strokeColor = SKColor(red: 0.96, green: 0.72, blue: 0.22, alpha: 1)
        wordCard.lineWidth = 5
        wordCard.position = CGPoint(x: centerX, y: safeHeight * 0.43)
        addChild(wordCard)

        let wordLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        wordLabel.text = displayWord(revealWord: revealWord)
        wordLabel.fontSize = min(58, safeWidth * 0.095)
        wordLabel.fontColor = SKColor(red: 0.14, green: 0.18, blue: 0.27, alpha: 1)
        wordLabel.position = wordCard.position
        wordLabel.horizontalAlignmentMode = .center
        wordLabel.verticalAlignmentMode = .center
        addChild(wordLabel)

        if let feedback {
            let feedbackLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            feedbackLabel.text = feedback
            feedbackLabel.fontSize = min(38, safeWidth * 0.065)
            feedbackLabel.fontColor = feedbackColor
            feedbackLabel.position = CGPoint(x: centerX, y: safeHeight * 0.33)
            feedbackLabel.horizontalAlignmentMode = .center
            feedbackLabel.verticalAlignmentMode = .center
            addChild(feedbackLabel)
        }

        addLetterChoices(at: CGPoint(x: centerX, y: safeHeight * 0.18), in: CGSize(width: safeWidth, height: safeHeight))
    }

    private func addBackground() {
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor(red: 0.91, green: 0.97, blue: 0.98, alpha: 1)
        background.strokeColor = .clear
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -10
        addChild(background)
    }

    private func addLetterChoices(at center: CGPoint, in canvasSize: CGSize) {
        let answers = shuffledAnswers()
        let cardSize = CGSize(width: canvasSize.width * 0.19, height: canvasSize.height * 0.15)
        let gap = canvasSize.width * 0.055
        let totalWidth = cardSize.width * 3 + gap * 2
        let startX = center.x - totalWidth / 2 + cardSize.width / 2

        for (index, letter) in answers.enumerated() {
            let x = startX + CGFloat(index) * (cardSize.width + gap)
            let card = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
            card.fillColor = .white
            card.strokeColor = SKColor(red: 0.38, green: 0.68, blue: 0.82, alpha: 1)
            card.lineWidth = 5
            card.position = CGPoint(x: x, y: center.y)
            card.name = "letter:\(letter)"
            addChild(card)

            let letterSprite = SKSpriteNode(imageNamed: letter)
            fit(letterSprite, maxWidth: cardSize.width * 0.68, maxHeight: cardSize.height * 0.78)
            letterSprite.position = card.position
            letterSprite.name = card.name
            addChild(letterSprite)
        }
    }

    private func shuffledAnswers() -> [String] {
        let distractors = alphabet.filter { $0 != correctLetter }.shuffled().prefix(2)
        return ([correctLetter] + distractors).shuffled()
    }

    private func displayWord(revealWord: Bool) -> String {
        currentLetters.enumerated().map { index, letter in
            if !revealWord, index == missingIndex {
                return "_"
            }
            return letter
        }.joined(separator: " ")
    }

#if canImport(UIKit)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isResolving, let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }
#elseif canImport(AppKit)
    override func mouseUp(with event: NSEvent) {
        guard !isResolving else { return }
        handleTap(at: event.location(in: self))
    }
#endif

    private func handleTap(at location: CGPoint) {
        for node in nodes(at: location) {
            var candidate: SKNode? = node
            while let current = candidate {
                if let name = current.name, name.hasPrefix("letter:") {
                    let letter = String(name.dropFirst("letter:".count))
                    handleSelection(letter, selectedNode: current)
                    return
                }
                candidate = current.parent
            }
        }
    }

    private func handleSelection(_ letter: String, selectedNode: SKNode) {
        guard let option = currentOption else { return }
        isResolving = true

        if letter == correctLetter {
            flash(node: selectedNode, color: SKColor(red: 0.24, green: 0.76, blue: 0.36, alpha: 1))
            renderRound(feedback: "Correct!", feedbackColor: SKColor(red: 0.12, green: 0.5, blue: 0.22, alpha: 1), revealWord: true)
            ItemSoundManager.shared.playSound(for: option.imageName, displayName: option.displayName)
            run(.sequence([
                .wait(forDuration: 1.25),
                .run { [weak self] in self?.startRound() }
            ]))
        } else {
            flash(node: selectedNode, color: SKColor(red: 0.96, green: 0.22, blue: 0.25, alpha: 1))
            renderRound(feedback: "Try again!", feedbackColor: SKColor(red: 0.75, green: 0.12, blue: 0.15, alpha: 1))
            run(.sequence([
                .wait(forDuration: 0.75),
                .run { [weak self] in
                    self?.isResolving = false
                    self?.renderRound()
                }
            ]))
        }
    }

    private func flash(node: SKNode, color: SKColor) {
        guard let shape = node as? SKShapeNode else { return }
        let originalColor = shape.fillColor
        shape.run(.sequence([
            .run { shape.fillColor = color },
            .wait(forDuration: 0.12),
            .run { shape.fillColor = originalColor }
        ]))
    }

    private func fit(_ sprite: SKSpriteNode, maxWidth: CGFloat, maxHeight: CGFloat) {
        guard sprite.size.width > 0, sprite.size.height > 0 else { return }
        let scale = min(maxWidth / sprite.size.width, maxHeight / sprite.size.height)
        sprite.setScale(scale)
    }
}
