import Foundation

// -----------------------------------------------------------------------------

// General functionality

func loadInput() -> String {
    let filename = CommandLine.arguments.count > 1 ?
        CommandLine.arguments[1] : exampleFilename
    do
    {
        return try String(contentsOfFile: filename)
    }
    catch {
        print("Could not load input from '\(filename)'.")
        exit(1)
    }
}

struct Pos : Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    init() { self.init(0, 0) }

    static func +(lhs: Pos, rhs: Pos) -> Pos {
        return Pos(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func -(lhs: Pos, rhs: Pos) -> Pos {
        return Pos(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    @discardableResult static func +=(lhs: inout Pos, rhs: Pos) -> Pos {
        lhs = lhs + rhs
        return lhs
    }
}

// -----------------------------------------------------------------------------

func sign(_ n : Int) -> Int {
    return n > 0 ? 1 : n < 0 ? -1 : 0
}

func updateLink(pos : inout Pos, previous: Pos) {
    let delta = previous - pos
    let touching = max(abs(delta.x), abs(delta.y)) <= 1
    if !touching {
        pos = Pos(pos.x + sign(delta.x), pos.y + sign(delta.y))
    }
}

// -----------------------------------------------------------------------------

let exampleFilename = "example09.txt"

let directions = [Character("U"): Pos(0, -1), "D": Pos(0, +1), "L": Pos(-1, 0), "R": Pos(+1, 0)]
let motions = loadInput().split(separator: "\n").map{
    let tokens = $0.split(separator:" ")
    return (directions[tokens.first!.first!]!, Int(String(tokens.last!))!)
}

var rope = Array(repeating: Pos(), count: 10)
var visitedShort = Set<Pos>()
var visitedLong = Set<Pos>()
for (direction, count) in motions {
    for _ in 1...count {
        rope[0] += direction
        for index in 1..<rope.count {
            updateLink(pos: &rope[index], previous: rope[index - 1])
        }
        visitedShort.insert(rope[1])
        visitedLong.insert(rope.last!)
    }
}
print("Part 1: \(visitedShort.count)")
print("Part 2: \(visitedLong.count)")
