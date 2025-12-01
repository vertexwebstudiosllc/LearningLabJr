//
//  BarnyardPeekabooScene.swift
//  Peekaboo Learning
//
//  Created by Matthew Teitelman on 6/14/25.
//

import AVFAudio
import AVFoundation
import SpriteKit

private struct BarnyardImageOption {
    let image: String
    let name: String
}

private enum BarnyardImageOptionsLoader {
    private static let fallbackOptions: [BarnyardImageOption] = [
        BarnyardImageOption(image: "cow", name: "Cow"),
        BarnyardImageOption(image: "pig", name: "Pig"),
        BarnyardImageOption(image: "chicken", name: "Chicken"),
        BarnyardImageOption(image: "turkey", name: "Turkey"),
        BarnyardImageOption(image: "sheep", name: "Sheep"),
        BarnyardImageOption(image: "rabbit", name: "Rabbit"),
        BarnyardImageOption(image: "horse", name: "Horse"),
        BarnyardImageOption(image: "goat", name: "Goat"),
        BarnyardImageOption(image: "duck", name: "Duck")
    ]

    static func loadOptions() -> [BarnyardImageOption] {
        guard let csv = loadCategoriesText() else {
            return fallbackOptions
        }

        let rows = parseCSV(csv)
        guard let headers = rows.first, rows.count > 1 else {
            return fallbackOptions
        }

        let normalizedHeaders = headers.map(normalizeHeader)
        let imageIndex = 0
        guard let inAppIndex = normalizedHeaders.firstIndex(of: "inapp") else {
            return fallbackOptions
        }

        let nameIndex = normalizedHeaders.firstIndex(of: "name")
        let categoryIndex = normalizedHeaders.firstIndex(of: "barnyard")
            ?? normalizedHeaders.firstIndex(of: "peekaboobarnyard")
            ?? normalizedHeaders.firstIndex(of: "natureexplorers")

        let options = rows.dropFirst().compactMap { row -> BarnyardImageOption? in
            guard row.indices.contains(imageIndex),
                  row.indices.contains(inAppIndex),
                  isMarked(row[inAppIndex]) else {
                return nil
            }

            if let categoryIndex,
               (!row.indices.contains(categoryIndex) || !isMarked(row[categoryIndex])) {
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

            return BarnyardImageOption(image: image, name: name)
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

class BarnyardPeekabooScene: SKScene, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    enum State {
        case idle
        case doorsOpen
        case showingName
        case closingDoors
    }

    private var state: State = .idle
    private var lastImageName = ""

    private let soundActionKey = "animalSound"

    private let leftDoor = SKSpriteNode(imageNamed: "barnDoorLeft")
    private let rightDoor = SKSpriteNode(imageNamed: "barnDoorRight")
    private let animal = SKSpriteNode()
    private let tts = AVSpeechSynthesizer()
    private var imageName = ""
    private var displayName = ""
    // AVAudioPlayer instances so we can stop audio immediately and chain playback
    private var audioPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    private var pendingSfxURL: URL?

    private let imageOptions = BarnyardImageOptionsLoader.loadOptions()

    private func setRandomImage() {
        let availableOptions = imageOptions.filter { SKTexture(imageNamed: $0.image).size() != .zero }
        let allOptions = availableOptions.isEmpty ? imageOptions : availableOptions
        let filteredOptions = allOptions.filter { $0.image != lastImageName }
        let optionsToChooseFrom = filteredOptions.isEmpty ? allOptions : filteredOptions
        guard let choice = optionsToChooseFrom.randomElement() else { return }

        let texture = SKTexture(imageNamed: choice.image)
        guard texture.size() != .zero else { return }

        animal.texture = texture
        imageName = choice.image
        displayName = choice.name
        lastImageName = imageName
        animal.alpha = 0

        let width = size.width * 0.25
        let aspectRatio = texture.size().height / texture.size().width
        animal.size = CGSize(width: width, height: width * aspectRatio)
    }


    override func didMove(to view: SKView) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession error: \(error)")
        }
        
        tts.delegate = self

        // 1. Background
        let background = SKSpriteNode(imageNamed: "barnBackground")
        background.position  = CGPoint(x: size.width/2, y: size.height/2)
        background.size      = size
        background.zPosition = 0
        addChild(background)

        // 2. Doors
        let doorWidth  = size.width * 0.2
        let doorHeight = size.height * 0.25
        let doorYOffset: CGFloat = -41 + size.height * 0.0083

        leftDoor.size        = CGSize(width: doorWidth, height: doorHeight)
        leftDoor.anchorPoint = CGPoint(x: 1, y: 0.5)
        leftDoor.position    = CGPoint(x: size.width/2, y: size.height/2 + doorYOffset)
        leftDoor.zPosition   = 1
        addChild(leftDoor)

        rightDoor.size        = CGSize(width: doorWidth, height: doorHeight)
        rightDoor.anchorPoint = CGPoint(x: 0, y: 0.5)
        rightDoor.position    = CGPoint(x: size.width/2, y: size.height/2  + doorYOffset)
        rightDoor.zPosition   = 1
        addChild(rightDoor)

        // 3. Shake animation
        runShakeAnimationOnDoors()

        // 4. Animal setup
        setRandomImage()  // Make sure texture and size are set before anything else

        animal.zPosition = 0.5
        animal.alpha     = 0
        animal.position  = CGPoint(x: size.width/2, y: size.height/2 - doorHeight * 0.1)
        addChild(animal)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !touches.isEmpty else { return }

        switch state {
        case .idle:
            stopAllSounds()
            leftDoor.removeAllActions()
            rightDoor.removeAllActions()
            leftDoor.zRotation = 0
            rightDoor.zRotation = 0
            let duration = 0.5
            let offset = leftDoor.size.width
            leftDoor.run(.moveBy(x: -offset, y: 0, duration: duration))
            rightDoor.run(.moveBy(x: offset, y: 0, duration: duration))
            animal.run(.fadeIn(withDuration: 0.5))
            state = .doorsOpen

        case .doorsOpen:
            stopAllSounds()
            showAnimalName()
            state = .showingName
            // Play sound after state change to prevent overlap
            run(SKAction.wait(forDuration: 0.1)) { [weak self] in
                self?.playAnimalSound(self?.imageName ?? "")
            }

        case .showingName:
            stopAllSounds()
            
            leftDoor.removeAllActions()
            rightDoor.removeAllActions()
            leftDoor.zRotation = 0
            rightDoor.zRotation = 0
            let duration = 0.5
            let offset = leftDoor.size.width

            let closeLeft = SKAction.moveBy(x: offset, y: 0, duration: duration)
            let closeRight = SKAction.moveBy(x: -offset, y: 0, duration: duration)
            let fadeOutAnimal = SKAction.fadeOut(withDuration: 0.5)

            let group = SKAction.group([fadeOutAnimal])

            leftDoor.run(closeLeft)
            rightDoor.run(closeRight)
            animal.run(group)

            state = .closingDoors // ← Set this state immediately

            run(.wait(forDuration: duration)) {
                self.setRandomImage()
                self.runShakeAnimationOnDoors()
                self.state = .idle
            }

        case .closingDoors:
            break // do nothing while closing animation plays
        }
    }

    
    private func runShakeAnimationOnDoors() {
        leftDoor.zRotation = 0
        rightDoor.zRotation = 0
        let angle = CGFloat.pi / 180 * 5
        let shake = SKAction.sequence([
            SKAction.rotate(byAngle: angle, duration: 0.1),
            SKAction.rotate(byAngle: -angle * 2, duration: 0.2),
            SKAction.rotate(byAngle: angle, duration: 0.1)
        ])
        let shakeForever = SKAction.repeatForever(shake)
        leftDoor.run(shakeForever)
        rightDoor.run(shakeForever)
    }

       private func showAnimalName() {
           let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
           label.text = displayName
           label.fontSize = 64
           label.fontColor = .white
           label.zPosition = 2
           label.verticalAlignmentMode = .center
           label.horizontalAlignmentMode = .center
           label.position = CGPoint(x: size.width/2, y: size.height * 0.8)
           label.alpha = 0

           let bgSize = CGSize(width: label.frame.width + 30,
                               height: label.frame.height + 15)
           let bg = SKShapeNode(rectOf: bgSize, cornerRadius: 10)
           bg.fillColor = .black
           bg.alpha = 0.5
           bg.zPosition = 1.5
           bg.position = label.position

           addChild(bg)
           addChild(label)

           let fadeIn = SKAction.fadeIn(withDuration: 0.2)
           let pause = SKAction.wait(forDuration: 1.0)
           let fadeOut = SKAction.fadeOut(withDuration: 0.5)
           let cleanup = SKAction.run {
               label.removeFromParent()
               bg.removeFromParent()
           }

           label.run(.sequence([fadeIn, pause, fadeOut, cleanup]))
           bg.run(.sequence([fadeIn, pause, fadeOut, cleanup]))
       }
    
    func playAnimalSound(_ animal: String) {
        stopAllSounds()
        let key = animal.lowercased()

        // Skip animals without sounds if you don’t have assets yet (e.g., tractor)
        let animalsWithSounds: Set<String> = ["cow","pig","chicken","turkey","sheep","rabbit","horse","goat","duck","tractor"]
        guard animalsWithSounds.contains(key) else {
            print("No sound configured for \(animal)")
            return
        }

        // Helper to start AVAudioPlayer from URL
        func playURL(_ url: URL, primary: Bool = true) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                player.prepareToPlay()
                player.play()
                if primary {
                    audioPlayer = player
                } else {
                    sfxPlayer = player
                }
            } catch {
                print("Failed to create player for \(url): \(error)")
            }
        }

        // 1) Try merged file: "<animal>_final.wav"
        if let finalURL = Bundle.main.url(forResource: "\(key)_final", withExtension: "wav") {
            playURL(finalURL, primary: true)
            return
        }

        // 2) Fallback: "<animal>_voice.wav" then "<animal>_sound.wav"
        let voiceURL = Bundle.main.url(forResource: "\(key)_voice", withExtension: "wav")
        let sfxURL   = Bundle.main.url(forResource: "\(key)_sound", withExtension: "wav")

        switch (voiceURL, sfxURL) {
        case (let v?, let s?):
            // Play voice first, then sfx when delegate notifies
            pendingSfxURL = s
            playURL(v, primary: true)
        case (let v?, nil):
            playURL(v, primary: true)
        case (nil, let s?):
            playURL(s, primary: true)
        default:
            print("No audio files found for \(animal). Expected one of: \(key)_final.wav or \(key)_(voice|sound).wav")
        }
    }
    private func debugListWavs() {
        let wavs = Bundle.main.paths(forResourcesOfType: "wav", inDirectory: nil)
        print("WAVs in bundle:", wavs)
    }

    func speakAnimalName(_ name: String) {
        let utterance = AVSpeechUtterance(string: name)
        // Try a more natural voice available on device; fallback to language if nil.
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Allison-compact")
            ?? AVSpeechSynthesisVoice(language: "en-US")

        utterance.rate = 0.42         // slower = clearer for toddlers
        utterance.pitchMultiplier = 1.15
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.05

        tts.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        // Play your SFX from the bundle using AVAudioPlayer so we can stop it immediately
        if let url = Bundle.main.url(forResource: "rabbit_bounce", withExtension: "wav") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                player.prepareToPlay()
                player.play()
                audioPlayer = player
            } catch {
                print("Failed to play rabbit_bounce: \(error)")
            }
        }
    }
    private func stopAllSounds() {
        // Stop AVAudioPlayers immediately
        if let p = audioPlayer {
            p.stop()
            audioPlayer = nil
        }
        if let s = sfxPlayer {
            s.stop()
            sfxPlayer = nil
        }
        pendingSfxURL = nil

        // Stop any SKAction sound running under the soundActionKey
        removeAction(forKey: soundActionKey)

        // Stop any speech in progress
        if tts.isSpeaking {
            tts.stopSpeaking(at: .immediate)
        }
    }

    // AVAudioPlayerDelegate - chain voice -> sfx when voice finishes
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // If there is a pending sfx URL and the primary audioPlayer finished, play sfx
        if player === audioPlayer, let sURL = pendingSfxURL {
            pendingSfxURL = nil
            do {
                let sPlayer = try AVAudioPlayer(contentsOf: sURL)
                sPlayer.delegate = self
                sPlayer.prepareToPlay()
                sPlayer.play()
                sfxPlayer = sPlayer
            } catch {
                print("Failed to play chained sfx: \(error)")
            }
        } else if player === sfxPlayer {
            // sfx finished
            sfxPlayer = nil
        }
    }

   }
