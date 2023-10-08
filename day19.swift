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

enum Mineral: Int, CaseIterable {
  case Ore = 0
  case Clay = 1
  case Obsidian = 2
  case Geode = 3
}

typealias BotType = Mineral

struct Counts: Hashable {
  private let n: [Int]

  private init(_ n: [Int]) { self.n = n }

  init(ore: Int = 0, clay: Int = 0, obsidian: Int = 0, geode: Int = 0) {
    n = [ore, clay, obsidian, geode]
  }

  subscript(_ mineral: Mineral) -> Int {
    return n[mineral.rawValue]
  }

  static func + (a: Counts, b: Counts) -> Counts {
    return Counts((0..<Mineral.allCases.count).map { a.n[$0] + b.n[$0] })
  }
  static func - (a: Counts, b: Counts) -> Counts {
    return Counts((0..<Mineral.allCases.count).map { a.n[$0] - b.n[$0] })
  }
  static func + (a: Counts, m: Mineral) -> Counts {
    return Counts(
      (0..<Mineral.allCases.count).map { a.n[$0] + (m == Mineral(rawValue: $0)! ? 1 : 0) })
  }

  var valid: Bool { return n.allSatisfy { $0 >= 0 } }
}

typealias Minerals = Counts
typealias BotCounts = Counts

struct Blueprint {
  private let neededFor: [BotType: Minerals]
  let maxNeeded: BotCounts

  private init(_ neededFor: [BotType: Minerals]) {
    self.neededFor = neededFor
    self.maxNeeded = Counts(
      ore: neededFor.map { $0.value[.Ore] }.max()!,
      clay: neededFor[.Obsidian]![.Clay],
      obsidian: neededFor[.Geode]![.Obsidian],
      geode: Int.max)
  }

  func consider(botType: BotType, existingBots: BotCounts) -> Bool {
    return existingBots[botType] < maxNeeded[botType]
  }

  func canBuild(botType: BotType, available: Minerals) -> Minerals? {
    let availableUpdated = available - neededFor[botType]!
    if availableUpdated.valid {
      return availableUpdated
    }
    return nil
  }

  static func fromString(_ str: String.SubSequence) -> Blueprint {
    let n = str.split(separator: " ").compactMap { Int($0) }
    return Blueprint([
      .Ore: Minerals(ore: n[0]),
      .Clay: Minerals(ore: n[1]),
      .Obsidian: Minerals(ore: n[2], clay: n[3]),
      .Geode: Minerals(ore: n[4], clay: 0, obsidian: n[5]),
    ])
  }
}

struct State: Hashable {
  let timeLeft: Int
  let bots: BotCounts
  let minerals: Minerals

  func capped(maxNeeded: BotCounts) -> State {
    return State(
      timeLeft: timeLeft, bots: bots,
      minerals: Minerals(
        ore: min(minerals[.Ore], timeLeft * (maxNeeded[.Ore] - bots[.Ore])),
        clay: min(minerals[.Clay], timeLeft * (maxNeeded[.Clay] - bots[.Clay])),
        obsidian: min(minerals[.Obsidian], timeLeft * (maxNeeded[.Obsidian] - bots[.Obsidian])),
        geode: minerals[.Geode]
      ))
  }

  func build(blueprint: Blueprint, botType: BotType?) -> State? {
    var updatedMinerals: Minerals
    var updatedBots: BotCounts
    if botType == nil {
      updatedMinerals = minerals
      updatedBots = bots
    } else {
      if blueprint.consider(botType: botType!, existingBots: bots),
        let mineralsAfterBuilding = blueprint.canBuild(botType: botType!, available: minerals)
      {
        updatedMinerals = mineralsAfterBuilding
        updatedBots = bots + botType!
      } else {
        return nil
      }
    }
    updatedMinerals = updatedMinerals + bots
    return State(timeLeft: timeLeft - 1, bots: updatedBots, minerals: updatedMinerals)
  }
}

func getMaxGeode(blueprint: Blueprint, state: State, memo: inout [State: Int]) -> Int {
  if state.timeLeft == 0 {
    return state.minerals[.Geode]
  }
  // Simplify state, drop excess minerals
  let capped = state.capped(maxNeeded: blueprint.maxNeeded)
  if let result = memo[capped] {
    return result
  }

  // If building a geode bot is possible, always do this
  if let updatedState = state.build(blueprint: blueprint, botType: .Geode) {
    return getMaxGeode(blueprint: blueprint, state: updatedState, memo: &memo)
  }

  // Evaluate any remaining options
  let result = [BotType.Obsidian, BotType.Clay, BotType.Ore, nil].compactMap {
    if let updatedState = state.build(blueprint: blueprint, botType: $0) {
      return getMaxGeode(blueprint: blueprint, state: updatedState, memo: &memo)
    }
    return nil
  }.max()!

  memo[capped] = result
  return result
}

func getMaxGeode(blueprint: Blueprint, timeLeft: Int) -> Int {
  var memo = [State: Int]()
  return getMaxGeode(
    blueprint: blueprint,
    state: State(timeLeft: timeLeft, bots: BotCounts(ore: 1), minerals: Minerals()),
    memo: &memo)
}

func partOne(blueprints: [Blueprint]) -> Int {
  var score = 0
  for (index, blueprint) in blueprints.enumerated() {
    let max = getMaxGeode(blueprint: blueprint, timeLeft: 24)
    let qualityLevel = (index + 1) * max
    score += qualityLevel
    print(
      "Blueprint \(index + 1), max. #geodes = \(max), score = \(qualityLevel), total = \(score)")
  }
  return score
}

func partTwo(blueprints: [Blueprint]) -> Int {
  var score = 1
  for (index, blueprint) in blueprints.prefix(3).enumerated() {
    let max = getMaxGeode(blueprint: blueprint, timeLeft: 32)
    score *= max
    print("Blueprint \(index + 1), max. #geodes = \(max), score = \(max), total = \(score)")
  }
  return score
}

// -----------------------------------------------------------------------------

let blueprints = loadInput(exampleFilename: "example19.txt").split(separator: "\n").map {
  Blueprint.fromString($0)
}
print("Part 1:", partOne(blueprints: blueprints))
print("Part 2:", partTwo(blueprints: blueprints))
