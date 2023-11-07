import Foundation

func priority(_ item: Character) -> Int {
  Int((item.isUppercase ? 27 : 1) + Character(item.lowercased()).asciiValue! - 97)
}

func commonItem(_ packingLists: [String.SubSequence]) -> Character {
  var commonItem = Set(packingLists[0])
  packingLists.dropFirst().forEach { commonItem.formIntersection($0) }
  return commonItem.first!
}

func rucksackScore(rucksack: String.SubSequence) -> Int {
  let middle = rucksack.count / 2
  return priority(commonItem([rucksack.prefix(middle), rucksack.suffix(middle)]))
}

func groupScore(_ rucksacks: [String.SubSequence], _ groupIndex: Int) -> Int {
  let packingLists = (0..<3).map { rucksacks[3 * groupIndex + $0] }
  return priority(commonItem(packingLists))
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example03.txt"
do {
  let rucksacks = try String(contentsOfFile: filename).split(separator: "\n")
  print("Part 1:", rucksacks.map(rucksackScore).reduce(0, +))
  print("Part 2:", (0..<rucksacks.count / 3).map { groupScore(rucksacks, $0) }.reduce(0, +))
} catch {
  print("Could not load input from '\(filename)'.")
}
