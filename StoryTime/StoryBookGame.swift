//
//  StoryBookGame.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI

struct StoryBookGame: View {
    @State private var pageIndex = 0
    private let storyTitle = "Adventures of Owen Onion Volume 1"

    private let pages: [StoryBookPage] = [
        StoryBookPage(
            title: "Adventures of Owen Onion Volume 1",
            text: "By Matthew Teitelman",
            symbolName: "book.closed.fill",
            colors: [Color(red: 0.50, green: 0.34, blue: 0.66), Color(red: 0.98, green: 0.78, blue: 0.34)],
            isCover: true
        ),
        StoryBookPage(
            title: "Page 1",
            text: """
            It was almost dinner time.
            Tara opened the fridge, pantry, and cabinet.
            "What should I cook?" she said.
            The got all the food's attention.
            Whoever got selected for dinner was a very big deal.
            """,
            symbolName: "house.fill",
            colors: [Color(red: 0.96, green: 0.70, blue: 0.30), Color(red: 0.98, green: 0.88, blue: 0.45)]
        ),
        StoryBookPage(
            title: "Page 2",
            text: """
            On the counter sat Owen Onion.
            Owen a yellow onion was small and quiet.
            Although he had many layers.
            He did not have many words.
            But he loved numbers.
            "One Onion," Owen whispered.
            """,
            symbolName: "circle.fill",
            colors: [Color(red: 0.50, green: 0.34, blue: 0.66), Color(red: 0.85, green: 0.66, blue: 0.92)]
        ),
        StoryBookPage(
            title: "Page 3",
            text: """
            Beside Owen was Cooper Cheese.
            Cooper was loud, silly, and a big talker.
            He wore a baseball cap.
            He loved socking dingers.
            "Watch this!" Cooper shouted.
            CRACK!
            A pea flew into the fruit bowl.
            "DINGER!"
            """,
            symbolName: "baseball.fill",
            colors: [Color(red: 0.92, green: 0.62, blue: 0.18), Color(red: 0.99, green: 0.86, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 4",
            text: """
            Next to Cooper was Beau Bread.
            Beau was Cooper's little brother.
            He was soft, kind, and quiet.
            Beau did not speak much either.
            He mostly smiled and nodded.
            Owen, Cooper, and Beau liked playing together.
            """,
            symbolName: "square.fill",
            colors: [Color(red: 0.68, green: 0.46, blue: 0.25), Color(red: 0.96, green: 0.78, blue: 0.46)]
        ),
        StoryBookPage(
            title: "Page 5",
            text: """
            From the pantry came a tiny voice.
            "Attention, foods!"
            It was Quinn Quinoa.
            Quinn was new, healthy, and a bit BOSSY.
            She was also Owen's little sister.
            Behind her stood the carrots, peas, broccoli, spinach, and cucumber.
            """,
            symbolName: "leaf.fill",
            colors: [Color(red: 0.28, green: 0.58, blue: 0.36), Color(red: 0.70, green: 0.86, blue: 0.42)]
        ),
        StoryBookPage(
            title: "Page 6",
            text: """
            Quinn noticed Tara left her recipe book out.
            "Tara always picks cheesy foods," she said.
            Cooper smiled proudly.
            "That changes Tonight! We will make sure Tara wants something healthy."
            Owen looked at the book, then at Quinn.
            "Balance," he said.
            But no one heard.
            """,
            symbolName: "scale.3d",
            colors: [Color(red: 0.32, green: 0.56, blue: 0.48), Color(red: 0.90, green: 0.72, blue: 0.38)]
        ),
        StoryBookPage(
            title: "Page 7",
            text: """
            Tara picked up the big red recipe book.
            "Hmmm," she said.
            "Maybe I'll make a cheesy onion bread bake?"
            Owen smiled as he said "Onion".
            Cooper cheered.
            Beau gave a big nod.
            Quinn was not happy as she scowled and crossed her arms.
            """,
            symbolName: "book.fill",
            colors: [Color(red: 0.78, green: 0.18, blue: 0.18), Color(red: 0.96, green: 0.58, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 8",
            text: """
            Quinn had an idea.
            "If we hide the recipe book," she said,
            "Tara will choose a healthy meal made with Quinoa!"
            The other healthy foods nodded, afraid to go against Quinn.
            Owen shook his head as he tried to get words out.
            "No," he said.
            But Quinn didn't hear and was already getting her plan started.
            """,
            symbolName: "exclamationmark.triangle.fill",
            colors: [Color(red: 0.44, green: 0.30, blue: 0.58), Color(red: 0.88, green: 0.62, blue: 0.38)]
        ),
        StoryBookPage(
            title: "Page 9",
            text: """
            Quinn and the other healthy foods pushed the recipe book out of sight.
            THUMP, BUMP, FLIP.
            The recipe book slid behind the flour bin.
            Quinn smiled with joy.
            "Perfect."
            Owen tried to say Stop, but couldn't find the right word.
            "Oh no," he whispered.
            """,
            symbolName: "archivebox.fill",
            colors: [Color(red: 0.36, green: 0.44, blue: 0.56), Color(red: 0.78, green: 0.68, blue: 0.48)]
        ),
        StoryBookPage(
            title: "Page 10",
            text: """
            Tara came back, and went to grab her reciped book.
            "My recipe book is gone!"
            She looked all around, everywhere except behind the flour bin.
            So instead she picked up her phone.
            "I guess I'll just order fast food."
            The foods in the kitchen all froze.
            Quinn gasped.
            "That was not the plan."
            """,
            symbolName: "phone.fill",
            colors: [Color(red: 0.24, green: 0.40, blue: 0.62), Color(red: 0.90, green: 0.56, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 11",
            text: """
            Tara tapped her phone.
            "Maybe burgers."
            Tap.
            "Maybe fries."
            Tap.
            "Maybe nuggets."
            Owen looked at Quinn.
            Then at Cooper.
            Then at Beau.
            "Help," Owen said, as he pointed at the hidden recipe book.
            """,
            symbolName: "figure.walk",
            colors: [Color(red: 0.30, green: 0.52, blue: 0.68), Color(red: 0.96, green: 0.72, blue: 0.40)]
        ),
        StoryBookPage(
            title: "Page 12",
            text: """
            The book was far away.
            It was behind the flour and bowl of fruit.
            Cooper gulped.
            "How are we going to move the recipe book, its stuck behind the flour."
            Owen looked around.
            "One," he said, pointing to a spoon on the counter.
            "Two," he said, pointing to Beau.
            "Three," he said, pointing to Cooper.
            Owen had a plan.
            """,
            symbolName: "lightbulb.fill",
            colors: [Color(red: 0.34, green: 0.54, blue: 0.64), Color(red: 0.92, green: 0.78, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 13",
            text: """
            Owen placed the spoon under a corner of the Recipe Book.
            It wobbled a little, but remained in place.
            Owen tried to step onto the spoon, but couldn't do it by himself.
            "Help," he said.
            Cooper grabbed the spoon handle like a baseball bat, and held it still.
            Owen smiled.
            Beau nodded, and gave Owen a boost up.
            """,
            symbolName: "ruler.fill",
            colors: [Color(red: 0.50, green: 0.36, blue: 0.28), Color(red: 0.92, green: 0.70, blue: 0.40)]
        ),
        StoryBookPage(
            title: "Page 14",
            text: """
            Owen stepped up onto Beau, positioning himself infront of the spoon.
            "One, Two, Three, JUMP!" yelled Owen.
            He jumped as high as he could, aiming to land on the spoon handle.
            Beau reached out and caught him.
            The recipe book tipped over and became unstuck from its hiding spot.
            "Thanks!" Owen proclaimed.
            Beau smiled.
            """,
            symbolName: "hand.raised.fill",
            colors: [Color(red: 0.44, green: 0.52, blue: 0.62), Color(red: 0.94, green: 0.76, blue: 0.48)]
        ),
        StoryBookPage(
            title: "Page 15",
            text: """
            Owen, Cooper, and Beau were ready to celebrate.
            Cooper yelled "We did it!".
            They approached the recipe book.
            "Oof," said Owen.
            Owen turned and...
            "NOT SO FAST!"
            Quinn and her healthy food minions stepped in the way.
            Owen tried to reason with her but couldn't find his words.
            """,
            symbolName: "minus.circle.fill",
            colors: [Color(red: 0.26, green: 0.50, blue: 0.70), Color(red: 0.80, green: 0.76, blue: 0.56)]
        ),
        StoryBookPage(
            title: "Page 16",
            text: """
            Cooper yelled "Move, now!".
            "The Grapes stepped up."
            Cooper took out his baseball bat and...
            "Dinger." exclaimed Cooper as he swung his bat.
            The grape flew over the counter top.
            """,
            symbolName: "sum",
            colors: [Color(red: 0.42, green: 0.48, blue: 0.62), Color(red: 0.90, green: 0.74, blue: 0.44)]
        ),
        StoryBookPage(
            title: "Page 17",
            text: """
            Next came the Rolling Pin Ridge.
            The rolling pin was big and heavy.
            Cooper pushed.
            It rolled back.
            Carrot pushed.
            It did not move.
            Owen pointed to everyone.
            "Add," he said.
            """,
            symbolName: "plus.circle.fill",
            colors: [Color(red: 0.58, green: 0.42, blue: 0.28), Color(red: 0.94, green: 0.72, blue: 0.46)]
        ),
        StoryBookPage(
            title: "Page 18",
            text: """
            Cooper pushed.
            Quinn pushed.
            Beau pushed.
            The healthy foods pushed too.
            Owen counted.
            "One. Two. Three. Four. Five."
            RUMBLE.
            The rolling pin moved.
            "Teamwork!" Cooper cheered.
            """,
            symbolName: "5.circle.fill",
            colors: [Color(red: 0.34, green: 0.58, blue: 0.42), Color(red: 0.96, green: 0.78, blue: 0.40)]
        ),
        StoryBookPage(
            title: "Page 19",
            text: """
            At last, they found the recipe book.
            But three flour sacks blocked it.
            Owen counted them.
            "One. Two. Three."
            He pointed to the first sack.
            "Minus."
            They moved it away.
            """,
            symbolName: "book.pages.fill",
            colors: [Color(red: 0.72, green: 0.22, blue: 0.22), Color(red: 0.96, green: 0.76, blue: 0.40)]
        ),
        StoryBookPage(
            title: "Page 20",
            text: """
            "Minus," Owen said again.
            They moved the second sack.
            "Minus."
            They moved the third.
            The book was free.
            Quinn looked at Owen.
            "You did it."
            Owen shook his head.
            "Together."
            """,
            symbolName: "person.3.fill",
            colors: [Color(red: 0.32, green: 0.54, blue: 0.62), Color(red: 0.92, green: 0.74, blue: 0.38)]
        ),
        StoryBookPage(
            title: "Page 21",
            text: """
            The book was heavy.
            Very heavy.
            Tara still had her phone.
            "I'll order in five minutes," she said.
            Owen's eyes grew wide.
            "Five!"
            They had to hurry.
            """,
            symbolName: "timer",
            colors: [Color(red: 0.24, green: 0.46, blue: 0.66), Color(red: 0.92, green: 0.62, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 22",
            text: """
            Everyone pushed the book.
            It scraped.
            It bumped.
            It almost fell into the dog bowl.
            Owen counted down.
            "Four. Three. Two. One."
            The book slid under the table.
            But Tara still could not see it.
            """,
            symbolName: "arrow.right.circle.fill",
            colors: [Color(red: 0.30, green: 0.56, blue: 0.62), Color(red: 0.90, green: 0.72, blue: 0.40)]
        ),
        StoryBookPage(
            title: "Page 23",
            text: """
            They opened the book.
            Cooper flipped to grilled cheese.
            Quinn flipped to kale soup.
            Cooper flipped back.
            Quinn flipped again.
            The pages flapped wildly.
            Owen climbed on top.
            "Stop!"
            Everyone stopped.
            """,
            symbolName: "book.fill",
            colors: [Color(red: 0.78, green: 0.18, blue: 0.18), Color(red: 0.96, green: 0.58, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 24",
            text: """
            Owen pointed to one recipe.
            It said:
            Golden Onion Cheese Bread Bake
            with Rainbow Quinoa Crunch
            Cooper smiled.
            "I'm in it!"
            Beau nodded.
            Quinn smiled too.
            "So am I."
            Owen said, "Balance."
            """,
            symbolName: "scale.3d",
            colors: [Color(red: 0.24, green: 0.56, blue: 0.58), Color(red: 0.94, green: 0.76, blue: 0.38)]
        ),
        StoryBookPage(
            title: "Page 25",
            text: """
            Cooper grabbed a pea.
            "I'll get Tara's attention."
            He tossed it high.
            CRACK!
            The pea hit the book.
            The book slid across the floor.
            It bumped Tara's slipper.
            Tara looked down.
            "My recipe book!"
            """,
            symbolName: "baseball.diamond.bases",
            colors: [Color(red: 0.86, green: 0.52, blue: 0.22), Color(red: 0.98, green: 0.82, blue: 0.42)]
        ),
        StoryBookPage(
            title: "Page 26",
            text: """
            Tara picked up the book.
            She saw the open page.
            "Golden Onion Cheese Bread Bake," she read.
            "With Rainbow Quinoa Crunch."
            She smiled.
            "That sounds perfect."
            Owen whispered, "Perfect."
            """,
            symbolName: "star.fill",
            colors: [Color(red: 0.32, green: 0.56, blue: 0.48), Color(red: 0.96, green: 0.80, blue: 0.36)]
        ),
        StoryBookPage(
            title: "Page 27",
            text: """
            Tara chopped onion.
            Toasted bread.
            Melted cheese.
            Cooked quinoa.
            Added carrots, peas, broccoli, and spinach.
            The kitchen smelled warm and wonderful.
            Cooper grinned.
            Quinn stood proudly.
            Beau gave a big nod.
            """,
            symbolName: "flame.fill",
            colors: [Color(red: 0.88, green: 0.40, blue: 0.24), Color(red: 0.96, green: 0.78, blue: 0.34)]
        ),
        StoryBookPage(
            title: "Page 28",
            text: """
            Tara took a bite.
            Then another.
            "This is delicious," she said.
            The foods cheered.
            Owen counted Tara's happy bites.
            "One. Two. Three."
            Quinn sat beside him.
            "You saved dinner," she said.
            Owen smiled.
            "Together."
            """,
            symbolName: "fork.knife.circle.fill",
            colors: [Color(red: 0.36, green: 0.58, blue: 0.42), Color(red: 0.96, green: 0.76, blue: 0.40)]
        ),
        StoryBookPage(
            title: "Page 29",
            text: """
            After that, Quinn never hid the recipe book again.
            Cooper still socked dingers.
            Beau still spoke mostly in nods.
            And Owen still used one word at a time.
            But everyone listened.
            Because Owen's small words...
            added up.
            """,
            symbolName: "plus.forwardslash.minus",
            colors: [Color(red: 0.28, green: 0.50, blue: 0.68), Color(red: 0.86, green: 0.76, blue: 0.44)]
        ),
        StoryBookPage(
            title: "Page 30",
            text: """
            Whenever Tara wondered what to cook, the foods worked together.
            Cooper brought the fun.
            Quinn brought the healthy choices.
            Beau brought quiet courage.
            Owen brought the math.
            And dinner brought everyone together.
            Owen smiled and said:
            "Balance."
            """,
            symbolName: "heart.fill",
            colors: [Color(red: 0.46, green: 0.32, blue: 0.62), Color(red: 0.82, green: 0.66, blue: 0.86)]
        ),
        StoryBookPage(
            title: "The End",
            text: "The End",
            symbolName: "sparkles",
            colors: [Color(red: 0.50, green: 0.34, blue: 0.66), Color(red: 0.98, green: 0.78, blue: 0.34)],
            isCover: true
        )
    ]

    var body: some View {
        ZStack(alignment: .center) {
            StoryBookBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)

            GeometryReader { proxy in
                VStack(spacing: 14) {
                    PageIndicator(currentPage: pageIndex, pageCount: pages.count)
                        .padding(.top, 12)

                    StoryPageView(page: pages[pageIndex], availableHeight: proxy.size.height)
                        .frame(maxWidth: min(proxy.size.width - 32, 620))
                        .frame(maxHeight: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id(pageIndex)

                    HStack(spacing: 18) {
                        PageButton(systemImage: "chevron.left", isEnabled: pageIndex > 0) {
                            goBack()
                        }

                        Text("\(pageIndex + 1) / \(pages.count)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 72)

                        PageButton(systemImage: "chevron.right", isEnabled: pageIndex < pages.count - 1) {
                            goForward()
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 35)
                        .onEnded { value in
                            if value.translation.width < -40 {
                                goForward()
                            } else if value.translation.width > 40 {
                                goBack()
                            }
                        }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StoryBookBackground().ignoresSafeArea(.all))
        .navigationTitle(storyTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func goBack() {
        guard pageIndex > 0 else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            pageIndex -= 1
        }
    }

    private func goForward() {
        guard pageIndex < pages.count - 1 else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            pageIndex += 1
        }
    }
}

private struct StoryBookPage {
    let title: String
    let text: String
    let symbolName: String
    let colors: [Color]
    var isCover = false
}

private struct StoryPageView: View {
    let page: StoryBookPage
    let availableHeight: CGFloat

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: page.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: page.symbolName)
                    .font(.system(size: 110, weight: .bold))
                    .foregroundColor(.white.opacity(0.92))
                    .shadow(color: Color.black.opacity(0.16), radius: 10, x: 0, y: 6)
            }
            .frame(maxHeight: max(130, availableHeight * 0.28))

            pageText
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.24), radius: 14, x: 0, y: 8)
    }

    @ViewBuilder
    private var pageText: some View {
        if page.isCover {
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.16, green: 0.20, blue: 0.28))
                    .minimumScaleFactor(0.65)

                Text(page.text)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.34, green: 0.38, blue: 0.46))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Text(page.text)
                .font(.system(size: textFontSize(for: page.text), weight: .semibold, design: .rounded))
                .lineSpacing(lineSpacing(for: page.text))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.24, green: 0.28, blue: 0.36))
                .minimumScaleFactor(0.55)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func textFontSize(for text: String) -> CGFloat {
        switch text.count {
        case 0...180:
            20
        case 181...260:
            18
        case 261...340:
            16
        default:
            14
        }
    }

    private func lineSpacing(for text: String) -> CGFloat {
        text.count > 260 ? 2 : 4
    }
}

private struct PageButton: View {
    let systemImage: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isEnabled ? Color(red: 0.18, green: 0.24, blue: 0.34) : .white.opacity(0.45))
                .frame(width: 58, height: 50)
                .background(isEnabled ? Color.white : Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

private struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.35))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
            }
        }
        .frame(height: 18)
    }
}

private struct StoryBookBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.26, green: 0.49, blue: 0.73),
                    Color(red: 0.43, green: 0.76, blue: 0.68)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Image("PlayfulBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.45)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    NavigationStack {
        StoryBookGame()
    }
}
