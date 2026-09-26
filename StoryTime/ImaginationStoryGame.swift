import SwiftUI
import Combine

@MainActor
final class ImaginationStorySession: ObservableObject {
    private static let firstKey = "imaginationStory.lastFirst"
    private static let buddyKey = "imaginationStory.lastBuddy"
    private let defaults: UserDefaults
    @Published var play: ImaginationPlay
    @Published private(set) var buddy: TogetherFriend
    private var buddies: [TogetherFriend]
    nonisolated deinit {}
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        play = ImaginationPlay(previousFirst: defaults.string(forKey: Self.firstKey))
        var deck = TogetherFriend.bank.shuffled()
        if deck[0].id == defaults.string(forKey: Self.buddyKey) { deck.swapAt(0, 1) }
        buddy = deck.removeFirst(); buddies = deck
        defaults.set(buddy.id, forKey: Self.buddyKey)
    }
    @discardableResult func choose(_ id: String, generation: UUID) -> Bool {
        guard play.choose(id, generation: generation) else { return false }
        if play.stage == 1 { defaults.set(id, forKey: Self.firstKey) }
        return true
    }
    func changeBuddy() {
        guard play.phase == .choosing, play.stage == 0 else { return }
        advanceBuddy()
    }
    func replay() {
        play = ImaginationPlay(previousFirst: defaults.string(forKey: Self.firstKey))
        advanceBuddy()
    }
    private func advanceBuddy() {
        if buddies.isEmpty {
            buddies = TogetherFriend.bank.shuffled()
            if buddies[0].id == buddy.id { buddies.swapAt(0, 1) }
        }
        buddy = buddies.removeFirst()
        defaults.set(buddy.id, forKey: Self.buddyKey)
    }
}

struct StorySequenceGame: View {
    @StateObject private var session = ImaginationStorySession()
    @StateObject private var narrator = GameNarrator()
    private var play: ImaginationPlay { session.play }
    private var shownAction: ImaginationAction? {
        play.phase == .reading ? play.story[play.page] : play.story.last
    }
    var body: some View {
        ToddlerGameScaffold(title: "First, Next, Last", prompt: play.prompt, accent: .purple,
                            completion: play.phase == .complete, onReplay: session.replay,
                            scrollToTopOnPromptChange: true) {
            Text("Our story star: \(session.buddy.name)").font(.headline)
                .accessibilityIdentifier("imagine.buddy.\(session.buddy.id)")
            ImaginationScene(buddy: session.buddy, action: shownAction)
                .frame(maxWidth: 540).aspectRatio(320.0 / 205, contentMode: .fit)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(shownAction?.sentence ?? session.buddy.appearance)
            if play.phase == .choosing {
                if play.stage == 0 {
                    Button { session.changeBuddy(); narrator.speak(session.buddy.introduction) } label: {
                        Label("Change character", systemImage: "person.2.fill").frame(minHeight: 48)
                    }.accessibilityIdentifier("imagine.character")
                }
                HStack {
                    ForEach(0..<3) { index in
                        Label(ImaginationStories.labels[index], systemImage: index < play.stage ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(index == play.stage ? .purple : .secondary)
                    }
                }.font(.subheadline.bold()).accessibilityIdentifier("imagine.steps")
                HStack {
                    Text(ImaginationStories.questions[play.stage]).font(.title2.bold())
                    Button { narrator.speak(ImaginationStories.questions[play.stage]) } label: {
                        Image(systemName: "speaker.wave.2.fill").frame(width: 48, height: 48)
                    }.accessibilityLabel("Hear the question")
                }
                Text("Every choice can be part of your pretend story.").font(.subheadline).multilineTextAlignment(.center)
                let token = play.generation
                ForEach(play.choices, id: \.self) { id in
                    let action = ImaginationStories.action(id)
                    HStack(spacing: 8) {
                        Button { narrator.stop(); session.choose(id, generation: token) } label: {
                            HStack(spacing: 14) {
                                ImaginationProp(kind: action.art).frame(width: 60, height: 60)
                                Text(action.title).font(.system(.headline, design: .rounded)).multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }.padding(12).frame(maxWidth: .infinity, minHeight: 84)
                                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.purple.opacity(0.25), lineWidth: 2))
                        }.buttonStyle(.plain).accessibilityIdentifier("imagine.choice.\(id)")
                            .accessibilityLabel(action.title)
                        Button { narrator.speak(action.sentence) } label: {
                            Image(systemName: "speaker.wave.2.fill").frame(width: 48, height: 64)
                        }.accessibilityLabel("Hear \(action.title)").accessibilityIdentifier("imagine.hear.\(id)")
                    }
                }
            } else if play.phase == .story {
                Text("Our three-page story").font(.title2.bold())
                ForEach(Array(play.story.enumerated()), id: \.element.id) { index, action in
                    Button { read(index) } label: {
                        HStack(spacing: 12) {
                            ImaginationProp(kind: action.art).frame(width: 52, height: 52)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(ImaginationStories.labels[index]).font(.headline).foregroundStyle(.purple)
                                Text(action.sentence).font(.body).multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "speaker.wave.2.fill")
                        }.padding(14).frame(maxWidth: .infinity).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).accessibilityIdentifier("imagine.page.\(index)")
                }
                ToddlerActionButton(title: "Read our story", systemImage: "book.fill", color: .purple) { read(0) }
                    .accessibilityIdentifier("imagine.read")
                endButtons
            } else if play.phase == .reading {
                Text("\(ImaginationStories.labels[play.page]) · Page \(play.page + 1) of 3")
                    .font(.title2.bold()).accessibilityIdentifier("imagine.reading")
                HStack {
                    Button { narrator.stop(); session.play.previousPage() } label: {
                        Label("Back", systemImage: "chevron.left").frame(minWidth: 80, minHeight: 56)
                    }.disabled(play.page == 0).accessibilityIdentifier("imagine.previous")
                    Spacer()
                    if play.page < 2 {
                        Button { narrator.stop(); session.play.nextPage() } label: {
                            Label("Next page", systemImage: "chevron.right").frame(minHeight: 56)
                        }.accessibilityIdentifier("imagine.next")
                    } else {
                        Button { narrator.stop(); session.play.closeBook() } label: {
                            Label("Our story", systemImage: "book.closed.fill").frame(minHeight: 56)
                        }.accessibilityIdentifier("imagine.close")
                    }
                }
                endButtons
            }
            Text("Make-believe together. Add your own words, sounds, and ideas!")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.onDisappear { narrator.stop() }
    }
    private var endButtons: some View {
        VStack(spacing: 12) {
            ToddlerActionButton(title: "Make another story", systemImage: "sparkles", color: .teal) {
                narrator.stop(); session.replay()
            }.accessibilityIdentifier("imagine.another")
            ToddlerActionButton(title: "Finish our stories", systemImage: "checkmark", color: .purple) {
                narrator.stop(); session.play.finish()
            }.accessibilityIdentifier("imagine.finish")
        }
    }
    private func read(_ page: Int) {
        let previous = play.prompt
        narrator.stop(); session.play.read(page)
        if play.prompt == previous { narrator.speak(play.prompt) }
    }
}

struct ImaginationScene: View {
    let buddy: TogetherFriend
    let action: ImaginationAction?
    private var theme: String { action?.theme ?? "" }
    var body: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(theme == "space" ? Color.indigo.opacity(0.8) : .cyan.opacity(0.16))
                scenery.frame(width: 320, height: 205)
                TogetherFriendArt(friend: buddy, waving: action != nil)
                    .frame(width: 100, height: 150).position(x: 80, y: 122)
                if let action {
                    ImaginationProp(kind: action.art).frame(width: 98, height: 98).position(x: 224, y: 124)
                } else {
                    Image(systemName: "text.bubble.fill").resizable().scaledToFit().foregroundStyle(.purple.opacity(0.5))
                        .frame(width: 104, height: 92).position(x: 223, y: 84)
                    Image(systemName: "sparkles").font(.system(size: 37)).foregroundStyle(.yellow).position(x: 223, y: 76)
                }
            }.frame(width: 320, height: 205).clipShape(RoundedRectangle(cornerRadius: 22))
                .scaleEffect(g.size.width / 320, anchor: .topLeading)
        }
    }
    @ViewBuilder private var scenery: some View {
        ZStack {
            Rectangle().fill(theme == "snow" ? .white : theme == "island" ? Color.yellow.opacity(0.4) : Color.green.opacity(0.15))
                .frame(width: 320, height: 46).position(x: 160, y: 186)
            switch theme {
            case "space":
                Ellipse().stroke(.white.opacity(0.3), lineWidth: 2).frame(width: 280, height: 60).rotationEffect(.degrees(-20)).offset(y: -40)
                ForEach(0..<7) { i in Circle().fill(.white.opacity(0.7)).frame(width: 4, height: 4).position(x: CGFloat(i)*45+10, y: CGFloat(i%3)*19+15) }
            case "island":
                Rectangle().fill(.cyan.opacity(0.5)).frame(width: 320, height: 55).position(x: 160, y: 51)
                ForEach(0..<3) { i in Capsule().fill(.white.opacity(0.6)).frame(width: 53, height: 3).position(x: CGFloat(i)*100+50, y: 52) }
            case "castle":
                ImaginationProp(kind: "castle").frame(width: 85, height: 85).opacity(0.25).position(x: 220, y: 49)
            case "garden":
                ForEach(0..<8) { i in RoundedRectangle(cornerRadius: 3).fill(.white.opacity(0.7)).frame(width: 9, height: 49).position(x: CGFloat(i)*43+10, y: 42) }
            case "music":
                ForEach([18.0, 302.0], id: \.self) { x in RoundedRectangle(cornerRadius: 12).fill(.purple.opacity(0.55)).frame(width: 35, height: 140).position(x: x, y: 62) }
                ForEach([70.0, 140.0, 240.0], id: \.self) { x in Image(systemName: "music.note").foregroundStyle(.pink).position(x: x, y: 24) }
            case "snow":
                ForEach(0..<12) { i in Circle().fill(.white).frame(width: 6, height: 6).position(x: CGFloat(i)*28+5, y: CGFloat(i%4)*24+10) }
            default: EmptyView()
            }
        }.frame(width: 320, height: 205)
    }
}

struct ImaginationProp: View {
    let kind: String
    private var huntID: String? {
        ["rocket": "rocket", "bunny": "bunny", "guitar": "guitar", "earth": "earth", "boat": "boat", "crab": "crab", "book": "book", "flower": "flower", "butterfly": "butterfly", "tree": "tree", "leaf": "leaf", "drum": "drum", "teddy": "teddy", "bell": "bell", "snowman": "snowman", "cup": "cup"][kind]
    }
    private var symbol: String? {
        ["star": "star.fill", "basket": "basket.fill", "wave": "hand.wave.fill", "crown": "crown.fill", "music": "music.note", "flag": "flag.fill", "pencil": "pencil.tip", "clap": "hands.clap.fill", "box": "shippingbox.fill", "snowflake": "snowflake", "paw": "pawprint.fill"][kind]
    }
    var body: some View {
        GeometryReader { g in
            Group {
                if let id = huntID { HuntItemArt(item: HuntItem.named(id)) }
                else if let symbol { Image(systemName: symbol).resizable().scaledToFit().foregroundStyle(.purple).padding(5) }
                else {
                    custom.frame(width: 100, height: 100).scaleEffect(min(g.size.width, g.size.height) / 100)
                        .position(x: g.size.width / 2, y: g.size.height / 2)
                }
            }.frame(width: g.size.width, height: g.size.height)
        }.accessibilityHidden(true)
    }
    @ViewBuilder private var custom: some View {
        ZStack {
            switch kind {
            case "castle":
                RoundedRectangle(cornerRadius: 4).fill(.purple).frame(width: 72, height: 45).offset(y: 21)
                ForEach([-30.0, 30.0], id: \.self) { x in
                    Rectangle().fill(.purple).frame(width: 24, height: 65).offset(x: x, y: 8)
                    Image(systemName: "triangle.fill").resizable().scaledToFit().foregroundStyle(.pink).frame(width: 31, height: 26).offset(x: x, y: -34)
                }
                UnevenRoundedRectangle(topLeadingRadius: 13, topTrailingRadius: 13).fill(.yellow).frame(width: 24, height: 34).offset(y: 26)
            case "treasure":
                RoundedRectangle(cornerRadius: 9).fill(.brown).frame(width: 78, height: 56).offset(y: 13)
                RoundedRectangle(cornerRadius: 9).fill(.orange).frame(width: 78, height: 24).offset(y: -5)
                RoundedRectangle(cornerRadius: 3).fill(.yellow).frame(width: 15, height: 18).offset(y: 11)
                Image(systemName: "sparkles").foregroundStyle(.yellow).font(.title).offset(y: -30)
            case "seed":
                Ellipse().fill(.brown).frame(width: 73, height: 23).offset(y: 31)
                Capsule().fill(.green).frame(width: 6, height: 45).offset(y: 7)
                Ellipse().fill(.green).frame(width: 34, height: 17).rotationEffect(.degrees(-30)).offset(x: 13, y: -13)
                Ellipse().fill(.green).frame(width: 28, height: 15).rotationEffect(.degrees(30)).offset(x: -12, y: -3)
            case "dragon":
                Ellipse().fill(.purple).frame(width: 40, height: 55).rotationEffect(.degrees(-30)).offset(x: -17, y: -7)
                Ellipse().fill(.green).frame(width: 58, height: 47).offset(x: -4, y: 19)
                Capsule().fill(.green).frame(width: 23, height: 49).offset(x: 19, y: -3)
                Ellipse().fill(.green).frame(width: 46, height: 30).offset(x: 22, y: -24)
                ForEach([-17.0, 13.0], id: \.self) { x in Capsule().fill(.green).frame(width: 15, height: 26).offset(x: x, y: 36) }
                Circle().fill(.white).frame(width: 11, height: 11).offset(x: 20, y: -29)
                Circle().fill(.black).frame(width: 5, height: 5).offset(x: 21, y: -29)
                Capsule().fill(.white).frame(width: 15, height: 3).offset(x: 33, y: -18)
            default: EmptyView()
            }
        }
    }
}
