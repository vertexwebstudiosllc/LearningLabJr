import SwiftUI

struct StoryBagGame: View {
    @StateObject private var session = StoryBagSession()
    @StateObject private var narrator = GameNarrator()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reading = false
    @State private var readingLine = 0
    @State private var readingToken = UUID()
    var body: some View {
        ToddlerGameScaffold(title: "The Story Bag", prompt: session.setting == nil ? BagSurprise.finished : BagSurprise.instruction,
                            accent: .purple, completion: false, onReplay: {}) {
            if let setting = session.setting {
                Text(setting.title).font(.title2.bold()).accessibilityIdentifier("bag.setting.\(setting.id)")
                BagBookScene(setting: setting, selected: session.selected, highlighted: reading ? readingLine - 1 : nil)
                    .aspectRatio(360.0 / 240, contentMode: .fit).frame(maxWidth: 580)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(([setting.title] + session.selected.map(\.title)).joined(separator: ", "))
                if !session.ready {
                    Text("Bag \(session.selected.count + 1) of 3").font(.headline).accessibilityIdentifier("bag.progress")
                    if !session.isOpen {
                        Button {
                            session.open(); narrator.speak(ImaginationStories.questions[session.selected.count])
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "bag.fill").font(.system(size: 78)).overlay { Image(systemName: "sparkles").font(.title).foregroundStyle(.yellow).offset(y: 10) }
                                Text("Open the surprise bag").font(.headline)
                            }.frame(maxWidth: .infinity, minHeight: 150).foregroundStyle(.purple)
                        }.buttonStyle(.plain).accessibilityIdentifier("bag.open")
                    } else {
                        Text("Which surprise belongs in your story?").font(.headline)
                        let token = session.generation
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(session.choices) { choice in
                                VStack {
                                    Button {
                                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { session.choose(choice.id, generation: token) }
                                        if !session.ready { narrator.speak(choice.sentence) }
                                    } label: {
                                        VStack(spacing: 10) {
                                            BagSurpriseArt(choice: choice).frame(height: 95)
                                            Text(choice.title).font(.headline).multilineTextAlignment(.center)
                                        }.padding(14).frame(maxWidth: .infinity, minHeight: 150)
                                            .background(.white, in: RoundedRectangle(cornerRadius: 22))
                                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.purple.opacity(0.2), lineWidth: 2))
                                    }.buttonStyle(.plain).accessibilityIdentifier("bag.choice.\(choice.id)")
                                    Button { narrator.speak(choice.sentence) } label: {
                                        Image(systemName: "speaker.wave.2.fill").frame(minWidth: 60, minHeight: 48)
                                    }.accessibilityLabel("Hear \(choice.title)")
                                }.frame(maxWidth: .infinity)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(session.lines.enumerated()), id: \.offset) { index, line in
                            Text(line).font(.system(.body, design: .rounded, weight: reading && readingLine == index ? .bold : .regular))
                                .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                                .background(reading && readingLine == index ? Color.purple.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }.accessibilityIdentifier("bag.story")
                    Text(reading ? "Ruth is reading your story" : "Your story is ready")
                        .accessibilityIdentifier(reading ? "bag.reading.\(readingLine)" : "bag.ready")
                    ToddlerActionButton(title: reading ? "Stop reading" : "Read our story again", systemImage: reading ? "stop.fill" : "speaker.wave.2.fill", color: .purple) {
                        if reading { stopReading() } else { readStory() }
                    }.accessibilityIdentifier("bag.read")
                    ToddlerActionButton(title: "A new story setting", systemImage: "book.fill", color: .purple) {
                        stopReading(); session.nextStory()
                    }.accessibilityIdentifier("bag.next")
                }
            } else {
                Image(systemName: "books.vertical.fill").font(.system(size: 80)).foregroundStyle(.purple)
                Text("All 12 storybook settings explored!").font(.title2.bold()).multilineTextAlignment(.center)
                Text("Your progress is saved, so a setting won’t repeat.").multilineTextAlignment(.center)
            }
            Button("All done") { stopReading(); dismiss() }.frame(minHeight: 48)
        }
        .onChange(of: session.selected.count) { _, count in if count == 3 { readStory() } }
        .onDisappear { stopReading() }
    }
    private func stopReading() {
        readingToken = UUID(); reading = false; narrator.stop()
    }
    private func readStory() {
        stopReading()
        let token = UUID(); readingToken = token; reading = true; readingLine = 0
        narrator.speakSequence(session.lines, onLine: { index in
            guard readingToken == token else { return }; readingLine = index
        }, onFinish: {
            guard readingToken == token else { return }; reading = false
        })
    }
}

struct BagObjectArt: View {
    let art: String
    var body: some View {
        if art == "pencil" { Image(systemName: "pencil").resizable().scaledToFit().foregroundStyle(.purple).padding(10) }
        else if let item = HuntItem.bank.first(where: { $0.id == art }) { HuntItemArt(item: item) }
        else { ImaginationProp(kind: art) }
    }
}
struct BagSurpriseArt: View {
    let choice: BagSurprise
    var body: some View {
        GeometryReader { g in
            ZStack {
                BagObjectArt(art: choice.art).padding(12)
                if choice.id == "bunny" || choice.id == "cat" {
                    Image(systemName: choice.id == "bunny" ? "crown.fill" : "triangle.fill")
                        .font(.system(size: g.size.height * 0.25)).foregroundStyle(choice.id == "bunny" ? Color.orange : Color.purple)
                        .overlay(alignment: .top) { if choice.id == "cat" { Circle().fill(.yellow).frame(width: 7, height: 7).offset(y: -3) } }
                        .offset(y: -g.size.height * 0.32)
                }
                if choice.id == "dragon" || choice.id == "tree" {
                    Image(systemName: "music.note").font(.title2).foregroundStyle(.pink).offset(x: g.size.width * 0.3, y: -g.size.height * 0.2)
                }
                if choice.id == "teddy" {
                    Path { path in
                        path.move(to: CGPoint(x: 16, y: 5))
                        path.addCurve(to: CGPoint(x: 1, y: 3), control1: CGPoint(x: 10, y: 0), control2: CGPoint(x: 6, y: 14))
                        path.move(to: CGPoint(x: 16, y: 5))
                        path.addCurve(to: CGPoint(x: 31, y: 3), control1: CGPoint(x: 22, y: 0), control2: CGPoint(x: 26, y: 14))
                    }.stroke(Color.indigo, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 32, height: 12).offset(y: -g.size.height * 0.025)
                }
            }.frame(width: g.size.width, height: g.size.height)
        }
    }
}
struct BagBookScene: View {
    let setting: BagSetting
    let selected: [BagSurprise]
    let highlighted: Int?
    var body: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(Color.purple).frame(width: 358, height: 238)
                RoundedRectangle(cornerRadius: 13).fill(Color.sportsRGB(setting.sky)).frame(width: 342, height: 220)
                Rectangle().fill(Color.sportsRGB(setting.ground)).frame(width: 342, height: 79).offset(y: 70)
                decoration
                BagObjectArt(art: setting.art).frame(width: 85, height: 85).position(x: 290, y: 66)
                ForEach(Array(selected.enumerated()), id: \.element.id) { index, choice in
                    BagSurpriseArt(choice: choice).frame(width: 91, height: 95)
                        .background(highlighted == index ? Color.white.opacity(0.55) : .clear, in: RoundedRectangle(cornerRadius: 18))
                        .position(x: CGFloat(67 + index * 112), y: 158)
                }
                Rectangle().fill(Color.purple.opacity(0.18)).frame(width: 3, height: 217)
                Text(setting.title).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(.indigo)
                    .position(x: 170, y: 25)
            }.frame(width: 360, height: 240).clipped()
                .scaleEffect(min(g.size.width / 360, g.size.height / 240))
                .position(x: g.size.width / 2, y: g.size.height / 2)
        }
    }
    private var decoration: some View {
        let symbols = ["castle": "flag.fill", "moon": "star.fill", "island": "water.waves", "garden": "leaf.fill", "snow": "snowflake", "ocean": "circle", "farm": "sun.max.fill", "kitchen": "fork.knife", "forest": "tree.fill", "party": "party.popper.fill", "space": "sparkles", "beach": "sun.max.fill"]
        return HStack(spacing: 22) {
            ForEach(0..<3) { index in
                Image(systemName: symbols[setting.id]!).font(.system(size: 24 + CGFloat(index * 4)))
                    .foregroundStyle(Color.purple.opacity(0.25))
            }
        }.position(x: 102, y: 70)
    }
}
