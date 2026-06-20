//
//  ItemSoundManager.swift
//  LearningLabJr
//

import AVFoundation
import Foundation

final class ItemSoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = ItemSoundManager()

    private let catalog = ItemSoundCatalog.load()
    private var player: AVAudioPlayer?

    private override init() {
        super.init()
    }

    func playSound(for imageName: String) {
        let imageKey = imageName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !imageKey.isEmpty else { return }

        stop()

        guard let url = catalog.soundURL(for: imageKey) else {
            return
        }

        do {
#if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
#endif
            let nextPlayer = try AVAudioPlayer(contentsOf: url)
            nextPlayer.delegate = self
            nextPlayer.prepareToPlay()
            nextPlayer.play()
            player = nextPlayer
        } catch {
            print("Failed to play item sound for \(imageKey): \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}

private struct ItemSoundCatalog {
    private static let resourceNames = [
        ("LearningLabAppCategories", "csv"),
        ("LearningLabAppCategories", "tsv"),
        ("LearningLabAppCategories", "txt")
    ]

    private static let soundHeaderNames: Set<String> = [
        "noise",
        "noises",
        "noisefile",
        "sound",
        "sounds",
        "soundfile",
        "audio",
        "audiofile",
        "sfx",
        "sfxfile"
    ]

    private static let soundExtensions = ["wav", "mp3", "m4a", "caf", "aif", "aiff"]
    private static let soundDirectories: [String?] = ["ItemNoises", "Noises", nil]

    private let soundNamesByImage: [String: String]

    static func load() -> ItemSoundCatalog {
        guard let text = loadCategoriesText() else {
            return ItemSoundCatalog(soundNamesByImage: [:])
        }

        let rows = parseCSV(text)
        guard let headers = rows.first, rows.count > 1 else {
            return ItemSoundCatalog(soundNamesByImage: [:])
        }

        let normalizedHeaders = headers.map(normalizeHeader)
        guard let soundIndex = normalizedHeaders.firstIndex(where: { soundHeaderNames.contains($0) }) else {
            return ItemSoundCatalog(soundNamesByImage: [:])
        }

        var sounds: [String: String] = [:]
        for row in rows.dropFirst() {
            guard row.indices.contains(0), row.indices.contains(soundIndex) else { continue }

            let imageName = row[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let soundName = row[soundIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !imageName.isEmpty, !soundName.isEmpty else { continue }

            sounds[normalizeResourceKey(imageName)] = soundName
        }

        return ItemSoundCatalog(soundNamesByImage: sounds)
    }

    func soundURL(for imageName: String) -> URL? {
        let normalizedImage = Self.normalizeResourceKey(imageName)

        if let configuredSound = soundNamesByImage[normalizedImage],
           let configuredURL = Self.url(forConfiguredSound: configuredSound) {
            return configuredURL
        }

        let fallbackNames = [
            imageName,
            "\(imageName)_sound",
            "\(imageName)_noise",
            "\(imageName)_sfx",
            "\(imageName)_final",
            "\(imageName)_voice"
        ]

        for name in fallbackNames {
            if let url = Self.url(forConfiguredSound: name) {
                return url
            }
        }

        return nil
    }

    private static func loadCategoriesText() -> String? {
        for resource in resourceNames {
            guard let url = Bundle.main.url(forResource: resource.0, withExtension: resource.1),
                  let text = try? String(contentsOf: url, encoding: .utf8) else {
                continue
            }

            return text
        }

        return nil
    }

    private static func url(forConfiguredSound configuredSound: String) -> URL? {
        let trimmedSound = configuredSound.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSound.isEmpty else { return nil }

        let resourcePath = (trimmedSound as NSString).deletingPathExtension
        let explicitExtension = (trimmedSound as NSString).pathExtension

        if !explicitExtension.isEmpty,
           let url = url(forResourcePath: resourcePath, extension: explicitExtension) {
            return url
        }

        for soundExtension in soundExtensions {
            if let url = url(forResourcePath: resourcePath, extension: soundExtension) {
                return url
            }
        }

        return nil
    }

    private static func url(forResourcePath resourcePath: String, extension soundExtension: String) -> URL? {
        let cleanPath = resourcePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPath.isEmpty else { return nil }

        let nsPath = cleanPath as NSString
        let resourceName = nsPath.lastPathComponent
        let explicitDirectory = nsPath.deletingLastPathComponent

        if explicitDirectory != ".", !explicitDirectory.isEmpty {
            return Bundle.main.url(forResource: resourceName, withExtension: soundExtension, subdirectory: explicitDirectory)
        }

        for directory in soundDirectories {
            if let url = Bundle.main.url(forResource: cleanPath, withExtension: soundExtension, subdirectory: directory) {
                return url
            }
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

    private static func normalizeResourceKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
