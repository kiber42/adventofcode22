import Foundation

func itemScore(_ item : Character) -> Int {
    let offset_a = Int(Character("a").asciiValue!) - 1
    let offset_A = Int(Character("A").asciiValue!) - 27
    return Int(item.asciiValue!) - (item >= Character("a") ? offset_a : offset_A)
}

func rucksackScore(rucksack: String.SubSequence) -> Int {
    let middle = rucksack.count / 2
    let (comp1, comp2) = (rucksack.prefix(middle).sorted(), rucksack.suffix(middle).sorted())
    let commonItem = Set(comp1).intersection(Set(comp2)).first!
    return itemScore(commonItem)
}

func groupScore(_ rucksacks: [String.SubSequence], _ groupIndex: Int) -> Int {
    let r1 = rucksacks[3 * groupIndex]
    let r2 = rucksacks[3 * groupIndex + 1]
    let r3 = rucksacks[3 * groupIndex + 2]
    let commonItem = Set(r1).intersection(r2).intersection(r3).first!
    return itemScore(commonItem)
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example03.txt"
do
{
    let rucksacks = try String(contentsOfFile: filename).split(separator: "\n")
    print("Part 1: \(rucksacks.map(rucksackScore).reduce(0, +))")
    print("Part 2: \((0..<rucksacks.count / 3).map({groupScore(rucksacks, $0)}).reduce(0, +))")
} catch {
    print("Could not load input from '\(filename)'.")
}
