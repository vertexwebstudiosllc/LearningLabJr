import SwiftUI
import Combine

@MainActor
final class PictureHuntSession: ObservableObject {
    nonisolated deinit {}
    private static let recentKey = "pictureHunt.recentScenes"
    private let defaults: UserDefaults
    @Published var play: PictureHuntPlay
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        play = PictureHuntPlay(avoiding: defaults.stringArray(forKey: Self.recentKey) ?? [])
        remember()
    }
    func next() {
        let previous = play.index
        play.next()
        if play.index != previous { remember() }
    }
    func replay() {
        play = PictureHuntPlay(avoiding: defaults.stringArray(forKey: Self.recentKey) ?? [])
        remember()
    }
    private func remember() {
        let previous = defaults.stringArray(forKey: Self.recentKey) ?? []
        defaults.set(Array((previous + [play.current.id]).suffix(3)), forKey: Self.recentKey)
    }
}

struct StoryPictureHunt: View {
    @StateObject private var session = PictureHuntSession()
    @StateObject private var narrator = GameNarrator()
    @State private var feedback = ""
    private var play: PictureHuntPlay { session.play }
    var body: some View {
        ToddlerGameScaffold(title: "Picture Hunt", prompt: play.current.prompt, accent: .purple,
                            completion: play.complete, onReplay: { feedback = ""; session.replay() },
                            scrollToTopOnPromptChange: true) {
            Text("Story \(play.index + 1) of \(play.rounds.count) · \(play.found.count) of 3 found")
                .font(.subheadline.bold()).accessibilityIdentifier("hunt.progress")
            Text(play.current.title).font(.title3.bold()).accessibilityIdentifier("hunt.scene.\(play.current.id)")
            HuntStoryPicture(story: play.current, found: play.found)
                .frame(maxWidth: 540).aspectRatio(320.0 / 210, contentMode: .fit)
                .accessibilityElement(children: .ignore).accessibilityLabel(play.current.story)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(play.choices, id: \.self) { id in
                    let item = HuntItem.named(id)
                    let found = play.found.contains(id)
                    VStack(spacing: 0) {
                        Button {
                            guard !play.solved else { return }
                            if session.play.select(id) {
                                feedback = play.solved ? HuntStory.success : HuntStory.found
                            } else { feedback = HuntStory.retry }
                            narrator.speak(feedback)
                        } label: {
                            VStack(spacing: 4) {
                                HuntItemArt(item: item).frame(width: 48, height: 48)
                                    .overlay(alignment: .topTrailing) {
                                        if found { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).background(.white, in: Circle()) }
                                    }
                                Text(item.name).font(.system(.caption, design: .rounded, weight: .bold))
                                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                            }.frame(maxWidth: .infinity, minHeight: 83)
                                .background(found ? Color.green.opacity(0.13) : .white, in: RoundedRectangle(cornerRadius: 17))
                                .overlay(RoundedRectangle(cornerRadius: 17).stroke(found ? Color.green : .purple.opacity(0.25), lineWidth: 2))
                        }.buttonStyle(.plain).disabled(found || play.solved)
                            .accessibilityLabel(item.name).accessibilityValue(found ? "Found" : "Not found")
                            .accessibilityIdentifier("hunt.choice.\(id)")
                        Button { narrator.speak(item.name) } label: {
                            Image(systemName: "speaker.wave.2.fill").font(.body).frame(maxWidth: .infinity, minHeight: 44)
                        }.accessibilityLabel("Hear \(item.name)").accessibilityIdentifier("hunt.hear.\(id)")
                    }
                }
            }.frame(maxWidth: 540)
            if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("hunt.feedback") }
            if play.solved {
                ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish our stories" : "Next story", systemImage: "book.fill", color: .purple) {
                    narrator.stop(); feedback = ""; session.next()
                }.accessibilityIdentifier("hunt.next")
            }
        }.onDisappear { narrator.stop() }
    }
}

/// Each scene is a composed story illustration, not a row of answer cards.
/// The same transparent props appear in the choices, helping early visual matching.
struct HuntStoryPicture: View {
    let story: HuntStory
    var found: Set<String> = []
    private var night: Bool { ["bedtime", "space"].contains(story.id) }
    private var watery: Bool { ["beach", "ocean"].contains(story.id) }
    private var indoor: Bool { ["bedtime", "music", "kitchen", "library", "birthday", "workshop", "station"].contains(story.id) }
    var body: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(night ? Color.indigo.opacity(0.9) : story.id == "snow" ? .cyan.opacity(0.12) : .cyan.opacity(0.24))
                backdrop.frame(width: 320, height: 210)
                ForEach(Array(story.targets.enumerated()), id: \.element) { index, id in
                    HuntItemArt(item: HuntItem.named(id))
                        .frame(width: positions[index].2, height: positions[index].2)
                        .overlay(alignment: .topTrailing) {
                            if found.contains(id) {
                                Image(systemName: "checkmark.seal.fill").font(.title2).foregroundStyle(.green).background(.white, in: Circle())
                            }
                        }
                        .position(x: positions[index].0, y: positions[index].1)
                }
            }.frame(width: 320, height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scaleEffect(g.size.width / 320, anchor: .topLeading)
        }
    }
    private var positions: [(CGFloat, CGFloat, CGFloat)] {
        switch story.id {
        case "bedtime": return [(73, 146, 87), (172, 153, 64), (263, 51, 63)]
        case "beach": return [(65, 167, 73), (168, 158, 64), (264, 67, 74)]
        case "space": return [(82, 124, 113), (235, 134, 104), (250, 40, 47)]
        case "garden": return [(62, 69, 76), (151, 136, 86), (262, 159, 65)]
        case "rain": return [(79, 85, 100), (170, 163, 74), (257, 52, 87)]
        case "snow": return [(62, 142, 93), (181, 125, 115), (276, 171, 48)]
        case "library": return [(77, 137, 105), (180, 150, 65), (266, 120, 67)]
        case "birthday": return [(69, 146, 98), (181, 158, 72), (268, 95, 95)]
        case "park": return [(65, 67, 88), (160, 173, 54), (263, 128, 117)]
        case "station": return [(70, 143, 111), (194, 163, 62), (266, 54, 58)]
        default: return [(63, 136, 88), (162, 116, 88), (262, 146, 78)]
        }
    }
    @ViewBuilder private var backdrop: some View {
        ZStack {
            if indoor {
                Rectangle().fill(story.id == "bedtime" ? Color.indigo : Color.orange.opacity(0.13)).frame(height: 70).offset(y: 74)
                Rectangle().fill(.brown.opacity(0.25)).frame(height: 5).offset(y: 40)
            } else if watery {
                Rectangle().fill(.cyan.opacity(0.5)).frame(height: 125).offset(y: 42)
                if story.id == "beach" { Ellipse().fill(.yellow.opacity(0.65)).frame(width: 410, height: 110).offset(x: -100, y: 100).frame(width: 320, height: 210) }
                ForEach(0..<4) { index in
                    Path { p in
                        p.move(to: CGPoint(x: 5, y: 70 + index * 30))
                        p.addCurve(to: CGPoint(x: 315, y: 70 + index * 30), control1: CGPoint(x: 90, y: 50 + index * 30), control2: CGPoint(x: 230, y: 90 + index * 30))
                    }.stroke(.white.opacity(0.5), lineWidth: 3)
                }
            } else if story.id != "space" {
                Ellipse().fill(story.id == "snow" ? .white : story.id == "rain" ? Color.gray.opacity(0.25) : .green.opacity(0.3))
                    .frame(width: 450, height: 140).offset(y: 98).frame(width: 320, height: 210)
            }
            switch story.id {
            case "picnic":
                RoundedRectangle(cornerRadius: 8).fill(.pink.opacity(0.4)).frame(width: 270, height: 69).rotationEffect(.degrees(-4)).offset(y: 61)
                ForEach(0..<6) { i in Rectangle().fill(.white.opacity(0.5)).frame(width: 6, height: 60).offset(x: CGFloat(i)*40-100, y: 61) }
            case "farm":
                Path { p in p.move(to: CGPoint(x: 183, y: 43)); p.addLine(to: CGPoint(x: 238, y: 8)); p.addLine(to: CGPoint(x: 301, y: 43)); p.closeSubpath() }.fill(.red.opacity(0.65))
                Rectangle().fill(.red.opacity(0.35)).frame(width: 103, height: 65).position(x: 240, y: 73)
                Rectangle().fill(.white.opacity(0.7)).frame(width: 35, height: 48).position(x: 240, y: 82)
            case "bedtime":
                RoundedRectangle(cornerRadius: 12).fill(.blue.opacity(0.45)).frame(width: 91, height: 80).position(x: 263, y: 52)
                RoundedRectangle(cornerRadius: 14).fill(.purple).frame(width: 127, height: 37).position(x: 79, y: 183)
            case "space":
                Ellipse().stroke(.white.opacity(0.22), lineWidth: 2).frame(width: 335, height: 90).rotationEffect(.degrees(-35)).frame(width: 320, height: 210)
            case "garden":
                ForEach(0..<9) { i in RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.55)).frame(width: 12, height: 62).position(x: CGFloat(i)*40, y: 73) }
                RoundedRectangle(cornerRadius: 12).fill(.brown.opacity(0.4)).frame(width: 155, height: 24).position(x: 143, y: 183)
            case "rain":
                ForEach(0..<12) { i in Capsule().fill(.blue.opacity(0.35)).frame(width: 3, height: 12).rotationEffect(.degrees(15)).position(x: CGFloat(i)*28+7, y: CGFloat(i%3)*29+80) }
                Ellipse().fill(.blue.opacity(0.3)).frame(width: 250, height: 20).position(x: 160, y: 194)
            case "music":
                ForEach([18.0, 302.0], id: \.self) { x in RoundedRectangle(cornerRadius: 14).fill(.purple.opacity(0.7)).frame(width: 45, height: 157).position(x: x, y: 72) }
                Rectangle().fill(.brown.opacity(0.3)).frame(height: 26).position(x: 160, y: 196)
            case "kitchen", "workshop":
                RoundedRectangle(cornerRadius: 8).fill(story.id == "kitchen" ? .orange.opacity(0.35) : .brown.opacity(0.5)).frame(width: 298, height: 20).position(x: 160, y: 182)
                ForEach([40.0, 280.0], id: \.self) { x in Rectangle().fill(.brown.opacity(0.5)).frame(width: 12, height: 25).position(x: x, y: 200) }
            case "library":
                RoundedRectangle(cornerRadius: 8).stroke(.brown.opacity(0.3), lineWidth: 8).frame(width: 280, height: 53).position(x: 160, y: 40)
                Rectangle().fill(.brown.opacity(0.4)).frame(width: 165, height: 10).position(x: 228, y: 184)
            case "birthday":
                Path { p in p.move(to: CGPoint(x: 0, y: 10)); p.addQuadCurve(to: CGPoint(x: 320, y: 10), control: CGPoint(x: 160, y: 60)) }.stroke(.purple, lineWidth: 2)
                ForEach(0..<8) { i in
                    Image(systemName: "triangle.fill").rotationEffect(.degrees(180)).foregroundStyle(i.isMultiple(of: 2) ? .pink : .orange).position(x: CGFloat(i)*40+20, y: 25)
                }
            case "station":
                Rectangle().fill(.brown.opacity(0.4)).frame(width: 270, height: 9).position(x: 143, y: 198)
                ForEach(0..<10) { i in Rectangle().fill(.brown.opacity(0.3)).frame(width: 7, height: 15).position(x: CGFloat(i)*30+10, y: 196) }
                Rectangle().fill(.brown).frame(width: 6, height: 90).position(x: 266, y: 95)
            default: EmptyView()
            }
        }
    }
}

struct HuntItemArt: View {
    let item: HuntItem
    var body: some View {
        GeometryReader { g in
            Group {
                if let asset = item.asset {
                    Image(asset).resizable().scaledToFit()
                } else if !item.symbol.isEmpty {
                    Image(systemName: item.symbol).resizable().scaledToFit().foregroundStyle(item.color).padding(5)
                } else {
                    custom.frame(width: 80, height: 80).scaleEffect(min(g.size.width, g.size.height) / 80)
                        .position(x: g.size.width / 2, y: g.size.height / 2)
                }
            }.frame(width: g.size.width, height: g.size.height)
        }.accessibilityHidden(true)
    }
    @ViewBuilder private var custom: some View {
        ZStack {
            switch item.id {
            case "guitar":
                Ellipse().fill(.brown).frame(width: 42, height: 40).offset(y: 20)
                Ellipse().fill(.brown).frame(width: 32, height: 31).offset(y: 1)
                RoundedRectangle(cornerRadius: 3).fill(.orange).frame(width: 10, height: 47).offset(y: -18)
                RoundedRectangle(cornerRadius: 4).fill(.brown).frame(width: 18, height: 14).offset(y: -33)
                Circle().fill(.black.opacity(0.7)).frame(width: 13, height: 13).offset(y: 13)
                ForEach([-2.0, 2.0], id: \.self) { x in Rectangle().fill(.white.opacity(0.7)).frame(width: 1, height: 50).offset(x: x, y: -1) }
            case "spoon":
                Ellipse().fill(.purple).frame(width: 29, height: 39).offset(y: -18)
                Capsule().fill(.purple).frame(width: 10, height: 49).offset(y: 13)
            case "toolbox":
                RoundedRectangle(cornerRadius: 6).stroke(.red, lineWidth: 6).frame(width: 28, height: 19).offset(y: -24)
                RoundedRectangle(cornerRadius: 7).fill(.red).frame(width: 70, height: 45).offset(y: 7)
                Rectangle().fill(.pink).frame(width: 70, height: 5).offset(y: 2)
                RoundedRectangle(cornerRadius: 2).fill(.yellow).frame(width: 11, height: 15).offset(y: 4)
            case "bucket", "watering":
                RoundedRectangle(cornerRadius: 9).fill(item.color).frame(width: 47, height: 43).offset(y: 12)
                Circle().trim(from: 0.5, to: 1).stroke(item.color, lineWidth: 6).frame(width: 36, height: 36).offset(y: -9)
                if item.id == "watering" {
                    Capsule().fill(item.color).frame(width: 33, height: 12).rotationEffect(.degrees(-35)).offset(x: 25, y: -1)
                    Ellipse().fill(item.color).frame(width: 12, height: 23).rotationEffect(.degrees(-35)).offset(x: 36, y: -12)
                }
            case "boots":
                ForEach([-17.0, 17.0], id: \.self) { x in
                    RoundedRectangle(cornerRadius: 5).fill(.yellow).frame(width: 23, height: 48).offset(x: x, y: -3)
                    RoundedRectangle(cornerRadius: 7).fill(.orange).frame(width: 32, height: 17).offset(x: x+4, y: 24)
                }
            case "drum":
                RoundedRectangle(cornerRadius: 8).fill(.orange).frame(width: 65, height: 43).offset(y: 10)
                Ellipse().fill(.yellow).frame(width: 65, height: 23).offset(y: -12)
                ForEach([-17.0, 17.0], id: \.self) { x in Capsule().fill(.brown).frame(width: 5, height: 45).rotationEffect(.degrees(x)).offset(x: x, y: -17) }
            case "bowl":
                Circle().trim(from: 0.5, to: 1).fill(.teal).rotationEffect(.degrees(180)).frame(width: 68, height: 68).offset(y: -9)
                Ellipse().fill(.orange).frame(width: 66, height: 17).offset(y: -9)
            case "snowman":
                Circle().fill(.white).overlay(Circle().stroke(.cyan.opacity(0.5), lineWidth: 1.5)).frame(width: 52, height: 52).offset(y: 14)
                Circle().fill(.white).overlay(Circle().stroke(.cyan.opacity(0.5), lineWidth: 1.5)).frame(width: 36, height: 36).offset(y: -22)
                HStack(spacing: 10) { Circle().frame(width: 4, height: 4); Circle().frame(width: 4, height: 4) }.offset(y: -26)
                Capsule().fill(.orange).frame(width: 13, height: 5).offset(x: 5, y: -17)
                Capsule().fill(.pink).frame(width: 39, height: 7).offset(y: -4)
            case "mitten":
                RoundedRectangle(cornerRadius: 18).fill(.red).frame(width: 37, height: 55).offset(x: -4, y: -6)
                Capsule().fill(.red).frame(width: 18, height: 31).rotationEffect(.degrees(35)).offset(x: 20, y: 1)
                RoundedRectangle(cornerRadius: 4).fill(.pink).frame(width: 40, height: 14).offset(x: -4, y: 24)
            case "kite":
                Path { p in p.move(to: CGPoint(x: 40, y: 4)); p.addLine(to: CGPoint(x: 65, y: 28)); p.addLine(to: CGPoint(x: 40, y: 55)); p.addLine(to: CGPoint(x: 15, y: 28)); p.closeSubpath() }.fill(.purple)
                Path { p in p.move(to: CGPoint(x: 40, y: 55)); p.addCurve(to: CGPoint(x: 29, y: 79), control1: CGPoint(x: 56, y: 61), control2: CGPoint(x: 15, y: 71)) }.stroke(.pink, lineWidth: 3)
            default: EmptyView()
            }
        }
    }
}
