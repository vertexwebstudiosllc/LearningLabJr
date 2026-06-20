//
//  VehiclePeekabooScene.swift
//  Peekaboo Learning
//
//  Created by Matthew Teitelman on 8/3/25.
//

import SpriteKit

private struct VehicleImageOption {
    let image: String
    let name: String
}

private enum VehicleImageOptionsLoader {
    private static let fallbackOptions: [VehicleImageOption] = [
        VehicleImageOption(image: "ambulance", name: "Ambulance"),
        VehicleImageOption(image: "carBlue", name: "Blue Car"),
        VehicleImageOption(image: "copCar", name: "Police Car"),
        VehicleImageOption(image: "firetruck", name: "Fire Truck"),
        VehicleImageOption(image: "foodTruckGrey", name: "Food Truck"),
        VehicleImageOption(image: "motorcylceRed", name: "Red Motorcycle"),
        VehicleImageOption(image: "tractor", name: "Tractor"),
        VehicleImageOption(image: "trashTruck", name: "Trash Truck"),
        VehicleImageOption(image: "truckYellow", name: "Yellow Truck")
    ]

    static func loadOptions() -> [VehicleImageOption] {
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
              let vehicleIndex = normalizedHeaders.firstIndex(of: "vehicle")
                ?? normalizedHeaders.firstIndex(of: "vehicles") else {
            return fallbackOptions
        }

        let nameIndex = normalizedHeaders.firstIndex(of: "name")

        let options = rows.dropFirst().compactMap { row -> VehicleImageOption? in
            guard row.indices.contains(imageIndex),
                  row.indices.contains(inAppIndex),
                  row.indices.contains(vehicleIndex),
                  isMarked(row[inAppIndex]),
                  isMarked(row[vehicleIndex]) else {
                return nil
            }

            let image = row[imageIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !image.isEmpty else { return nil }

            let csvName: String?
            if let nameIndex, row.indices.contains(nameIndex) {
                let trimmedName = row[nameIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                csvName = trimmedName.isEmpty ? nil : trimmedName
            } else {
                csvName = nil
            }

            let name = csvName ?? displayName(from: image)
            return VehicleImageOption(image: image, name: name)
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

class VehiclePeekabooScene: SKScene {
    enum State {
        case idle
        case doorOpen
        case showingName
        case closingDoor
    }

    private var state: State = .idle
    private var lastVehicleName = ""

    private let garageDoor = SKSpriteNode(imageNamed: "MechanicGarageDoor")
    private let vehicle = SKSpriteNode()
    private var vehicleImageName = ""
    private var vehicleName = ""

    private let imageOptions = VehicleImageOptionsLoader.loadOptions()

    // MARK: - Vehicle Selection
    private func setRandomVehicle() {
        let availableOptions = imageOptions.filter { SKTexture(imageNamed: $0.image).size() != .zero }
        let allOptions = availableOptions.isEmpty ? imageOptions : availableOptions
        let filteredOptions = allOptions.filter { $0.name != lastVehicleName }
        let optionsToChooseFrom = filteredOptions.isEmpty ? allOptions : filteredOptions
        guard let choice = optionsToChooseFrom.randomElement() else { return }

        let texture = SKTexture(imageNamed: choice.image)
        guard texture.size() != .zero else { return }

        vehicle.texture = texture
        vehicleImageName = choice.image
        vehicleName = choice.name
        lastVehicleName = vehicleName
        vehicle.alpha = 0

        let width = size.width * 0.38
        let aspectRatio = texture.size().height / texture.size().width
        vehicle.size = CGSize(width: width, height: width * aspectRatio)
    }

    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        // Background
        let background = SKSpriteNode(imageNamed: "MechanicGarage")
        background.position  = CGPoint(x: size.width/2, y: size.height/2)
        background.size      = size
        background.zPosition = 0
        addChild(background)

        // Garage Door
        let baseDoorHeight = size.height * 0.4032
        let tallerDoorHeight = baseDoorHeight * 1.46

        let baseDoorWidth = size.width * 0.5093
        let smallerDoorWidth = baseDoorWidth * 0.87

        garageDoor.size = CGSize(width: smallerDoorWidth, height: tallerDoorHeight)
        garageDoor.anchorPoint = CGPoint(x: 0.5, y: 0)
        garageDoor.position = CGPoint(x: size.width/2,
                                      y: size.height/2 - tallerDoorHeight/2)
        garageDoor.zPosition = 1
        addChild(garageDoor)


        // Shake animation
        runShakeAnimationOnDoor()

        // Vehicle setup
        setRandomVehicle()
        vehicle.zPosition = 0.5
        vehicle.position  = CGPoint(x: size.width/2, y: size.height/2 - garageDoor.size.height*0.1)
        addChild(vehicle)

    }

    // MARK: - Input Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !touches.isEmpty else { return }

        switch state {
        case .idle:
            garageDoor.removeAllActions()
            garageDoor.zRotation = 0
            let duration = 0.6
            let moveUp = SKAction.moveBy(x: 0, y: garageDoor.size.height, duration: duration)
            garageDoor.run(moveUp)
            vehicle.run(.fadeIn(withDuration: 0.5))
            state = .doorOpen

        case .doorOpen:
            showVehicleName()
            ItemSoundManager.shared.playSound(for: vehicleImageName)
            state = .showingName

        case .showingName:
            let duration = 0.6
            let moveDown = SKAction.moveBy(x: 0, y: -garageDoor.size.height, duration: duration)
            let fadeOutVehicle = SKAction.fadeOut(withDuration: 0.5)

            garageDoor.run(moveDown)
            vehicle.run(fadeOutVehicle)

            state = .closingDoor
            run(.wait(forDuration: duration)) {
                self.setRandomVehicle()
                self.runShakeAnimationOnDoor()
                self.state = .idle
            }

        case .closingDoor:
            break // do nothing while closing
        }
    }

    // MARK: - Animations
    private func runShakeAnimationOnDoor() {
        garageDoor.zRotation = 0
        let angle = CGFloat.pi / 180 * 2
        let shake = SKAction.sequence([
            SKAction.rotate(byAngle: angle, duration: 0.1),
            SKAction.rotate(byAngle: -angle*2, duration: 0.2),
            SKAction.rotate(byAngle: angle, duration: 0.1)
        ])
        garageDoor.run(.repeatForever(shake))
    }

    private func showVehicleName() {
        // Wrap long text if it’s wider than 80% of the scene
        let maxWidth = size.width * 0.65
        let labelFontSize: CGFloat = 46
        let lineSpacing: CGFloat = 52
        let words = vehicleName.split(separator: " ")
        var currentLine = ""
        var lines: [String] = []

        let testLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        testLabel.fontSize = labelFontSize

        for word in words {
            let newLine = currentLine.isEmpty ? String(word) : "\(currentLine) \(word)"
            testLabel.text = newLine
            if testLabel.frame.width > maxWidth {
                lines.append(currentLine)
                currentLine = String(word)
            } else {
                currentLine = newLine
            }
        }
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        // Create one label per line (TOP to BOTTOM)
        var labelNodes: [SKLabelNode] = []
        let totalHeight = CGFloat(lines.count - 1) * lineSpacing

        for (i, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = line
            label.fontSize = labelFontSize
            label.fontColor = .white
            label.zPosition = 2
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center

            // Now print in correct order: first line on top, next below it
            let yOffset = totalHeight / 2 - CGFloat(i) * lineSpacing
            label.position = CGPoint(x: size.width/2,
                                     y: size.height * 0.8 + yOffset)
            label.alpha = 0
            addChild(label)
            labelNodes.append(label)
        }

        // Background sized to fit all lines
        let maxLineWidth = labelNodes.map { $0.frame.width }.max() ?? 0
        let bgHeight = CGFloat(lines.count) * lineSpacing
        let bgSize = CGSize(width: maxLineWidth + 40, height: bgHeight + 20)
        let bg = SKShapeNode(rectOf: bgSize, cornerRadius: 10)
        bg.fillColor = .black
        bg.alpha = 0.5
        bg.zPosition = 1.5
        bg.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        addChild(bg)

        // Animate fade in/out
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let pause = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let cleanup = SKAction.run {
            labelNodes.forEach { $0.removeFromParent() }
            bg.removeFromParent()
        }

        labelNodes.forEach { $0.run(.sequence([fadeIn, pause, fadeOut, cleanup])) }
        bg.run(.sequence([fadeIn, pause, fadeOut, cleanup]))
    }
}
