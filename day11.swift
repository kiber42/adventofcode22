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

enum Operation {
  case Add(Int)
  case Mult(Int)
  case Square

  func apply(_ value: Int) -> Int {
    switch self {
    case .Add(let v): return value + v
    case .Mult(let v): return value * v
    case .Square: return value * value
    }
  }

  static func parse(_ s: String.SubSequence) -> Operation {
    let tokens = s.split(separator: " ")
    assert(tokens[0] == "old")
    if tokens[2] == "old" {
      assert(tokens[1] == "*")
      return Square
    }
    let value = Int(tokens[2])!
    switch tokens[1] {
    case "+": return Add(value)
    case "*": return Mult(value)
    default: assert(false)
    }
  }
}

class Monkey {
  static var combinedTestFactor = 1

  let operation: Operation
  let divisionTest: Int
  let targetTrue: Int
  let targetFalse: Int
  let relaxFactor: Int

  var itemWorryLevels: [Int]
  var numInspections = 0

  init(description: String.SubSequence, relaxFactor: Int) {
    let lines = description.split(separator: "\n")
    itemWorryLevels = lines[1].dropFirst(18).replacingOccurrences(of: ",", with: "").split(
      separator: " "
    ).map { Int($0)! }
    operation = Operation.parse(lines[2].dropFirst(19))
    let lastNumber: (String.SubSequence) -> (Int) = { Int($0.split(separator: " ").last!)! }
    divisionTest = lastNumber(lines[3])
    targetTrue = lastNumber(lines[4])
    targetFalse = lastNumber(lines[5])
    self.relaxFactor = relaxFactor
    Monkey.combinedTestFactor *= divisionTest
  }

  typealias ItemWorryLevelAndTarget = (Int, Int)

  func doTurn() -> [ItemWorryLevelAndTarget] {
    let throwing = itemWorryLevels.map { inspect(itemWorryLevel: $0) }
    numInspections += itemWorryLevels.count
    itemWorryLevels = []
    return throwing
  }

  private func inspect(itemWorryLevel: Int) -> ItemWorryLevelAndTarget {
    let updatedLevel = (operation.apply(itemWorryLevel) / relaxFactor) % Monkey.combinedTestFactor
    let target = updatedLevel % self.divisionTest == 0 ? targetTrue : targetFalse
    return (updatedLevel, target)
  }
}

class MonkeyIsland {
  let monkeys: [Monkey]

  init(_ data: String, relaxFactor: Int) {
    Monkey.combinedTestFactor = 1
    monkeys = data.split(separator: "\n\n").map {
      Monkey(description: $0, relaxFactor: relaxFactor)
    }
  }

  func runRound() {
    for monkey in monkeys {
      for (itemWorryLevel, target) in monkey.doTurn() {
        monkeys[target].itemWorryLevels.append(itemWorryLevel)
      }
    }
  }

  func runGame(numRounds: Int) -> Int {
    for _ in 0..<numRounds {
      runRound()
    }
    let inspections = monkeys.map { $0.numInspections }.sorted()
    let n = inspections.count
    return inspections[n - 2] * inspections[n - 1]
  }
}

// -----------------------------------------------------------------------------

let data = loadInput(exampleFilename: "example11.txt")
print("Part 1:", MonkeyIsland(data, relaxFactor: 3).runGame(numRounds: 20))
print("Part 2:", MonkeyIsland(data, relaxFactor: 1).runGame(numRounds: 10000))
