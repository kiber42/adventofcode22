import Foundation

typealias Assignment = (ClosedRange<Int>, ClosedRange<Int>)

func getAssignments(args: [String]) -> [Assignment] {
  let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example04.txt"
  let input = try! String(contentsOfFile: filename).split(separator: "\n")
  return input.map {
    let groups = $0.split(separator: ",")
    assert(groups.count == 2)
    return (parseRange(groups[0]), parseRange(groups[1]))
  }
}

// Parse text "123-456" as closed range [123,456]
func parseRange(_ s: String.SubSequence) -> ClosedRange<Int> {
  let numbers = s.split(separator: "-").compactMap { Int($0) }
  assert(numbers.count == 2)
  return numbers[0]...numbers[1]
}

let assignments = getAssignments(args: CommandLine.arguments)
let fullOverlap = assignments.filter { a, b in a.contains(b) || b.contains(a) }
let partialOverlap = assignments.filter { a, b in a.overlaps(b) }

print("Part 1:", fullOverlap.count)
print("Part 2:", partialOverlap.count)
