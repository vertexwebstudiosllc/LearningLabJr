import SwiftUI

struct FeelingWeatherGame: View {
    let onReplay: () -> Void
    @State private var play = FeelingWeatherPlay()
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "My Feeling Weather", prompt: play.prompt, accent: play.feeling?.color ?? .purple,
                            completion: play.finished, onReplay: onReplay) {
            Image(systemName: play.feeling?.symbol ?? "cloud.sun.fill").font(.system(size: 90))
                .foregroundStyle(play.feeling?.color ?? .purple).frame(height: 125)
                .accessibilityLabel(play.feeling?.name ?? "Feeling weather")
            if let feeling = play.feeling {
                Text(feeling.name).font(.title.bold()).accessibilityIdentifier("weather.feeling")
            }
            switch play.phase {
            case .feeling:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(FeelingWeatherMood.allCases) { mood in
                        ToddlerActionButton(title: mood.name, systemImage: mood.symbol, color: mood.color) { play.choose(mood) }
                            .accessibilityIdentifier("weather.mood.\(mood.id)")
                    }
                }
            case .size:
                ForEach(FeelingWeatherSize.allCases) { size in
                    ToddlerActionButton(title: size.title, systemImage: "circle.fill", color: play.feeling?.color ?? .purple) { play.chooseSize(size) }
                        .accessibilityIdentifier("weather.size.\(size.id)")
                }
            case .support:
                if let mood = play.feeling {
                    ForEach(mood.supports) { choice in
                        HStack(spacing: 8) {
                            ToddlerActionButton(title: choice.title, systemImage: choice.symbol, color: mood.color) { play.chooseSupport(choice.id, for: mood) }
                                .accessibilityIdentifier("weather.support.\(choice.id)")
                            Button { narrator.speak(choice.title) } label: {
                                Image(systemName: "speaker.wave.2.fill").font(.title3).frame(width: 48, height: 64)
                            }.accessibilityLabel("Hear \(choice.title)").accessibilityIdentifier("weather.hear.\(choice.id)")
                        }
                    }
                }
            case .review, .complete:
                VStack(alignment: .leading, spacing: 12) {
                    Text("My feeling: \(play.feeling?.name ?? "Not sure")")
                    Text("Its size: \(play.size?.title ?? "Not sure")")
                    Text("I would like: \(play.support?.title ?? "")")
                }.font(.headline).padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 22)).accessibilityIdentifier("weather.summary")
                if !play.finished {
                    ToddlerActionButton(title: "Share with my grown-up", systemImage: "heart.fill", color: play.feeling?.color ?? .purple) { play.finish() }
                        .accessibilityIdentifier("weather.finish")
                }
            }
            if play.phase != .feeling && !play.finished {
                Button("Choose a different feeling") { narrator.stop(); play.reset() }
                    .font(.headline).frame(minHeight: 52).accessibilityIdentifier("weather.reset")
            }
            Text("Grown-up: accept your child's choice. This moment is not saved or scored.")
                .font(.subheadline).multilineTextAlignment(.center).padding(16)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
        }.onDisappear { narrator.stop() }
    }
}
