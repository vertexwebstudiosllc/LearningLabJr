import SwiftUI

struct NoisyStoryGame: View {
    @StateObject private var session = NoisyStorySession()
    @StateObject private var narrator = GameNarrator()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ToddlerGameScaffold(title: "A Noisy Little Story", prompt: session.prompt, accent: .purple,
                            completion: false, onReplay: {}, scrollToTopOnPromptChange: true) {
            if let story = session.story, let page = session.current {
                Text(story.title).font(.system(.title2, design: .rounded, weight: .bold))
                    .accessibilityIdentifier("noisy.story.\(story.id)")
                Text("Page \(session.page + 1) of \(story.pages.count) · \(session.heard.count) of 2 sounds")
                    .font(.subheadline.bold()).accessibilityIdentifier("noisy.page.\(session.page)")
                HStack(spacing: 14) {
                    ForEach(page.sounds, id: \.self) { id in
                        let sound = NoisySound.named(id)
                        Button {
                            guard let line = session.hear(id) else { return }
                            narrator.speak(line)
                        } label: {
                            VStack(spacing: 12) {
                                NoisyPicture(art: sound.art).frame(maxWidth: .infinity).frame(height: 125)
                                    .scaleEffect(session.heard.contains(id) && !reduceMotion ? 1.06 : 1)
                                    .animation(reduceMotion ? nil : .spring(duration: 0.3), value: session.heard.contains(id))
                                Text(sound.name).font(.system(.headline, design: .rounded))
                                Image(systemName: session.heard.contains(id) ? "checkmark.circle.fill" : "speaker.wave.2.fill")
                                    .font(.title2).foregroundStyle(session.heard.contains(id) ? .green : .purple)
                            }.padding(15).frame(maxWidth: .infinity, minHeight: 225)
                                .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 22))
                        }.buttonStyle(.plain).accessibilityLabel("Hear \(sound.name)")
                            .accessibilityIdentifier("noisy.sound.\(id)")
                    }
                }.padding(14).background(Color.sportsRGB(story.color), in: RoundedRectangle(cornerRadius: 28))
                Text(session.caption.isEmpty ? "Tap both pictures. Make the sounds together!" : session.caption)
                    .font(.title3.bold()).multilineTextAlignment(.center).frame(minHeight: 65)
                if session.ready {
                    ToddlerActionButton(title: session.page + 1 == story.pages.count ? "The end — choose a new story" : "Turn the page", systemImage: "book.fill", color: .purple) {
                        narrator.stop(); session.next()
                    }.accessibilityIdentifier("noisy.next")
                }
                Button("Choose a different story") { narrator.stop(); session.returnToChoices() }
                    .frame(minHeight: 48).accessibilityIdentifier("noisy.change")
            } else {
                Text(session.finishedCount == 0 ? "Which adventure shall we hear?" : "Story finished! What happens next?")
                    .font(.title2.bold()).multilineTextAlignment(.center).accessibilityIdentifier("noisy.chooser")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 135))], spacing: 14) {
                    ForEach(session.choices) { story in
                        Button { narrator.stop(); session.choose(story.id) } label: {
                            VStack(spacing: 10) {
                                NoisyPicture(art: story.art).frame(height: 80)
                                Text(story.title).font(.system(.headline, design: .rounded))
                                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                            }.padding(15).frame(maxWidth: .infinity, minHeight: 135)
                                .background(Color.sportsRGB(story.color), in: RoundedRectangle(cornerRadius: 22))
                        }.buttonStyle(.plain).accessibilityIdentifier("noisy.choose.\(story.id)")
                    }
                }
                ToddlerActionButton(title: "All done", systemImage: "checkmark", color: .purple) { dismiss() }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct NoisyPicture: View {
    let art: String
    var body: some View {
        if art == "water" {
            Image(systemName: "water.waves").resizable().scaledToFit().foregroundStyle(.cyan).padding(10)
        } else if art == "clap" {
            Image(systemName: "hands.clap.fill").resizable().scaledToFit().foregroundStyle(.orange).padding(10)
        } else if art == "bubbles" {
            ZStack {
                ForEach(0..<3) { index in
                    Circle().fill(Color.cyan.opacity(0.18))
                        .overlay(Circle().stroke(Color.cyan, lineWidth: 3))
                        .overlay(alignment: .topLeading) { Capsule().fill(.white).frame(width: 10, height: 5).rotationEffect(.degrees(-35)).padding(8) }
                        .frame(width: CGFloat(30 + index * 13), height: CGFloat(30 + index * 13))
                        .offset(x: CGFloat([26, -20, 15][index]), y: CGFloat([-25, 15, 26][index]))
                }
            }.frame(width: 100, height: 100)
        } else { HuntItemArt(item: HuntItem.named(art)) }
    }
}
