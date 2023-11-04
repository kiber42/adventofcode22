import Foundation

func loadInput(exampleFilename: String) -> String {
  let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : exampleFilename
  do {
    return try String(contentsOfFile: filename)
  } catch {
    print("Could not load input from '\(filename)'.")
    exit(1)
  }
}

struct Pos: Hashable {
  let x, y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  init(_ data: String.SubSequence) {
    let tokens = data.split(separator: ",").compactMap { Int($0) }
    assert(tokens.count == 2)
    x = tokens[0]
    y = tokens[1]
  }

  var below: Pos { Pos(x, y + 1) }
  var left: Pos { Pos(x - 1, y) }
  var right: Pos { Pos(x + 1, y) }

  static func minMax(_ positions: [Pos]) -> (Pos, Pos) {
    assert(!positions.isEmpty)
    let xs = positions.map { $0.x }
    let ys = positions.map { $0.y }
    return (Pos(xs.min()!, ys.min()!), Pos(xs.max()!, ys.max()!))
  }

  static func direction(_ from: Pos, _ to: Pos) -> Pos {
    let sgn = { v in
      return v > 0 ? 1 : v < 0 ? -1 : 0
    }
    return Pos(sgn(to.x - from.x), sgn(to.y - from.y))
  }

  static func + (_ lhs: Pos, _ rhs: Pos) -> Pos {
    return Pos(lhs.x + rhs.x, lhs.y + rhs.y)
  }

  static func == (_ lhs: Pos, _ rhs: Pos) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
}

struct Rock {
  let edges: [Pos]
  let min: Pos
  let max: Pos

  init(_ data: String.SubSequence) {
    edges = data.split(separator: " -> ").map { Pos($0) }
    (min, max) = Pos.minMax(edges)
  }
}

struct Cave: CustomStringConvertible {
  private let entry: Pos
  private var blocked: [[Bool]]
  private let haveFloor: Bool
  private let height: Int

  init(rocks: [Rock], haveFloor: Bool) {
    let (min, max) = Pos.minMax(rocks.flatMap { [$0.min, $0.max] })
    height = max.y + 1 + (haveFloor ? 1 : 0)
    let width = max.x - min.x + 2 * height + 1
    let xoffset = height - min.x
    entry = Pos(500 + xoffset, 0)

    blocked = Array(repeating: Array(repeating: false, count: width), count: height)
    for rock in rocks {
      for (start, end) in zip(rock.edges.dropLast(), rock.edges.dropFirst()) {
        let dir = Pos.direction(start, end)
        var p = start
        while p != end {
          blocked[p.y][p.x + xoffset] = true
          p = p + dir
        }
      }
      let last = rock.edges.last!
      blocked[last.y][last.x + xoffset] = true
    }
    self.haveFloor = haveFloor
  }

  // Returns false when termination condition is reached
  mutating func dropRock() -> Bool {
    if blockedAt(entry) {
      return false
    }
    var pos = entry
    while let next = [pos.below, pos.below.left, pos.below.right].first(where: { !blockedAt($0) }) {
      pos = next
      if pos.y == height - 1 {
        if haveFloor {
          // rock stops here
          break
        } else {
          // rock disappears
          return false
        }
      }
    }
    blocked[pos.y][pos.x] = true
    return true
  }

  func blockedAt(_ pos: Pos) -> Bool {
    return blocked[pos.y][pos.x]
  }

  var description: String {
    blocked.map { $0.map { $0 ? "#" : " " }.joined() }.joined(separator: "\n")
  }
}

func countSandUnits(rocks: [Rock], haveFloor: Bool = false) -> Int {
  var cave = Cave(rocks: rocks, haveFloor: haveFloor)
  var sandCount = 0
  while cave.dropRock() {
    // print(cave)
    sandCount += 1
  }
  return sandCount
}

// -----------------------------------------------------------------------------

let rocks = loadInput(exampleFilename: "example14.txt").split(separator: "\n").map { Rock($0) }
print("Part 1:", countSandUnits(rocks: rocks))
print("Part 2:", countSandUnits(rocks: rocks, haveFloor: true))
