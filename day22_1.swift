import Foundation

// -----------------------------------------------------------------------------

func loadInput() -> String {
  let filename = CommandLine.arguments.count > 1 ?
    CommandLine.arguments[1] : exampleFilename
  do {
    return try String(contentsOfFile: filename)
  } catch {
    print("Could not load input from '\(filename)'.")
    exit(1)
  }
}

struct Pos {
  let x: Int
  let y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }
}

struct RowOrColumn : CustomStringConvertible {
  let start : Int
  let end : Int
  let obstacles : [Int]

  var description: String {
    return String(repeating: " ", count: start) + (start...end).map({ x in obstacles.contains(x) ? "#" : "."}).joined()
  }
}

struct Maze : CustomStringConvertible {
  let rows : [RowOrColumn]
  let columns : [RowOrColumn]

  init(_ input: String.SubSequence) {
    self.rows = Maze.buildRows(input)
    self.columns = Maze.buildColumns(self.rows)
  }

  var description: String {
    return rows.map({ $0.description }).joined(separator: "\n")
  }

  private static func buildRows(_ input : String.SubSequence) -> [RowOrColumn] {
    return input.split(separator: "\n").map({ row in
      let indexToInt = { index in row.distance(from: row.startIndex, to: index!) }
      return RowOrColumn(
        start: indexToInt(row.firstIndex(where: { $0 != " " })),
        end: indexToInt(row.lastIndex(where: { $0 != " " })),
        obstacles: row.enumerated().compactMap({ $1 == "#" ? $0 : nil })
      )
    })
  }

  private static func buildColumns(_ rows : [RowOrColumn]) -> [RowOrColumn] {
    let maxWidth = rows.map({ $0.end }).max()!
    let allObstacles = rows.enumerated().flatMap({ y, row in
      row.obstacles.map({ x in Pos(x, y) }) })

    return (0...maxWidth).map({ x in
      RowOrColumn(
        start: rows.firstIndex(where: {$0.start <= x && x <= $0.end})!,
        end: rows.lastIndex(where: {$0.start <= x && x <= $0.end})!,
        obstacles: allObstacles.compactMap({ pos in pos.x == x ? pos.y : nil })      
      )
    })
  }  
}

enum Direction: Int {
  case right = 0
  case down = 1
  case left = 2
  case up = 3
}

enum Move: CustomStringConvertible {
  case left
  case right
  case go(Int)

  var description: String {
    switch self {
    case .left:
      return "L"
    case .right:
      return "R"
    case let .go(distance):
      return "Go \(distance)"
    }
  }

  func apply(_ pos: Pos, _ dir: Direction, _ maze: Maze) -> (Pos, Direction) {
    switch self {
    case .left:
      return (pos, Direction(rawValue: (dir.rawValue + 3) % 4)!)
    case .right:
      return (pos, Direction(rawValue: (dir.rawValue + 1) % 4)!)
    case let .go(distance):
      let sideways = dir == .left || dir == .right
      let rowOrColumn = sideways ? maze.rows[pos.y] : maze.columns[pos.x]

      let updatedPos = { d in
        let p0 = rowOrColumn.start
        let wrap = rowOrColumn.end - p0 + 1
        let sign = dir == .right || dir == .down ? +1 : -1
        let p = (((sideways ? pos.x : pos.y) - p0 + d * sign) % wrap + wrap) % wrap + p0
        return sideways ? Pos(p, pos.y) : Pos(pos.x , p)
      }
      if rowOrColumn.obstacles.isEmpty {        
        return (updatedPos(distance), dir)
      }
      var goodPos = pos
      for d in 1...distance {
        let newPos = updatedPos(d)        
        if !maze.rows[newPos.y].obstacles.contains(newPos.x) {
          goodPos = newPos          
        }
        else {
          break
        }        
      }
      return (goodPos, dir)
    }
  }
}

func parseMoves(_ input: String.SubSequence) -> [Move] {
  var value = 0
  var seq: [Move] = []
  for ch in input {
    if ("0"..."9").contains(ch) {
      value = value * 10 + Int(String(ch))!
    } else {
      if value > 0 {
        seq.append(.go(value))
        value = 0
      }
      if ch == "L" {
        seq.append(.left)
      } else if ch == "R" {
        seq.append(.right)
      }
    }
  }
  if value > 0 { seq.append(.go(value)) }
  return seq
}

// -----------------------------------------------------------------------------

let exampleFilename = "example22.txt"

let inputParts = loadInput().split(separator: "\n\n")
let maze = Maze(inputParts[0])
let moves = parseMoves(inputParts[1])

var pos = Pos(maze.rows.first!.start, 0)
var dir = Direction.right
print("Start at \(pos.x + 1), \(pos.y + 1), facing \(dir)")
for move in moves {
  (pos, dir) = move.apply(pos, dir, maze)
  print("\(move)\t=> at \(pos.x + 1), \(pos.y + 1), facing \(dir)")
}
print("Part 1: \(1000 * (pos.y + 1) + 4 * (pos.x + 1) + (dir.rawValue))")
