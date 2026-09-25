import SwiftUI

struct CozyPiece: Identifiable {
    let id: Int
    let name: String
    let kind: String
    let paint: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let instruction: String
    var color: Color { LabPaint.named(paint).color }
}
struct CozyProject: Identifiable {
    let id: String
    let name: String
    let pieces: [CozyPiece]
    let success: String
    static let retry = "Let's look together. Listen for the next piece, then tap its picture."
    static let bank: [Self] = [
        .init(id: "nest", name: "bird nest", pieces: [
            .init(id: 0, name: "Twigs", kind: "oval", paint: "brown", x: 160, y: 165, width: 220, height: 80, instruction: "Let's build a bird nest! Gather the twigs to make the bottom of our pretend nest."),
            .init(id: 1, name: "Woven sides", kind: "ring", paint: "brown", x: 160, y: 145, width: 220, height: 90, instruction: "Weave the sides to hold our nest together."),
            .init(id: 2, name: "Soft grass", kind: "oval", paint: "green", x: 160, y: 143, width: 150, height: 40, instruction: "Add soft grass to line our pretend nest."),
            .init(id: 3, name: "Pretend eggs", kind: "eggs", paint: "blue", x: 160, y: 130, width: 110, height: 55, instruction: "Settle three pretend eggs gently inside."),
        ], success: "Our cozy nest is ready! Watch real nests from far away and leave them undisturbed."),
        .init(id: "doghouse", name: "doghouse", pieces: [
            .init(id: 0, name: "Walls", kind: "rectangle", paint: "orange", x: 160, y: 145, width: 160, height: 130, instruction: "Let's build a doghouse! Start with the walls of our pretend doghouse."),
            .init(id: 1, name: "Roof", kind: "triangle", paint: "red", x: 160, y: 60, width: 210, height: 90, instruction: "Add a roof above the walls."),
            .init(id: 2, name: "Doorway", kind: "arch", paint: "brown", x: 160, y: 169, width: 66, height: 82, instruction: "Make a doorway for our dog to walk through."),
            .init(id: 3, name: "Welcome sign", kind: "bone", paint: "white", x: 160, y: 106, width: 80, height: 24, instruction: "Add a bone-shaped welcome sign."),
        ], success: "You built a doghouse with walls, a roof, and a doorway!"),
        .init(id: "cattoy", name: "cat toy", pieces: [
            .init(id: 0, name: "Ball", kind: "circle", paint: "purple", x: 160, y: 135, width: 130, height: 130, instruction: "Let's build a cat toy! Choose the soft ball for our pretend cat toy."),
            .init(id: 1, name: "Fabric stripes", kind: "stripes", paint: "pink", x: 160, y: 135, width: 105, height: 95, instruction: "Add colorful fabric stripes to the ball."),
            .init(id: 2, name: "Patch", kind: "circle", paint: "yellow", x: 160, y: 135, width: 42, height: 42, instruction: "Add a bright round patch."),
            .init(id: 3, name: "Star", kind: "star", paint: "orange", x: 160, y: 135, width: 24, height: 24, instruction: "Decorate the patch with a star."),
        ], success: "A colorful soft ball for a playful cat!"),
        .init(id: "petbed", name: "pet bed", pieces: [
            .init(id: 0, name: "Bed base", kind: "oval", paint: "brown", x: 160, y: 160, width: 235, height: 100, instruction: "Let's build a pet bed! Choose the wide base for our pet bed."),
            .init(id: 1, name: "Cushion", kind: "oval", paint: "blue", x: 160, y: 150, width: 195, height: 68, instruction: "Put a soft cushion inside the bed."),
            .init(id: 2, name: "Blanket", kind: "rectangle", paint: "purple", x: 130, y: 149, width: 100, height: 48, instruction: "Lay a cozy blanket over the cushion."),
            .init(id: 3, name: "Pillow", kind: "oval", paint: "pink", x: 222, y: 136, width: 52, height: 36, instruction: "Add a little pillow."),
        ], success: "Our pet bed has a soft place to rest!"),
        .init(id: "tunnel", name: "rabbit tunnel", pieces: [
            .init(id: 0, name: "Tunnel", kind: "rectangle", paint: "orange", x: 160, y: 133, width: 205, height: 108, instruction: "Let's build a rabbit tunnel! Start with a long pretend tunnel."),
            .init(id: 1, name: "Far opening", kind: "oval", paint: "brown", x: 258, y: 133, width: 46, height: 108, instruction: "Add the opening at the far end."),
            .init(id: 2, name: "Near opening", kind: "oval", paint: "brown", x: 62, y: 133, width: 46, height: 108, instruction: "Add the opening at the near end."),
            .init(id: 3, name: "Mat", kind: "rectangle", paint: "green", x: 160, y: 192, width: 230, height: 16, instruction: "Put a soft mat below the tunnel."),
        ], success: "Two open ends make a tunnel our rabbit can explore!"),
        .init(id: "bridge", name: "little bridge", pieces: [
            .init(id: 0, name: "Supports", kind: "supports", paint: "brown", x: 160, y: 160, width: 210, height: 100, instruction: "Let's build a little bridge! Set two supports under our pretend bridge."),
            .init(id: 1, name: "Deck", kind: "rectangle", paint: "orange", x: 160, y: 110, width: 250, height: 25, instruction: "Lay the deck across the supports."),
            .init(id: 2, name: "Rail posts", kind: "posts", paint: "brown", x: 160, y: 78, width: 220, height: 58, instruction: "Add the rail posts above the deck."),
            .init(id: 3, name: "Handrail", kind: "rectangle", paint: "yellow", x: 160, y: 50, width: 250, height: 16, instruction: "Put the handrail across the posts."),
        ], success: "Our little bridge connects one side to the other!"),
        .init(id: "flowerbox", name: "flower box", pieces: [
            .init(id: 0, name: "Box", kind: "rectangle", paint: "orange", x: 160, y: 173, width: 215, height: 68, instruction: "Let's build a flower box! Choose a box for our pretend flowers."),
            .init(id: 1, name: "Soil", kind: "rectangle", paint: "brown", x: 160, y: 142, width: 190, height: 20, instruction: "Fill the box with soil."),
            .init(id: 2, name: "Stems", kind: "stems", paint: "green", x: 160, y: 109, width: 140, height: 60, instruction: "Add three green stems."),
            .init(id: 3, name: "Flowers", kind: "flowers", paint: "pink", x: 160, y: 75, width: 170, height: 52, instruction: "Add the bright flowers to the stems."),
        ], success: "Three colorful flowers brighten our flower box!"),
        .init(id: "bughotel", name: "bug hotel", pieces: [
            .init(id: 0, name: "Frame", kind: "rectangle", paint: "orange", x: 160, y: 143, width: 180, height: 130, instruction: "Let's build a bug hotel! Start with the frame of our pretend bug hotel."),
            .init(id: 1, name: "Shelves", kind: "stripes", paint: "brown", x: 160, y: 150, width: 160, height: 90, instruction: "Add shelves inside the frame."),
            .init(id: 2, name: "Tubes", kind: "tubes", paint: "yellow", x: 160, y: 143, width: 135, height: 84, instruction: "Fill the shelves with little hollow tubes."),
            .init(id: 3, name: "Shelter roof", kind: "triangle", paint: "red", x: 160, y: 55, width: 215, height: 80, instruction: "Put a sheltering roof on top."),
        ], success: "Our pretend bug hotel has little spaces to hide!"),
        .init(id: "boat", name: "toy boat", pieces: [
            .init(id: 0, name: "Hull", kind: "hull", paint: "blue", x: 160, y: 174, width: 220, height: 65, instruction: "Let's build a toy boat! Choose the hull, the bottom of our toy boat."),
            .init(id: 1, name: "Mast", kind: "rectangle", paint: "brown", x: 160, y: 103, width: 12, height: 150, instruction: "Stand the mast in the middle."),
            .init(id: 2, name: "Sail", kind: "triangle", paint: "yellow", x: 211, y: 92, width: 85, height: 105, instruction: "Add a bright sail beside the mast."),
            .init(id: 3, name: "Flag", kind: "triangle", paint: "red", x: 138, y: 38, width: 38, height: 26, instruction: "Add a little flag at the top."),
        ], success: "A hull, a mast, and a sail! Our toy boat is ready for pretend adventures!"),
        .init(id: "table", name: "picnic table", pieces: [
            .init(id: 0, name: "Table legs", kind: "supports", paint: "brown", x: 160, y: 155, width: 150, height: 110, instruction: "Let's build a picnic table! Set the legs of our pretend picnic table."),
            .init(id: 1, name: "Tabletop", kind: "rectangle", paint: "orange", x: 160, y: 99, width: 235, height: 30, instruction: "Put the wide tabletop on the legs."),
            .init(id: 2, name: "Benches", kind: "benches", paint: "yellow", x: 160, y: 162, width: 280, height: 20, instruction: "Add a bench on each side."),
            .init(id: 3, name: "Tablecloth", kind: "rectangle", paint: "pink", x: 160, y: 97, width: 125, height: 34, instruction: "Spread a colorful tablecloth on top."),
        ], success: "Our picnic table is ready for a pretend picnic!"),
    ]
    static var narration: [String] {
        [retry] + bank.flatMap { project in
            project.pieces.flatMap { [$0.instruction, retry + " " + $0.instruction] } + [project.success]
        }
    }
}
struct CozyPlay {
    let projects: [CozyProject]
    private(set) var index = 0
    private(set) var placed = 0
    private(set) var needsHelp = false
    var complete: Bool { index == projects.count }
    var current: CozyProject { projects[min(index, projects.count - 1)] }
    var built: Bool { placed == current.pieces.count }
    var prompt: String {
        if complete { return "We did it together! You can play again or choose all done." }
        return built ? current.success : (needsHelp ? CozyProject.retry + " " : "") + current.pieces[placed].instruction
    }
    init(previousSecond: String = "") {
        var others = Array(CozyProject.bank.dropFirst()).shuffled()
        if others[0].id == previousSecond { others.swapAt(0, 1) }
        projects = [CozyProject.bank[0]] + others
    }
    mutating func choose(_ piece: Int, project: String, step: Int) {
        guard !complete, !built, current.id == project, placed == step,
              current.pieces.contains(where: { $0.id == piece }) else { return }
        guard piece == placed else { needsHelp = true; return }
        placed += 1; needsHelp = false
    }
    mutating func advance(from project: String) {
        guard !complete, built, current.id == project else { return }
        index += 1; placed = 0; needsHelp = false
    }
}
