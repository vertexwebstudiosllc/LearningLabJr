//
//  ClawGameScene.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 8/2/25.
//
import SpriteKit

private struct ClawImageOption {
    let image: String
    let name: String
}

private enum ClawImageOptionsLoader {
    private static let knownAssetNames: [String: String] = [
        "baseball": "baseball",
        "basketball": "basketball",
        "football": "football",
        "golf ball": "golf ball",
        "hockey puck": "hockey puck",
        "tennis ball": "tennis ball",
        "volleyball": "volleyball"
    ]

    private static let fallbackOptions: [ClawImageOption] = [
        ClawImageOption(image: "basketball", name: "Basketball"),
        ClawImageOption(image: "baseball", name: "Baseball"),
        ClawImageOption(image: "football", name: "Football"),
        ClawImageOption(image: "hockey puck", name: "Hockey Puck"),
        ClawImageOption(image: "tennis ball", name: "Tennis Ball"),
        ClawImageOption(image: "golf ball", name: "Golf Ball"),
        ClawImageOption(image: "volleyball", name: "Volleyball")
    ]

    static func loadOptions() -> [ClawImageOption] {
        guard let csv = loadCategoriesText() else {
            return fallbackOptions
        }

        let rows = parseCSV(csv)
        guard let headers = rows.first, rows.count > 1 else {
            return fallbackOptions
        }

        let normalizedHeaders = headers.map(normalizeHeader)
        let imageIndex = 0
        guard let inAppIndex = normalizedHeaders.firstIndex(of: "inapp"),
              let sportIndex = normalizedHeaders.firstIndex(of: "sport")
                ?? normalizedHeaders.firstIndex(of: "sports") else {
            return fallbackOptions
        }

        let nameIndex = normalizedHeaders.firstIndex(of: "name")
        let options = rows.dropFirst().compactMap { row -> ClawImageOption? in
            guard row.indices.contains(imageIndex),
                  row.indices.contains(inAppIndex),
                  row.indices.contains(sportIndex),
                  isMarked(row[inAppIndex]),
                  isMarked(row[sportIndex]) else {
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

            return ClawImageOption(image: image, name: name)
        }

        return options.isEmpty ? fallbackOptions : options
    }

    private static func loadCategoriesText() -> String? {
        let resourceNames = [
            ("LearningLabAppCategories", "csv"),
            ("LearningLabAppCategories", "tsv"),
            ("LearningLabAppCategories", "txt"),
            ("LearningLabAppCategories", "numbers")
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

    private static func normalizeHeader(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private static func isMarked(_ value: String) -> Bool {
        let marker = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return marker == "x" || marker == "yes" || marker == "true" || marker == "1"
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

class ClawGameScene: SKScene {
    // MARK: - Configuration
    private let maxVisibleItemCount = 5
    private let clawSpeed: TimeInterval = 0.3
    private let topInsetRatio: CGFloat = 0.09
    private let bottomInsetRatio: CGFloat = 0.08

    // MARK: - Nodes & State
    private var claw: SKSpriteNode!
    private var bottomItems = [SKSpriteNode]()
    private var originalClawPosition: CGPoint!
    private var isDropping = false

    private let imageOptions = ClawImageOptionsLoader.loadOptions()
    private var itemSide: CGFloat = 0
    private var lastPickedName: String?
    private var grabbedItem: SKSpriteNode?
    private var pickedImages = Set<String>()
    private var dropDistance: CGFloat = 0

    private let rope = SKShapeNode()

    // MARK: - Setup
    override func didMove(to view: SKView) {
        // Background
        let bg = SKSpriteNode(imageNamed: "ClawGameBackground")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.size     = size
        bg.zPosition = -1
        addChild(bg)

        // Rope
        rope.strokeColor = .black
        rope.lineWidth   = 2
        rope.zPosition   = 5
        addChild(rope)

        // Claw
        claw = SKSpriteNode(imageNamed: "Claw")
        claw.size = fittedSize(
            for: claw.texture?.size() ?? claw.size,
            maxWidth: size.width * 0.44,
            maxHeight: size.height * 0.28
        )
        claw.position = CGPoint(x: size.width/2,
                                y: size.height - claw.size.height/2 - size.height * topInsetRatio)
        claw.zPosition = 10
        addChild(claw)
        originalClawPosition = claw.position

        // Compute bottom-row sizing
        let visibleItemCount = min(maxVisibleItemCount, playableOptions.count)
        guard visibleItemCount > 0 else { return }

        let margin       = size.width * 0.05
        let availW       = size.width - margin*2
        let byCount      = availW / CGFloat(visibleItemCount)
        let maxH         = size.height * 0.22
        let maxClawWidth = claw.size.width * 1.08
        itemSide         = min(byCount * 1.42, maxH, maxClawWidth)
        dropDistance     = max(0, originalClawPosition.y - itemSide * 1.25 - size.height * bottomInsetRatio)

        // Spawn bottom-row sports items
        let initialOptions = Array(playableOptions.shuffled().prefix(visibleItemCount))
        let spacing = visibleItemCount > 1 ? availW / CGFloat(visibleItemCount - 1) : 0
        for (index, option) in initialOptions.enumerated() {
            let x = visibleItemCount > 1 ? margin + spacing * CGFloat(index) : size.width / 2
            let y = itemSide / 2 + size.height * bottomInsetRatio
            addBottomItem(option, at: CGPoint(x: x, y: y))
        }

        isUserInteractionEnabled = true
    }

    // MARK: - Draw the rope each frame
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: claw.position.x, y: size.height))
        path.addLine(to: CGPoint(x: claw.position.x,
                                 y: claw.position.y + claw.size.height/2))
        rope.path = path
    }

    // MARK: - Drag the claw
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDropping, let t = touches.first else { return }
        let loc = t.location(in: self)
        let half = claw.size.width/2
        claw.position.x = min(max(loc.x, half), size.width - half)
    }

    // MARK: - Tap handling
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        guard !isDropping else { return }
        isDropping = true

        let tapLocation = touch.location(in: self)
        let tappedItem = bottomItems.first { $0.frame.contains(tapLocation) }
        let disappearedImage = grabbedItem.flatMap { imageName(for: $0) }

        if let old = grabbedItem {
            old.removeFromParent()
            grabbedItem = nil
        }

        let targetX = tappedItem?.position.x ?? claw.position.x
        let moveOverTarget = SKAction.moveTo(x: targetX, duration: 0.2)
        moveOverTarget.timingMode = .easeInEaseOut

        let down = SKAction.moveBy(x: 0, y: -dropDistance, duration: clawSpeed)
        down.timingMode = .easeIn

        let grab = SKAction.run { [weak self] in
            guard let self = self else { return }

            let candidates = self.bottomItems.filter { $0.name != self.lastPickedName }
            guard let item = tappedItem ?? candidates.randomElement() ?? self.bottomItems.randomElement(),
                  let name = item.name else { return }

            let itemImage = self.imageName(for: item)
            self.lastPickedName = name
            if let itemImage {
                self.pickedImages.insert(itemImage)
            }
            let replacementPosition = item.position
            item.removeFromParent()
            if let idx = self.bottomItems.firstIndex(of: item) {
                self.bottomItems.remove(at: idx)
            }

            let grabSide = min(self.itemSide * 1.65, self.size.height * 0.18)
            let grabSize = CGSize(width: grabSide,
                                  height: grabSide)
            item.size = grabSize
            self.claw.addChild(item)
            item.position = CGPoint(x: 0,
                                    y: -self.claw.size.height/2 - grabSide * 0.28)
            item.setScale(0.8)
            item.run(.scale(to: 1.0, duration: 0.1))

            self.grabbedItem = item
            self.showPickedName(name)
            if let itemImage {
                ItemSoundManager.shared.playSound(for: itemImage)
            }
            self.addRandomReplacement(
                excludingSelected: itemImage,
                disappearedImage: disappearedImage,
                at: replacementPosition
            )
        }

        let up = SKAction.move(to: originalClawPosition, duration: clawSpeed)
        up.timingMode = .easeOut

        let reset = SKAction.run { [weak self] in
            self?.isDropping = false
        }

        claw.run(.sequence([moveOverTarget, down, grab, up, reset]))
    }

    // MARK: - Show the picked item name under the claw
    private func showPickedName(_ name: String) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = name
        label.fontSize = min(40, max(24, size.width * 0.07))
        label.fontColor = .white
        label.zPosition = 1001
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.alpha = 0

        let bgSize = CGSize(width: label.frame.width + 30,
                            height: label.frame.height + 15)
        let background = SKShapeNode(rectOf: bgSize, cornerRadius: 10)
        background.fillColor = .black
        background.alpha = 0.5
        background.strokeColor = .clear
        background.zPosition   = 1000
        background.alpha       = 0

        let centerX = size.width / 2
        let minimumY = itemSide + size.height * bottomInsetRatio + bgSize.height / 2 + 16
        let preferredY = size.height * 0.47
        let maximumY = originalClawPosition.y - claw.size.height / 2 - bgSize.height / 2 - 18
        let yPos = min(max(preferredY, minimumY), maximumY)

        background.position = CGPoint(x: centerX, y: yPos)
        label.position      = background.position

        addChild(background)
        addChild(label)

        let fadeIn  = SKAction.fadeIn(withDuration: 0.2)
        let wait    = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let cleanup = SKAction.run {
            label.removeFromParent()
            background.removeFromParent()
        }
        let seq     = SKAction.sequence([fadeIn, wait, fadeOut, cleanup])

        background.run(seq)
        label.run(seq)
    }

    private var playableOptions: [ClawImageOption] {
        let optionsWithTextures = imageOptions.filter { SKTexture(imageNamed: $0.image).size() != .zero }
        return optionsWithTextures.isEmpty ? imageOptions : optionsWithTextures
    }

    private func addBottomItem(_ option: ClawImageOption, at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: option.image)
        node.name = option.name
        node.userData = NSMutableDictionary(dictionary: ["image": option.image])
        node.size = CGSize(width: itemSide, height: itemSide)
        node.position = position
        node.zPosition = 1
        addChild(node)
        bottomItems.append(node)
    }

    private func imageName(for node: SKSpriteNode) -> String? {
        node.userData?["image"] as? String
    }

    private func addRandomReplacement(
        excludingSelected selectedImage: String?,
        disappearedImage: String?,
        at position: CGPoint
    ) {
        let visibleImages = Set(bottomItems.compactMap { imageName(for: $0) })
        let selectedImages = Set([selectedImage].compactMap { $0 })
        let protectedImages = Set([selectedImage, disappearedImage].compactMap { $0 })
        let strictOptions = playableOptions.filter {
            !protectedImages.contains($0.image) && !visibleImages.contains($0.image)
        }
        let notYetPickedOptions = strictOptions.filter { !pickedImages.contains($0.image) }

        if let replacement = notYetPickedOptions.randomElement() ?? strictOptions.randomElement() {
            addBottomItem(replacement, at: position)
            return
        }

        // Reuse the disappeared item only if no other off-screen option remains.
        let unavoidableReuseOptions = playableOptions.filter {
            !selectedImages.contains($0.image) && !visibleImages.contains($0.image)
        }
        guard let replacement = unavoidableReuseOptions.randomElement() else { return }
        addBottomItem(replacement, at: position)
    }

    private func fittedSize(for sourceSize: CGSize, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            return CGSize(width: maxWidth, height: maxHeight)
        }

        let scale = min(maxWidth / sourceSize.width, maxHeight / sourceSize.height)
        return CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
    }
}
