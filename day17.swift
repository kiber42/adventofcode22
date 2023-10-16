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

enum Shape: CaseIterable {
  case HBar
  case Cross
  case Corner
  case VBar
  case Square

  var height: Int {
    switch self {
    case .HBar: return 1
    case .Cross: return 3
    case .Corner: return 3
    case .VBar: return 4
    case .Square: return 2
    }
  }

  var width: Int {
    switch self {
    case .HBar: return 4
    case .Cross: return 3
    case .Corner: return 3
    case .VBar: return 1
    case .Square: return 2
    }
  }

  var offsets: [(Int, Int)] {
    switch self {
    case .HBar: return [(0, 0), (1, 0), (2, 0), (3, 0)]
    case .Cross: return [(1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]
    case .Corner: return [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)]
    case .VBar: return [(0, 0), (0, 1), (0, 2), (0, 3)]
    case .Square: return [(0, 0), (1, 0), (0, 1), (1, 1)]
    }
  }
}

enum Direction: Character {
  case Left = "<"
  case Right = ">"
}

class LoopIterator<T>: IteratorProtocol {
  typealias Element = T

  let array: [T]
  var index: Array<T>.Index

  init(_ array: [T]) {
    assert(!array.isEmpty)
    self.array = array
    self.index = array.startIndex
  }

  func next() -> Element? {
    if index == array.endIndex {
      index = array.startIndex
    }
    let result = array[index]
    index = array.index(after: index)
    return result
  }
}

class Chamber: CustomStringConvertible {
  var data = [[Bool]]()

  private func isFree(_ shape: Shape, _ x: Int, _ y: Int) -> Bool {
    return y >= 0
      && shape.offsets.allSatisfy { (ox, oy) in
        return oy >= data.count - y || !data[y + oy][x + ox]
      }
  }

  private func place(_ shape: Shape, _ x: Int, _ y: Int) {
    while data.count < y + shape.height {
      data.append([Bool](repeating: false, count: 7))
    }
    for (ox, oy) in shape.offsets {
      data[y + oy][x + ox] = true
    }
  }

  func dropRock(shape: Shape, jets: LoopIterator<Direction>) {
    var x0 = 2
    var y0 = height + 3
    let x_max = 7 - shape.width
    repeat {
      let x_updated = min(max(x0 + (jets.next()! == .Left ? -1 : +1), 0), x_max)
      if x0 != x_updated && isFree(shape, x_updated, y0) {
        x0 = x_updated
      }
      y0 -= 1
    } while isFree(shape, x0, y0)
    y0 += 1
    place(shape, x0, y0)
  }

  func dropRocks(n: Int, shapes: LoopIterator<Shape>, jets: LoopIterator<Direction>) -> Int {
    for _ in 0..<n {
      dropRock(shape: shapes.next()!, jets: jets)
    }
    return height
  }

  var height: Int {
    return data.count
  }

  var description: String {
    return data.reversed().map { $0.map { $0 ? "#" : "." }.joined() }.joined(separator: "\n")
  }
}

func partOne(jetData: [Direction]) -> Int {
  return Chamber().dropRocks(
    n: 2022, shapes: LoopIterator(Shape.allCases), jets: LoopIterator(jetData))
}

struct Index: Hashable {
  let jet: Int
  let shape: Int
}

struct State {
  let numRocks: Int
  let height: Int
}

func partTwo(jetData: [Direction]) -> Int {
  let chamber = Chamber()
  let jets = LoopIterator(jetData)
  let shapes = LoopIterator(Shape.allCases)

  let numRocks = 1_000_000_000_000
  var cache = [Index: State]()
  for n in 0..<numRocks {
    let key = Index(jet: jets.index, shape: shapes.index)
    if let cached = cache[key] {
      // When a certain combination of jet index and shape index re-appears, it is quite likely
      // we have entered a cycle.
      // Keep moving forward on the cycle until the remaining number of rocks to drop is a multiple
      // of the number of rocks that has been simulated since the cache entry was added.
      // This simplifies the computation of the final height.
      // Since this is a heuristic, it might fail in some cases -- if this happens, add further
      // checks to confirm we're on a cycle (e.g. multiple cache hits in a row).
      let remaining = numRocks - n
      let rocksSince = n - cached.numRocks
      if remaining % rocksSince == 0 {
        let h = chamber.height
        return h + (h - cached.height) * (remaining / rocksSince)
      }
    } else {
      cache[key] = State(numRocks: n, height: chamber.height)
    }

    chamber.dropRock(shape: shapes.next()!, jets: jets)
  }
  return chamber.height
}

// -----------------------------------------------------------------------------

let jetData = loadInput(exampleFilename: "example17.txt").compactMap { Direction(rawValue: $0) }

print("Part 1:", partOne(jetData: jetData))
print("Part 2:", partTwo(jetData: jetData))
