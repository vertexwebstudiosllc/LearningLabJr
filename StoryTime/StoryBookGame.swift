//
//  StoryBookGame.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI

struct StoryBookGame: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pageIndex = 0

    private let storyTitle = "Owen Onion Finds His Voice"
    private let pages = StoryBookPage.owenOnion

    var body: some View {
        ZStack {
            StoryBookBackground()

            GeometryReader { proxy in
                VStack(spacing: 10) {
                    bookHeader

                    StoryPageView(page: pages[pageIndex])
                        .id(pageIndex)
                        .transition(pageTransition)
                        .frame(maxWidth: 720, maxHeight: .infinity)

                    navigationBar
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .contentShape(Rectangle())
                .gesture(pageSwipe)
            }
        }
        .navigationTitle(storyTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var bookHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "book.closed.fill")
                .foregroundStyle(Color(red: 0.49, green: 0.24, blue: 0.55))

            Text(storyTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.22, green: 0.16, blue: 0.14))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Text("Page \(pageIndex + 1) of \(pages.count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.42, green: 0.31, blue: 0.25))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: 720)
        .frame(height: 44)
        .background(.white.opacity(0.88), in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 7, y: 4)
    }

    private var navigationBar: some View {
        HStack(spacing: 14) {
            PageButton(
                systemImage: "chevron.left",
                label: "Previous page",
                isEnabled: pageIndex > 0,
                action: goBack
            )

            PageIndicator(currentPage: pageIndex, pageCount: pages.count)
                .frame(maxWidth: 360)

            PageButton(
                systemImage: pageIndex == pages.count - 1 ? "checkmark" : "chevron.right",
                label: pageIndex == pages.count - 1 ? "Story complete" : "Next page",
                isEnabled: pageIndex < pages.count - 1,
                action: goForward
            )
        }
        .frame(maxWidth: 720)
    }

    private var pageSwipe: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < -45 {
                    goForward()
                } else if value.translation.width > 45 {
                    goBack()
                }
            }
    }

    private var pageTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private func goBack() {
        guard pageIndex > 0 else { return }
        withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.34, dampingFraction: 0.88)) {
            pageIndex -= 1
        }
    }

    private func goForward() {
        guard pageIndex < pages.count - 1 else { return }
        withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.34, dampingFraction: 0.88)) {
            pageIndex += 1
        }
    }
}

private struct StoryBookPage: Identifiable {
    let number: Int
    let text: String

    var id: Int { number }
    var imageName: String { "OwenOnionPage\(number)" }

    static let owenOnion: [StoryBookPage] = [
        StoryBookPage(number: 1, text: """
        Owen Onion was round and small,
        with purple skin and layers tall.
        He had two feet, a tiny nose,
        and little hands with little toes.
        Owen had a voice inside…
        but most days, Owen liked to hide.
        """),
        StoryBookPage(number: 2, text: """
        His best friend Cooper Cheese was loud.
        He talked to chairs.
        He talked to clouds.
        He talked while running through the room.
        He talked while sweeping with a broom.
        “Talking’s fun!” said Cooper Cheese.
        “Try it, Owen. Pretty please?”
        """),
        StoryBookPage(number: 3, text: """
        Owen looked down at his shoes.
        He had a worry he could not lose.
        “I’m an onion,” Owen said.
        Then he tucked his chin and hid his head.
        “What if my breath smells oniony?
        What if no one stands near me?”
        """),
        StoryBookPage(number: 4, text: """
        Cooper blinked his cheesy eyes.
        Then Cooper smiled a warm surprise.
        “Owen, Owen, listen here.
        You are my friend. Come sit right near.”
        He scooted close and gave a grin.
        “I like you outside, and within.”
        """),
        StoryBookPage(number: 5, text: """
        Along rolled Beau, a sandwich roll,
        with happy heart and gentle soul.
        Beau Bread smiled his soft bread smile.
        “I’ll sit with Owen for a while.”
        Owen peeked. His fear felt small.
        Beau did not seem scared at all.
        """),
        StoryBookPage(number: 6, text: """
        Then Quinn Quinoa hopped in too.
        She wore a bow of leafy blue.
        “Words are how we share and say
        the things we feel throughout the day.”
        She tapped Owen’s hand with care.
        “Your words are welcome everywhere.”
        """),
        StoryBookPage(number: 7, text: """
        Owen’s fingers touched his mouth.
        His worried thoughts went north and south.
        “What if I speak and people know?
        What if they wrinkle up and go?”
        Cooper said, “Then start out small.
        One tiny word. That’s all. That’s all.”
        """),
        StoryBookPage(number: 8, text: """
        Beau Bread said, “Let’s practice. See?
        You can say a word with me.”
        Beau took a breath.
        He gave a try.
        He smiled and softly said,
        “Hi.”
        """),
        StoryBookPage(number: 9, text: """
        Cooper bounced and shouted, “Hi!”
        His cheesy voice went flying by.
        Quinn said, “Hi,” so calm and sweet.
        Beau tapped rhythm with his feet.
        Then Cooper whispered, “Now you try.
        Just one small word. Just one small hi.”
        """),
        StoryBookPage(number: 10, text: """
        Owen breathed in.
        Owen breathed out.
        His little knees went shake-shake-shout.
        His voice came out so soft and shy,
        “Hi.”
        The room was still.
        The room was kind.
        No one left him far behind.
        """),
        StoryBookPage(number: 11, text: """
        Cooper clapped.
        Beau Bread cheered.
        Quinn smiled bright and stood up near.
        “You did it, Owen!” Cooper cried.
        “You found the voice you kept inside!”
        Owen smiled from cheek to cheek.
        Maybe it was safe to speak.
        """),
        StoryBookPage(number: 12, text: """
        Then from the table came a squeak.
        A tiny pea rolled down the peak.
        It rolled past Beau.
        It rolled past Quinn.
        It nearly dropped into the bin.
        The pea cried, “Help! I cannot stop!”
        Owen’s eyes went big.
        “Stop!”
        """),
        StoryBookPage(number: 13, text: """
        Beau Bread jumped and caught the pea.
        Cooper shouted, “Victory!”
        Quinn said, “Owen, that was you.
        Your brave word helped the pea get through.”
        The little pea smiled up with glee.
        “Thank you, Owen Oniony!”
        """),
        StoryBookPage(number: 14, text: """
        Owen laughed a tiny laugh.
        Then Cooper gave his hand a pat.
        “Your voice is yours,” said Cooper Cheese.
        “Use it loud or soft with ease.”
        Quinn said, “Words can help. It’s true.”
        Beau Bread nodded, “We hear you.”
        """),
        StoryBookPage(number: 15, text: """
        Now Owen still was sometimes shy.
        But when he wanted, he would try.
        He did not need to shout or roar.
        One little word could open doors.
        He stood up tall, his smile bright,
        and said to all his friends that night:
        “Hi, friends.”
        And every friend came close to hear.
        Owen’s voice was welcome here.
        """)
    ]
}

private struct StoryPageView: View {
    let page: StoryBookPage

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color(red: 1.00, green: 0.97, blue: 0.88)

                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .accessibilityLabel("Illustration for page \(page.number)")

                storyText
                    .padding(.horizontal, max(16, proxy.size.width * 0.055))
                    .padding(.top, max(16, proxy.size.height * 0.025))
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.9), lineWidth: 3)
            }
            .shadow(color: .black.opacity(0.24), radius: 14, y: 8)
        }
        .aspectRatio(942.0 / 1674.0, contentMode: .fit)
        .accessibilityElement(children: .combine)
    }

    private var storyText: some View {
        Text(page.text)
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .lineSpacing(2)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.13))
            .minimumScaleFactor(0.62)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial.opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.72), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }

    private var fontSize: CGFloat {
        page.text.count > 275 ? 15 : page.text.count > 225 ? 16 : 17
    }
}

private struct PageButton: View {
    let systemImage: String
    let label: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(isEnabled ? Color(red: 0.49, green: 0.24, blue: 0.55) : Color.gray.opacity(0.45))
                .frame(width: 54, height: 48)
                .background(.white.opacity(isEnabled ? 0.94 : 0.55), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(color: .black.opacity(isEnabled ? 0.14 : 0), radius: 5, y: 3)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.42))
                    .frame(width: index == currentPage ? 17 : 7, height: 7)
                    .animation(.easeOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .accessibilityHidden(true)
    }
}

private struct StoryBookBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.62, green: 0.37, blue: 0.64),
                    Color(red: 0.94, green: 0.62, blue: 0.34)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image("PlayfulBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.22)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        StoryBookGame()
    }
}
