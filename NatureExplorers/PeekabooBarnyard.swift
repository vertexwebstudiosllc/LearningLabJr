// Restores the original barn background, sliding doors and three-tap reveal loop.
import SpriteKit

final class BarnyardPeekabooScene: SKScene {
    private(set) var play: BarnyardPlay
    var onChange: ((BarnyardPlay) -> Void)?
    var onIntroduce: ((BarnyardDiscovery) -> Void)?
    var reduceMotion = false
    private let leftDoor = SKSpriteNode(imageNamed: "barnDoorLeft")
    private let rightDoor = SKSpriteNode(imageNamed: "barnDoorRight")
    private let visitor = SKSpriteNode()
    private let namePlate = SKNode()
    private var doorY: CGFloat { size.height - size.width * 1.5 * 0.545 }

    init(size: CGSize, deck: BarnyardDeck = BarnyardDeck()) {
        play = BarnyardPlay(deck: deck)
        super.init(size: size)
        scaleMode = .aspectFit
    }
    required init?(coder: NSCoder) { fatalError("Use init(size:deck:)") }

    override func didMove(to view: SKView) {
        guard children.isEmpty else { return }
        // Keep the original illustration's proportions; crop only the long path
        // below the barn so the complete building fits in the embedded screen.
        let background = SKSpriteNode(imageNamed: "barnBackground")
        background.name = "barn.background"
        background.anchorPoint = CGPoint(x: 0.5, y: 1)
        background.position = CGPoint(x: size.width / 2, y: size.height)
        background.size = CGSize(width: size.width, height: size.width * 1.5)
        addChild(background)
        for (door, anchor) in [(leftDoor, CGFloat(1)), (rightDoor, CGFloat(0))] {
            door.size = CGSize(width: size.width * 0.17, height: size.width * 1.5 * 0.25)
            door.anchorPoint = CGPoint(x: anchor, y: 0.5)
            door.position = CGPoint(x: size.width / 2, y: doorY)
            door.zPosition = 2
            addChild(door)
        }
        leftDoor.name = "barn.leftDoor"; rightDoor.name = "barn.rightDoor"
        visitor.name = "barn.visitor"; visitor.zPosition = 1
        visitor.position = CGPoint(x: size.width / 2, y: doorY)
        addChild(visitor)
        namePlate.zPosition = 3
        namePlate.position = CGPoint(x: size.width / 2, y: size.height - size.width * 1.5 * 0.255)
        addChild(namePlate)
        prepareVisitor()
        onChange?(play)
    }
    private func prepareVisitor() {
        let texture = SKTexture(imageNamed: play.current.asset)
        let native = texture.size()
        visitor.texture = texture
        if native.width > 0, native.height > 0 {
            let scale = min(size.width * 0.29 / native.width, size.width * 1.5 * 0.22 / native.height)
            visitor.size = CGSize(width: native.width * scale, height: native.height * scale)
        }
        visitor.alpha = 0
        namePlate.removeAllChildren()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touches.isEmpty { activate() }
    }
    func activate() {
        guard !isPaused, !children.isEmpty else { return }
        let previous = play.phase
        play.activate()
        guard play.phase != previous else { return }
        onChange?(play)
        switch play.phase {
        case .opening: animateDoors(opening: true)
        case .introduced:
            showName()
            onIntroduce?(play.current)
        case .closing: animateDoors(opening: false)
        case .closed, .open: break
        }
    }
    private func animateDoors(opening: Bool) {
        let duration = reduceMotion ? 0.0 : 0.5
        let offset = opening ? leftDoor.size.width : 0
        // Absolute destinations prevent drift across repeated visits.
        leftDoor.run(.moveTo(x: size.width / 2 - offset, duration: duration))
        rightDoor.run(.moveTo(x: size.width / 2 + offset, duration: duration))
        visitor.run(.fadeAlpha(to: opening ? 1 : 0, duration: duration))
        if !opening { namePlate.removeAllChildren() }
        run(.sequence([.wait(forDuration: duration), .run { [weak self] in
            guard let self else { return }
            self.play.finishAnimation()
            if self.play.phase == .closed { self.prepareVisitor() }
            self.onChange?(self.play)
        }]), withKey: "barn.transition")
    }
    private func showName() {
        namePlate.removeAllChildren()
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = play.current.name
        label.fontSize = 58
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        let plate = SKShapeNode(rectOf: CGSize(width: label.frame.width + 38, height: 82), cornerRadius: 16)
        plate.fillColor = .black.withAlphaComponent(0.8)
        plate.strokeColor = .white
        namePlate.addChild(plate)
        label.zPosition = 1
        namePlate.addChild(label)
    }
}
