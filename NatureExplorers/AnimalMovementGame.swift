import SwiftUI

struct AnimalMovementGame: View {
    @AppStorage("nature.animalMovement.lastAnimal") private var lastAnimal = ""
    @State private var play: AnimalMovementPlay?

    var body: some View {
        ToddlerGameScaffold(
            title: "Move Like an Animal",
            prompt: play?.current.prompt ?? AnimalMove.invitation,
            accent: .orange,
            completion: play?.complete == true,
            onReplay: { play = nil }
        ) {
            if let session = play {
                VStack(spacing: 18) {
                    Text(session.complete ? "Sixteen animal moves together!" : "Animal \(session.index + 1) of \(session.animals.count)")
                        .font(.headline).accessibilityIdentifier("movement.progress")
                    Image(session.current.asset)
                        .resizable().scaledToFit()
                        .frame(maxWidth: 300).frame(height: 235)
                        .padding(18)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.09), in: RoundedRectangle(cornerRadius: 30))
                        .accessibilityLabel(session.current.name)
                        .accessibilityIdentifier("movement.animal.\(session.current.id)")
                    Text(session.current.name).font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(session.current.movement).font(.title3.bold())
                    togetherReminder
                    if !session.complete {
                        ToddlerActionButton(title: session.index == session.animals.count - 1 ? "We did it!" : "Next animal", systemImage: "checkmark.circle.fill", color: .orange) {
                            play?.advance(from: session.current.id)
                            if let next = play, !next.complete { lastAnimal = next.current.id }
                        }.accessibilityIdentifier("movement.next")
                    }
                }
            } else {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 90)).foregroundStyle(.orange)
                    .frame(height: 145).accessibilityHidden(true)
                togetherReminder
                Text("16 animal friends · Go at your own pace")
                    .font(.headline).multilineTextAlignment(.center)
                ToddlerActionButton(title: "Let's move together", systemImage: "person.2.fill", color: .orange) {
                    let session = AnimalMovementPlay(previousAnimal: lastAnimal)
                    play = session
                    lastAnimal = session.current.id
                }.accessibilityIdentifier("movement.begin")
            }
        }
    }

    private var togetherReminder: some View {
        VStack(spacing: 8) {
            Label("Play with a grown-up", systemImage: "person.2.fill")
                .font(.system(.headline, design: .rounded))
            Text("Make a little space together. Sitting down works for every move!")
                .font(.subheadline).multilineTextAlignment(.center)
        }.padding(16).frame(maxWidth: .infinity)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
            .accessibilityIdentifier("movement.together")
    }
}
