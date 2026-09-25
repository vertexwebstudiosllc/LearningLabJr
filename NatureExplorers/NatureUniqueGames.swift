import SwiftUI

struct CozyNestGame: View {
    @State private var twigs: Set<Int> = []
    @State private var woven: Set<Int> = []
    @State private var eggs = 0
    private var step: Int { twigs.count < 3 ? 0 : woven.count < 3 ? 1 : eggs < 3 ? 2 : 3 }
    private let prompts = ["Some birds build nests from twigs. Gather three twigs.", "Tap each twig to weave it into a cozy nest.", "Our pretend nest is ready. Tap to settle the eggs gently.", "A cozy nest for three eggs! Watch real nests from far away."]
    var body: some View {
        ToddlerGameScaffold(title: "A Cozy Nest", prompt: prompts[step], accent: .brown, completion: step == 3, onReplay: { twigs = []; woven = []; eggs = 0 }) {
            ZStack {
                Ellipse().stroke(Color.brown.opacity(0.7), lineWidth: 24).frame(width: 215, height: 115)
                HStack(spacing: 10) {
                    ForEach(0..<eggs, id: \.self) { _ in
                        Ellipse().fill(Color.cyan.opacity(0.45)).frame(width: 38, height: 50)
                    }
                }
                if !woven.isEmpty {
                    ForEach(0..<3) { index in
                        if woven.contains(index) {
                            Capsule().fill(Color.brown).frame(width: 180, height: 9)
                                .rotationEffect(.degrees(Double(index - 1) * 18)).offset(y: 25)
                        }
                    }
                }
            }.frame(height: 180).accessibilityLabel("Pretend bird nest with \(eggs) eggs")
            if step < 2 {
                let displayedStep = step
                ForEach(0..<3) { index in
                    if step == 0 ? !twigs.contains(index) : !woven.contains(index) {
                        Button {
                            guard step == displayedStep else { return }
                            if displayedStep == 0 { twigs.insert(index) } else { woven.insert(index) }
                        } label: {
                            HStack {
                                Capsule().fill(Color.brown).frame(width: 110, height: 12).rotationEffect(.degrees(Double(index - 1) * 8))
                                Text(step == 0 ? "Gather twig" : "Weave twig").font(.headline)
                            }.frame(maxWidth: .infinity, minHeight: 72).background(Color.brown.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                        }.buttonStyle(.plain).accessibilityLabel(step == 0 ? "Gather twig \(index + 1)" : "Weave twig \(index + 1)")
                    }
                }
            } else if step == 2 {
                ToddlerActionButton(title: "Settle an egg", systemImage: "oval.fill", color: .brown) { eggs = min(eggs + 1, 3) }
            }
        }
    }
}
