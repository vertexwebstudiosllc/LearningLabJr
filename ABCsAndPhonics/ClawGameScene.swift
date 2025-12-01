//
//  ClawGameScene.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 8/2/25.
//
import SpriteKit

class ClawGameScene: SKScene {
    // MARK: - Configuration
    private let itemNames = ["Basketball","Baseball","Football","Hockey Puck","Tennis Ball","Golf Ball"]
    private let clawSpeed: TimeInterval = 0.3
    private let topInsetRatio: CGFloat = 0.09
    private let bottomInsetRatio: CGFloat = 0.08

    // MARK: - Nodes & State
    private var claw: SKSpriteNode!
    private var bottomItems = [SKSpriteNode]()
    private var originalClawPosition: CGPoint!
    private var isDropping = false

    private var itemSide: CGFloat = 0
    private var bottomPositionByName = [String:CGPoint]()
    private var lastPickedName: String?
    private var grabbedItem: SKSpriteNode?
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
        let margin       = size.width * 0.05
        let availW       = size.width - margin*2
        let byCount      = availW / CGFloat(itemNames.count)
        let maxH         = size.height * 0.22
        let maxClawWidth = claw.size.width * 1.08
        itemSide         = min(byCount * 1.42, maxH, maxClawWidth)
        dropDistance     = max(0, originalClawPosition.y - itemSide * 1.25 - size.height * bottomInsetRatio)

        // Spawn bottom-row sports items
        let bottomSize = CGSize(width: itemSide, height: itemSide)
        let spacing    = availW / CGFloat(itemNames.count - 1)
        for (i, name) in itemNames.enumerated() {
            let node = SKSpriteNode(imageNamed: name.lowercased().replacingOccurrences(of: " ", with: " "))
            node.name   = name
            node.size   = bottomSize
            let x       = margin + spacing * CGFloat(i)
            let y       = bottomSize.height/2 + size.height * bottomInsetRatio
            node.position = CGPoint(x: x, y: y)
            node.zPosition = 1
            addChild(node)
            bottomItems.append(node)
            bottomPositionByName[name] = node.position
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
        let targetX = tappedItem?.position.x ?? claw.position.x
        let moveOverTarget = SKAction.moveTo(x: targetX, duration: 0.2)
        moveOverTarget.timingMode = .easeInEaseOut

        let down = SKAction.moveBy(x: 0, y: -dropDistance, duration: clawSpeed)
        down.timingMode = .easeIn

        let grab = SKAction.run { [weak self] in
            guard let self = self else { return }

            if let old = self.grabbedItem, let nm = old.name {
                old.removeFromParent()
                old.size     = CGSize(width: self.itemSide,
                                      height: self.itemSide)
                old.position = self.bottomPositionByName[nm]!
                self.addChild(old)
                self.bottomItems.append(old)
            }

            let candidates = self.bottomItems.filter { $0.name != self.lastPickedName }
            guard let item = tappedItem ?? candidates.randomElement(),
                  let name = item.name else { return }

            self.lastPickedName = name
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

    private func fittedSize(for sourceSize: CGSize, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            return CGSize(width: maxWidth, height: maxHeight)
        }

        let scale = min(maxWidth / sourceSize.width, maxHeight / sourceSize.height)
        return CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
    }
}
