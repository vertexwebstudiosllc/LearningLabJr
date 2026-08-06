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

    let book: StoryBook

    init(book: StoryBook = .owenOnion) {
        self.book = book
    }

    private var storyTitle: String { book.title }
    private var pages: [StoryBookPage] { book.pages }

    var body: some View {
        ZStack {
            StoryBookBackground(colors: book.backgroundColors)

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
                .foregroundStyle(book.accentColor)

            VStack(alignment: .leading, spacing: 0) {
                Text(storyTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.22, green: 0.16, blue: 0.14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let subtitle = book.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.42, green: 0.31, blue: 0.25))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text("Page \(pageIndex + 1) of \(pages.count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.42, green: 0.31, blue: 0.25))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: 720)
        .frame(height: book.subtitle == nil ? 44 : 52)
        .background(.white.opacity(0.88), in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 7, y: 4)
    }

    private var navigationBar: some View {
        HStack(spacing: 14) {
            PageButton(
                systemImage: "chevron.left",
                label: "Previous page",
                isEnabled: pageIndex > 0,
                accentColor: book.accentColor,
                action: goBack
            )

            PageIndicator(currentPage: pageIndex, pageCount: pages.count)
                .frame(maxWidth: 360)

            PageButton(
                systemImage: pageIndex == pages.count - 1 ? "checkmark" : "chevron.right",
                label: pageIndex == pages.count - 1 ? "Story complete" : "Next page",
                isEnabled: pageIndex < pages.count - 1,
                accentColor: book.accentColor,
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

enum StoryBook {
    case owenOnion
    case dinoBasketball

    var title: String {
        switch self {
        case .owenOnion: "Owen Onion Finds His Voice"
        case .dinoBasketball: "Trey Triceratops: Shoots for Three"
        }
    }

    var subtitle: String? {
        switch self {
        case .owenOnion: nil
        case .dinoBasketball: "A Dino Sports Club Story"
        }
    }

    fileprivate var pages: [StoryBookPage] {
        switch self {
        case .owenOnion: StoryBookPage.owenOnion
        case .dinoBasketball: StoryBookPage.dinoBasketball
        }
    }

    fileprivate var accentColor: Color {
        switch self {
        case .owenOnion: Color(red: 0.49, green: 0.24, blue: 0.55)
        case .dinoBasketball: Color(red: 0.91, green: 0.36, blue: 0.08)
        }
    }

    fileprivate var backgroundColors: [Color] {
        switch self {
        case .owenOnion:
            [Color(red: 0.62, green: 0.37, blue: 0.64), Color(red: 0.94, green: 0.62, blue: 0.34)]
        case .dinoBasketball:
            [Color(red: 0.13, green: 0.61, blue: 0.84), Color(red: 0.95, green: 0.47, blue: 0.12)]
        }
    }
}

private struct StoryBookPage: Identifiable {
    let number: Int
    let text: String
    let imagePrefix: String

    var id: Int { number }
    var imageName: String { "\(imagePrefix)\(number)" }

    init(number: Int, text: String, imagePrefix: String = "OwenOnionPage") {
        self.number = number
        self.text = text
        self.imagePrefix = imagePrefix
    }

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

    static let dinoBasketball: [StoryBookPage] = [
        StoryBookPage(number: 1, text: """
        Trey Triceratops loved to run.
        He loved to stomp.
        He loved to play.
        But most of all,
        Trey wanted to learn
        basketball one day.
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 2, text: """
        At Dino Court, the hoops stood tall.
        So did Barry Brontosaurus.
        So did Rex T-Rex.
        Barry could dunk with his long, long neck.
        Rex could jump with a thunderous
        STOMP!
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 3, text: """
        Trey looked up.
        The basket looked high.
        Very high.
        “I’m not tall like Barry,” said Trey.
        “I can’t jump like Rex.”
        His little horns drooped.
        “Maybe basketball is not for me.”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 4, text: """
        Barry bent his long neck low.
        “Basketball is for every dino,” he said.
        “Some dunk.
        Some pass.
        Some run fast.”
        Rex grinned.
        “And some learn to shoot from far away.”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 5, text: """
        “From far away?” asked Trey.
        Rex bounced the ball.
        Barry pointed to a line on the court.
        “This is the three-point line,” said Barry.
        Rex smiled.
        “Make it from here,
        and it counts as three!”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 6, text: """
        Trey gulped.
        “That is very far.”
        Barry nodded.
        “It is.”
        Rex nodded too.
        “But far things get closer
        when you practice.”
        Then they chanted:
        Feet set.
        Eyes up.
        Toss it high.
        Try, try, try.
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 7, text: """
        Trey tried his first shot.
        BONK!
        The ball hit the rim.
        He tried again.
        BOING!
        The ball bounced away.
        He tried one more time.
        WHOOSH!
        Right over the hoop.
        Trey sighed.
        “I missed them all.”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 8, text: """
        Barry smiled kindly.
        “Missing is part of learning.”
        Rex patted Trey’s back.
        “Every great shooter
        missed first.”
        Trey looked at the ball.
        “Even you?”
        Rex nodded.
        “Especially me.”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 9, text: """
        So they practiced together.
        Barry taught Trey to stand strong.
        “Point your toes to the hoop.”
        Rex taught Trey to bend his knees.
        “Use your legs, little buddy!”
        Trey whispered:
        Feet set.
        Eyes up.
        Toss it high.
        Try, try, try.
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 10, text: """
        Trey shot in the morning.
        He shot after snack.
        He shot when the sun turned orange.
        Some shots missed.
        Some shots bounced.
        One shot rolled around the rim…
        and fell out.
        Trey stomped his foot.
        “This is hard!”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 11, text: """
        Barry nodded.
        “Hard means you are learning.”
        Rex spun the ball on one claw.
        “Practice does not make it easy.”
        He winked.
        “Practice makes you braver.”
        Trey took a deep breath.
        Then he tried again.
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 12, text: """
        At last, it was game day.
        The Dino Court was full.
        Stegosaurus cheered.
        Pterodactyls flapped.
        Raptor twins waved flags.
        Trey’s tummy felt wiggly.
        “What if I miss?” he whispered.
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 13, text: """
        Barry looked at him gently.
        “Then we try again.”
        Rex smiled.
        “You are on our team
        because you worked hard.”
        The score was tied.
        Three seconds left.
        The ball bounced to Trey.
        Barry shouted, “You can do it!”
        Rex shouted, “Shoot!”
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 14, text: """
        Trey stood behind the line.
        His heart went
        thump, thump, thump.
        He remembered the chant.
        Feet set.
        Eyes up.
        Toss it high.
        Try, try, try.
        Trey shot the ball.
        Up it went.
        Higher.
        Higher.
        Swish!
        """, imagePrefix: "DinoBasketballPage"),
        StoryBookPage(number: 15, text: """
        The crowd roared.
        Barry lifted Trey high.
        Rex danced a T-Rex dance.
        Trey laughed.
        “I made a three!”
        Barry smiled.
        “You practiced.”
        Rex grinned.
        “You got brave.”
        And Trey Triceratops knew:
        Big wins can start
        with one small try.
        """, imagePrefix: "DinoBasketballPage")
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
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(isEnabled ? accentColor : Color.gray.opacity(0.45))
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
    let colors: [Color]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors,
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
