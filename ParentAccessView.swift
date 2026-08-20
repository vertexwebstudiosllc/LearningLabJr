import SwiftUI

/// A fresh reading-and-arithmetic challenge separates parent actions from play.
/// This is a child gate, not authentication or proof of an adult's identity.
struct ParentChallengeView: View {
    let onSuccess: () -> Void
    var onCancel: (() -> Void)? = nil
    @State private var first = Int.random(in: 12...24)
    @State private var second = Int.random(in: 7...18)
    @State private var answer = ""
    @State private var tried = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 52)).foregroundStyle(.teal)
                Text("Grown-ups, this part is for you")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                Text("Please add \(first) and \(second) to continue.")
                    .font(.system(.title3, design: .rounded))
                    .multilineTextAlignment(.center)
                TextField("Your answer", text: $answer)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220, minHeight: 64)
                    .onSubmit(checkAnswer)
                if tried {
                    Text("That doesn't match yet. Please try again.")
                        .foregroundStyle(.secondary)
                }
                ToddlerActionButton(title: "Continue", systemImage: "lock.open.fill", action: checkAnswer)
                if let onCancel {
                    Button("Back to play", action: onCancel)
                        .frame(minWidth: 100, minHeight: 56)
                }
            }
            .padding(28)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.93).ignoresSafeArea())
        .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
    }

    private func checkAnswer() {
        if Int(answer.trimmingCharacters(in: .whitespacesAndNewlines)) == first + second {
            answer = ""
            onSuccess()
        } else {
            tried = true
            answer = ""
        }
    }
}

struct ParentAccessView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var unlocked = false

    var body: some View {
        Group {
            if unlocked {
                ParentsCornerMenu()
            } else {
                ParentChallengeView(onSuccess: { unlocked = true }, onCancel: { dismiss() })
            }
        }
        .navigationTitle("Parents Corner")
        .navigationBarTitleDisplayMode(.inline)
    }
}
