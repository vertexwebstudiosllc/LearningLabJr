import SwiftUI

struct NatureDetectiveGame: View {
    @AppStorage("nature.detective.lastFirst") private var lastFirst = ""
    @AppStorage("nature.detective.lastAnimal") private var lastAnimal = ""
    @State private var play: NatureDetectivePlay?

    var body: some View {
        ToddlerGameScaffold(title: "Nature Detective", prompt: play?.prompt ?? DetectiveAnimal.invitation,
                            accent: .teal, completion: play?.complete == true, onReplay: { play = nil }) {
            if let session = play {
                if session.complete {
                    Label("24 mysteries solved!", systemImage: "checkmark.seal.fill")
                        .font(.title2.bold()).accessibilityIdentifier("detective.complete")
                } else {
                    mystery(session)
                }
            } else {
                Image(systemName: "magnifyingglass").font(.system(size: 64)).foregroundStyle(.teal)
                HStack(spacing: 14) {
                    Image("BarnClean/rabbit").resizable().scaledToFit()
                    Image("DetectiveClean/butterfly").resizable().scaledToFit()
                    Image("OceanClean/octopus").resizable().scaledToFit()
                }.frame(height: 125).accessibilityHidden(true)
                Text("24 animal and insect mysteries")
                    .font(.title2.bold()).multilineTextAlignment(.center)
                Text("Listen, look, and ask for another clue. Explore at your own pace with a grown-up.")
                    .multilineTextAlignment(.center)
                ToddlerActionButton(title: "Let's investigate", systemImage: "magnifyingglass", color: .teal) {
                    guard play == nil else { return }
                    let session = NatureDetectivePlay(previousFirst: lastFirst, previousAnimal: lastAnimal)
                    play = session; lastFirst = session.current.animal.id; lastAnimal = session.current.animal.id
                }.accessibilityIdentifier("detective.begin")
            }
        }
    }

    @ViewBuilder private func mystery(_ session: NatureDetectivePlay) -> some View {
        let animal = session.current.animal
        HStack {
            Label("Mystery \(session.index + 1) of \(session.rounds.count)", systemImage: "magnifyingglass")
                .font(.headline).accessibilityIdentifier("detective.progress")
            Spacer()
            Text("\(session.index) solved").font(.subheadline)
        }
        if session.solved {
            Image(animal.asset).resizable().scaledToFit().frame(height: 210)
                .padding(18).frame(maxWidth: .infinity)
                .background(.teal.opacity(0.09), in: RoundedRectangle(cornerRadius: 28))
                .accessibilityLabel(animal.name).accessibilityIdentifier("detective.found.\(animal.id)")
            Text(animal.name).font(.system(.largeTitle, design: .rounded, weight: .bold))
            ToddlerActionButton(title: session.index == session.rounds.count - 1 ? "Finish exploring" : "Another mystery", systemImage: "arrow.right", color: .teal) {
                play?.advance(from: animal.id)
                if let next = play, !next.complete { lastAnimal = next.current.animal.id }
            }.accessibilityIdentifier("detective.next")
        } else {
            HStack(spacing: 12) {
                ForEach(1...animal.clues.count, id: \.self) { number in
                    Image(systemName: number <= session.clueCount ? "ear.fill" : "lock.fill")
                        .font(.title3).frame(width: 48, height: 48)
                        .foregroundStyle(number <= session.clueCount ? .teal : .secondary)
                        .background(.teal.opacity(0.08), in: Circle())
                }
            }.accessibilityElement(children: .ignore)
                .accessibilityLabel("\(session.clueCount) of 3 clues open")
                .accessibilityIdentifier("detective.clues")
            if session.clueCount < animal.clues.count {
                ToddlerActionButton(title: "Another clue", systemImage: "ear.fill", color: .teal) {
                    play?.revealClue(in: animal.id)
                }.accessibilityIdentifier("detective.clue")
            } else {
                Text("Use the speaker button to hear the clues again.")
                    .font(.subheadline).multilineTextAlignment(.center)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                ForEach(session.current.choices) { choice in
                    Button { play?.choose(choice.id, for: animal.id) } label: {
                        VStack(spacing: 12) {
                            Image(choice.asset).resizable().scaledToFit().frame(height: 105)
                            Text(choice.name).font(.system(.headline, design: .rounded))
                                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        }.padding(10).frame(maxWidth: .infinity, minHeight: 170)
                            .background(.white, in: RoundedRectangle(cornerRadius: 22))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.teal.opacity(0.25), lineWidth: 2))
                    }.buttonStyle(.plain).accessibilityLabel(choice.name)
                        .accessibilityIdentifier("detective.choice.\(choice.id)")
                }
            }
            if session.needsHelp {
                Label("Let's look and listen together", systemImage: "heart.fill")
                    .font(.headline).foregroundStyle(.teal).accessibilityIdentifier("detective.retry")
            }
        }
    }
}
