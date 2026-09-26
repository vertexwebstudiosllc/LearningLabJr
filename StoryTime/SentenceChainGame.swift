import SwiftUI

struct SentenceBuilderGame: View {
    @StateObject private var session = SentenceChainSession()
    @StateObject private var narrator = GameNarrator()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reading = false
    @State private var readingLine = 0
    @State private var readingToken = UUID()
    var body: some View {
        ScrollViewReader { proxy in
            ToddlerGameScaffold(title: "Make a Sentence", prompt: session.prompt, accent: .purple,
                                completion: false, onReplay: {}, scrollToTopOnPromptChange: true) {
                Text("My story · \(session.pages.count) \(session.pages.count == 1 ? "sentence" : "sentences")")
                    .font(.title2.bold()).accessibilityIdentifier("chain.count")
                if !session.pages.isEmpty {
                    ToddlerActionButton(title: reading ? "Stop reading" : "Read my whole story",
                                        systemImage: reading ? "stop.fill" : "speaker.wave.2.fill", color: .purple) {
                        if reading { stopReading() } else { readStory() }
                    }.accessibilityIdentifier("chain.read")
                }
                if session.building {
                    Text(session.pages.isEmpty ? "Build the first sentence." : "What happens next? Add a sentence to your story.")
                        .font(.headline).multilineTextAlignment(.center)
                    SentenceChainPicture(words: session.draft).frame(height: 175)
                        .accessibilityLabel(session.draft.map(\.title).joined(separator: ", "))
                    if session.ready {
                        Text(session.draftSentence).font(.title3.bold()).multilineTextAlignment(.center)
                        ToddlerActionButton(title: "Add to my story", systemImage: "plus.circle.fill", color: .purple) {
                            stopReading(); session.addSentence()
                        }.accessibilityIdentifier("chain.add")
                    } else {
                        Text("\(["Who?", "Does what?", "With what?"][session.draft.count])")
                            .font(.headline).accessibilityIdentifier("chain.step.\(session.draft.count)")
                        let token = session.generation
                        HStack(alignment: .top, spacing: 10) {
                            ForEach(session.choices) { word in
                                Button { stopReading(); session.choose(word.id, generation: token) } label: {
                                    VStack(spacing: 10) {
                                        SentenceChainWordArt(word: word).frame(height: 65)
                                        Text(word.title).font(.system(.headline, design: .rounded))
                                            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                                    }.padding(10).frame(maxWidth: .infinity, minHeight: 120)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 20))
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.purple.opacity(0.2), lineWidth: 2))
                                }.buttonStyle(.plain).accessibilityLabel(word.title)
                                    .accessibilityIdentifier("chain.choice.\(word.id)")
                            }
                        }
                    }
                    if !session.draft.isEmpty {
                        Button { stopReading(); session.undoWord() } label: {
                            Label("Change the last word", systemImage: "arrow.uturn.backward").frame(minHeight: 48)
                        }.accessibilityIdentifier("chain.undo")
                    }
                } else if let latest = session.pages.last {
                    SentenceChainPicture(words: latest.words).frame(height: 175)
                        .accessibilityLabel(latest.sentence)
                    Text(latest.sentence).font(.title3.bold()).multilineTextAlignment(.center)
                    ToddlerActionButton(title: "Keep adding to my story", systemImage: "plus.bubble.fill", color: .purple) {
                        stopReading(); session.keepAdding()
                    }.accessibilityIdentifier("chain.more")
                }
                if !session.pages.isEmpty {
                    Text("My story so far").font(.title3.bold())
                    Text("Tap any sentence to hear it.").font(.subheadline)
                    LazyVStack(spacing: 12) {
                        ForEach(Array(session.pages.enumerated()), id: \.element.id) { index, page in
                            Button { stopReading(); narrator.speak(page.sentence) } label: {
                                HStack(spacing: 12) {
                                    Text("\(index + 1)").font(.headline).foregroundStyle(.purple)
                                    HuntItemArt(item: HuntItem.named(page.words[0].art)).frame(width: 42, height: 48)
                                    Text(page.sentence).font(.headline).multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                    Image(systemName: "speaker.wave.2.fill").foregroundStyle(.purple)
                                }.padding(14).frame(maxWidth: .infinity, minHeight: 78)
                                    .background(reading && readingLine == index ? Color.purple.opacity(0.17) : .white,
                                                in: RoundedRectangle(cornerRadius: 18))
                            }.buttonStyle(.plain).id(page.id)
                                .accessibilityLabel("Sentence \(index + 1). \(page.sentence)")
                                .accessibilityIdentifier("chain.page.\(index)")
                        }
                    }
                }
                Button("All done") { stopReading(); dismiss() }.frame(minHeight: 48)
            }
            .safeAreaInset(edge: .bottom) {
                if reading {
                    Button { stopReading() } label: {
                        Label("Stop reading · sentence \(readingLine + 1)", systemImage: "stop.fill")
                            .font(.headline).padding().frame(maxWidth: .infinity)
                    }.background(.regularMaterial).accessibilityIdentifier("chain.stop")
                }
            }
            .onChange(of: readingLine) { _, index in
                guard reading, session.pages.indices.contains(index) else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { proxy.scrollTo(session.pages[index].id, anchor: .center) }
            }
            .onDisappear { stopReading() }
        }
    }
    private func stopReading() { readingToken = UUID(); reading = false; narrator.stop() }
    private func readStory() {
        stopReading(); let token = UUID(); readingToken = token; reading = true; readingLine = 0
        narrator.speakSequence(session.lines, onLine: { index in
            guard readingToken == token else { return }; readingLine = index
        }, onFinish: {
            guard readingToken == token else { return }; reading = false
        })
    }
}

struct SentenceChainWordArt: View {
    let word: SentenceStoryWord
    var body: some View {
        if word.id == "ball" {
            Image(systemName: "basketball.fill").resizable().scaledToFit().foregroundStyle(.orange)
        } else if ["finds", "carries", "looks"].contains(word.id) {
            Image(systemName: word.art).resizable().scaledToFit().foregroundStyle(.purple)
        } else {
            HuntItemArt(item: HuntItem.named(word.art))
        }
    }
}

struct SentenceChainPicture: View {
    let words: [SentenceStoryWord]
    var body: some View {
        HStack(spacing: 18) {
            ForEach(0..<3) { index in
                VStack(spacing: 8) {
                    if words.indices.contains(index) {
                        SentenceChainWordArt(word: words[index]).frame(height: 82)
                        Text(words[index].title).font(.headline).multilineTextAlignment(.center)
                    } else {
                        Image(systemName: ["person.crop.circle.badge.questionmark", "questionmark.circle", "shippingbox"][index])
                            .font(.system(size: 42)).foregroundStyle(.purple.opacity(0.35)).frame(height: 82)
                        Text(["Who", "Action", "Object"][index]).font(.subheadline).foregroundStyle(.secondary)
                    }
                }.frame(maxWidth: .infinity)
            }
        }.padding(18).frame(maxWidth: .infinity, minHeight: 165)
            .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
            .accessibilityElement(children: .ignore)
    }
}
