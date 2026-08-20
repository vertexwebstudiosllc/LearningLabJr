//
//  StoryBookGame.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI

struct StoryBookGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pageIndex = 0
    @StateObject private var narrator = GameNarrator()
    let book: StoryBook

    init(book: StoryBook = .owenOnion) { self.book = book }
    private var pages: [StoryBookPage] { book.pages }
    private var lastPage: Bool { pageIndex == pages.count - 1 }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(book.title).font(.system(.title3, design: .rounded, weight: .bold))
                    Text("Page \(pageIndex + 1) of \(pages.count) • Read together")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Button { narrator.speak(pages[pageIndex].text) } label: {
                    Image(systemName: "speaker.wave.2.fill").font(.title2.bold())
                        .frame(width: 64, height: 64)
                        .background(book.accentColor.opacity(0.12), in: Circle())
                }.accessibilityLabel("Read this page aloud")
            }.padding(.horizontal, 18).padding(.top, 12)

            ScrollView {
                VStack(spacing: 16) {
                    StoryPageView(page: pages[pageIndex])
                    Text(lastPage ? "The end. Which part would you like to talk about?" : "Pause together: What do you notice in this picture?")
                        .font(.system(.body, design: .rounded)).multilineTextAlignment(.center)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(book.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
                }.padding(.horizontal, 18).padding(.bottom, 18)
                    .frame(maxWidth: 760).frame(maxWidth: .infinity)
            }.id(pageIndex)

            HStack(spacing: 12) {
                Button {
                    guard pageIndex > 0 else { return }
                    narrator.stop()
                    pageIndex -= 1
                } label: {
                    Image(systemName: "chevron.left").font(.title2.bold()).frame(width: 64, height: 64)
                        .background(book.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
                }.disabled(pageIndex == 0).accessibilityLabel("Previous page")

                if lastPage {
                    ToddlerActionButton(title: "Read again", systemImage: "arrow.counterclockwise", color: book.accentColor) { narrator.stop(); pageIndex = 0 }
                    ToddlerActionButton(title: "All done", systemImage: "checkmark", color: book.accentColor) { dismiss() }
                } else {
                    ToddlerActionButton(title: "Next page", systemImage: "chevron.right", color: book.accentColor) {
                        guard pageIndex < pages.count - 1 else { return }
                        narrator.stop()
                        pageIndex += 1
                    }
                }
            }.padding(.horizontal, 18).padding(.bottom, 12)
        }
        .foregroundStyle(Color(red: 0.15, green: 0.19, blue: 0.25))
        .tint(book.accentColor)
        .background(Color(red: 0.99, green: 0.97, blue: 0.92).ignoresSafeArea())
        .navigationTitle("Read Together")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: pageIndex) { narrator.speak(pages[pageIndex].text) }
        .onDisappear { narrator.stop() }
    }
}

enum StoryBook {
    case owenOnion
    case dinoBasketball
    case dinoHockey
    case dinoBaseball

    var title: String {
        switch self {
        case .owenOnion: "Owen Onion Finds His Voice"
        case .dinoBasketball: "Trey Triceratops: Shoots for Three"
        case .dinoHockey: "Trey Triceratops: Scores a Hat Trick"
        case .dinoBaseball: "Trey Triceratops: Hits a Triple"
        }
    }

    var subtitle: String? {
        switch self {
        case .owenOnion: nil
        case .dinoBasketball: "A Dino Sports Club Story"
        case .dinoHockey: "A Dino Sports Club Story"
        case .dinoBaseball: "A Dino Sports Club Story"
        }
    }

    fileprivate var pages: [StoryBookPage] {
        switch self {
        case .owenOnion: StoryBookPage.owenOnion
        case .dinoBasketball: StoryBookPage.dinoBasketball
        case .dinoHockey: StoryBookPage.dinoHockey
        case .dinoBaseball: StoryBookPage.dinoBaseball
        }
    }

    fileprivate var accentColor: Color {
        switch self {
        case .owenOnion: Color(red: 0.49, green: 0.24, blue: 0.55)
        case .dinoBasketball: Color(red: 0.91, green: 0.36, blue: 0.08)
        case .dinoHockey: Color(red: 0.08, green: 0.52, blue: 0.78)
        case .dinoBaseball: Color(red: 0.18, green: 0.55, blue: 0.22)
        }
    }

    fileprivate var backgroundColors: [Color] {
        switch self {
        case .owenOnion:
            [Color(red: 0.62, green: 0.37, blue: 0.64), Color(red: 0.94, green: 0.62, blue: 0.34)]
        case .dinoBasketball:
            [Color(red: 0.13, green: 0.61, blue: 0.84), Color(red: 0.95, green: 0.47, blue: 0.12)]
        case .dinoHockey:
            [Color(red: 0.34, green: 0.77, blue: 0.94), Color(red: 0.72, green: 0.90, blue: 0.98)]
        case .dinoBaseball:
            [Color(red: 0.20, green: 0.62, blue: 0.30), Color(red: 0.93, green: 0.57, blue: 0.20)]
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

    static let dinoHockey: [StoryBookPage] = [
        StoryBookPage(number: 1, text: """
        Snowflakes danced on Dino Pond.
        The ice was shiny, smooth, and wide.
        Trey Triceratops peeked out slowly.
        “I want to play hockey,” he said.
        Then he took one tiny slide.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 2, text: """
        On the ice stood Milo Mammoth.
        Big feet. Warm fur. Kind eyes.
        Milo pushed the puck with a gentle tap.
        “Come on, Trey,” he called.
        “Hockey starts with one brave glide.”
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 3, text: """
        Beside Milo zipped Sasha Smilodon.
        Sasha was quick.
        Sasha was clever.
        Sasha swished her tail and skated in loops.
        “Zoom, zoom, zip!” she cheered.
        “Hockey is fast and fun!”
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 4, text: """
        Trey stepped onto the ice.
        Slip. Slide. Wobble.
        WHUMP!
        Trey landed on his belly.
        His hockey stick flew into the snow.
        “I am not good at ice,” Trey sighed.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 5, text: """
        Milo helped Trey up.
        “Falling is part of skating,” said Milo.
        Sasha nodded.
        “And trying again is part of winning.”
        Trey looked at the ice.
        It still looked slippery.
        But his friends looked kind.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 6, text: """
        Milo showed Trey how to stand.
        “Feet wide. Knees bent. Horn up high.”
        Sasha showed him how to glide.
        “Small push.
        Little slide.
        Try, try, try.”
        Trey whispered,
        “Try, try, try.”
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 7, text: """
        Soon Trey could glide.
        Not fast. Not fancy.
        But forward.
        Swish.
        Trey smiled.
        “I’m skating!”
        Milo trumpeted.
        Sasha cheered.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 8, text: """
        Then Trey saw Milo shoot the puck.
        SLAP!
        The puck zipped across the ice.
        Sasha shot next. SLAP!
        The puck zoomed into the net.
        Trey’s eyes grew wide.
        “I want to learn that!”
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 9, text: """
        “That is a slapshot,” said Milo.
        “It takes practice.”
        Sasha tapped Trey’s stick.
        “Stick down. Eyes up.
        Swing back. Slap!”
        Trey nodded.
        “Slapshot,” he whispered.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 10, text: """
        Trey tried. Tap.
        The puck moved one inch.
        He tried again. Bonk.
        The puck spun in a circle.
        He tried once more.
        Whoops!
        Trey spun in a circle too.
        “I can’t do it,” he said.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 11, text: """
        Milo smiled. “Not yet.”
        Sasha smiled too.
        “Yet is a little word
        with a big job.”
        So Trey practiced.
        Stick down. Eyes up.
        Swing back. Slap!
        Again. And again. And again.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 12, text: """
        At last, it was game day.
        Snow dinos filled the rink.
        Penguins waved little flags.
        A pterodactyl blew the whistle.
        Trey held his stick tight.
        “What if I miss?” he asked.
        Milo said, “Then we keep playing.”
        Sasha said, “And we help our team.”
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 13, text: """
        The puck slid to Trey.
        He remembered his practice.
        Stick down. Eyes up.
        Swing back. Slap!
        WHOOSH! Goal one!
        The crowd cheered.
        Trey blinked. “I did it!”
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 14, text: """
        The game went on.
        Trey skated. Trey passed.
        Trey tried again. SLAP!
        Goal two!
        Then, with one chilly second left,
        the puck came back to Trey.
        His heart went thump, thump, thump.
        """, imagePrefix: "DinoHockeyPage"),
        StoryBookPage(number: 15, text: """
        Trey took one brave breath.
        Stick down. Eyes up. Swing back.
        Slap! The puck flew. The net shook.
        Goal three! “A hat trick!” cried Milo.
        Sasha spun in happy circles.
        Trey smiled big.
        He had learned something true:
        Practice makes you better.
        And trying again can help you score.
        """, imagePrefix: "DinoHockeyPage")
    ]

    static let dinoBaseball: [StoryBookPage] = [
        StoryBookPage(number: 1, text: """
        The sun was bright on Dino Field.
        The grass was soft and green.
        Trey Triceratops held a bat.
        “I want to play baseball,” he said.
        Then he looked at home plate.
        “And I want to hit the ball.”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 2, text: """
        Out in center field stood Vincent Velociraptor.
        Vincent was quick. Vincent was clever.
        Vincent could run, run, run!
        He chased fly balls with speedy feet.
        “Baseball is fun,” Vincent called.
        “Come try with us, Trey!”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 3, text: """
        At first base stood Annie Ankylosaurus.
        Annie was strong. Annie was steady.
        Annie had a mighty tail and a happy grin.
        When Annie hit the ball…
        CRACK! It flew over the ferns.
        “Whoa,” said Trey.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 4, text: """
        Trey stepped up to bat.
        Vincent tossed the ball softly.
        Trey swung. WHOOSH!
        He missed. Annie tossed another.
        Trey swung again. WHOOSH!
        He missed again.
        Trey’s horns drooped.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 5, text: """
        “I can’t hit,” Trey said.
        Vincent jogged in from center field.
        “Not yet,” he said.
        Annie nodded. “Every hitter starts with practice.”
        Trey looked at the bat. “Even big hitters?”
        Annie smiled. “Especially big hitters.”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 6, text: """
        Vincent showed Trey his feet.
        “Stand strong.” Annie showed Trey his hands.
        “Hold tight.” Vincent pointed to the ball.
        “Watch close.” Together they chanted:
        Feet set. Eyes bright. Swing smooth.
        Hold tight.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 7, text: """
        Trey tried again.
        Feet set. Eyes on the ball.
        Swing smooth. Hold tight.
        TAP! The ball rolled two tiny steps.
        Trey blinked. “I hit it?”
        Vincent cheered. “You hit it!”
        Annie clapped. “That is where hitting starts.”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 8, text: """
        So Trey practiced.
        He hit soft tosses.
        He hit little grounders.
        He hit one ball into a mud puddle.
        SPLAT! Vincent laughed.
        Annie laughed.
        Trey laughed too.
        Practice was hard…
        but practice could be fun.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 9, text: """
        Some balls went left.
        Vincent chased them.
        Some balls went right.
        Annie scooped them up.
        Some balls barely moved at all.
        Trey sighed. “This is taking a long time.”
        Annie smiled. “Good things can take time.”
        Vincent said, “Try again.”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 10, text: """
        Trey took a breath.
        Feet set. Eyes bright.
        Swing smooth. Hold tight.
        CRACK!
        The ball bounced past Annie.
        It rolled all the way to the fern fence.
        Trey’s eyes grew wide. “I did it!”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 11, text: """
        At last, it was game day.
        Dino Field was full.
        Pterodactyls flapped.
        Stegosaurus waved a flag.
        Little raptors stomped and cheered.
        Trey held his bat close.
        His tummy felt wiggly.
        “What if I miss?” he whispered.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 12, text: """
        Vincent stood beside him.
        “Then we cheer for the next try.”
        Annie gave Trey a gentle nod.
        “You practiced.” Vincent smiled.
        “You worked hard.”
        Annie smiled too. “So now, trust your swing.”
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 13, text: """
        It was the last inning.
        Three dinos were on base.
        The game was almost done.
        Trey stepped up to home plate.
        The crowd got quiet.
        Vincent called, “You can do it!”
        Annie called, “Remember the chant!”
        Trey took one brave breath.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 14, text: """
        Feet set. Eyes on the ball.
        Swing smooth. Hold tight.
        The ball came in.
        Trey swung. CRACK!
        The ball soared over first base.
        It bounced past second.
        It rolled deep into center field.
        “Run, Trey, run!” shouted Vincent.
        """, imagePrefix: "DinoBaseballPage"),
        StoryBookPage(number: 15, text: """
        Trey ran to first.
        Then second.
        Then third.
        SAFE! Three dinos scored.
        The crowd roared.
        “Trey hit a triple!” shouted Annie.
        Vincent jumped high. Trey smiled big.
        He had learned something true:
        Practice helps. Friends help too.
        And one brave swing can win the game.
        """, imagePrefix: "DinoBaseballPage")
    ]
}

private struct StoryPageView: View {
    let page: StoryBookPage
    var body: some View {
        VStack(spacing: 20) {
            Text(page.text)
                .font(.system(.title3, design: .rounded, weight: .medium))
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
            Image(page.imageName)
                .resizable().scaledToFit()
                .frame(maxHeight: 500)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .accessibilityLabel("Story illustration for page \(page.number)")
        }
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
