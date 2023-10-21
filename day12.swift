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

  func neighbours(maxX: Int, maxY: Int) -> [Pos] {
    return [Pos(x - 1, y), Pos(x, y - 1), Pos(x + 1, y), Pos(x, y + 1)].compactMap {
      $0.isValid(maxX: maxX, maxY: maxY) ? $0 : nil
    }
  }

  func isValid(maxX: Int, maxY: Int) -> Bool {
    return x >= 0 && y >= 0 && x < maxX && y < maxY
  }
}

class Hill {
  let heights: [[Int]]
  let start: Pos
  let goal: Pos

  init(data: String) {
    var start = Pos(0, 0)
    var goal = Pos(0, 0)

    heights = data.split(separator: "\n").enumerated().map { y, row in
      row.enumerated().map { x, cell in
        if cell == "S" {
          start = Pos(x, y)
          return 0
        }
        if cell == "E" {
          goal = Pos(x, y)
          return 25
        }
        return Int(cell.asciiValue! - Character("a").asciiValue!)
      }
    }
    self.start = start
    self.goal = goal
  }
  
  func distancesToGoal() -> (Int, Int) {
    let maxX = heights.first!.count
    let maxY = heights.count
    var queue = [goal]
    var visited = Set<Pos>(queue)
    var distance = 0
    var minDistance: Int?

    // Find path from goal to possible starting points
    while !queue.isEmpty {
      distance += 1
      queue = queue.flatMap { cell in
        // Due to the reversed order, must not step down by more than 1
        let minHeight = heights[cell.y][cell.x] - 1
        return cell.neighbours(maxX: maxX, maxY: maxY).filter {
          heights[$0.y][$0.x] >= minHeight && visited.insert($0).0
        }
      }
      if minDistance == nil {
        if queue.map({ heights[$0.y][$0.x] }).contains(0) {
          minDistance = distance
        }
      } else if queue.contains(start) {
        break
      }
    }
    return (distance, minDistance ?? distance)
  }
}

// -----------------------------------------------------------------------------

let hill = Hill(data: loadInput(exampleFilename: "example12.txt"))
let distances = hill.distancesToGoal()
print("Part 1:", distances.0)
print("Part 2:", distances.1)
