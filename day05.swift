
import Foundation

struct Stack<T> {
  private var data = [T]()

  public mutating func push(_ val: T) {
    data.append(val)
  }

  public mutating func pop() -> T {
    let result = top()!
    data.removeLast()
    return result
  }

  public func top() -> T? {
    return data.last
  }
}

func buildStacks(_ stackInput: [Substring.SubSequence]) -> [Stack<Character>] {
  // Process input in reversed order (starting at bottom of stacks)
  let stackData = stackInput.reversed().dropFirst(1)
  // Each of the n stacks in the input is 3 characters wide, plus (n-1) spaces in between
  let n = (stackData.first!.count + 1) / 4
  // Parse line by line, build all stacks simultaneously
  var stacks = Array(repeating: Stack<Character>(), count: n)
  for line in stackData {
    for pos in 0..<n {
      let crate = line[line.index(line.startIndex, offsetBy: 4 * pos + 1)]
      if crate != " " { stacks[pos].push(crate) }
    }
  }
  return stacks
}

typealias Step = (Int, Int, Int)

func buildSteps(_ stepInput: [Substring.SubSequence]) -> [Step] {
  // Each step is a line like "move 1 from 2 to 1".
  // Pick numeric items from the line, adjust offsets to start from 0 instead of 1.
  return stepInput.map { $0.split(separator: " ").compactMap { Int($0) } }.map { numbers in
    (numbers[0], numbers[1] - 1, numbers[2] - 1)
  }
}

func combineStackTops(_ stacks: [Stack<Character>]) -> String {
  return String(stacks.map { $0.top() ?? Character("_") })
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example05.txt"
let blocks = try! String(contentsOfFile: filename)
  .split(separator: "\n\n").map { $0.split(separator: "\n") }
let steps = buildSteps(blocks[1])

// Part 1: move one block at a time (this reverses the order if several blocks are moved at once)
var stacks = buildStacks(blocks[0])
for (n, from, to) in steps {
  for _ in 1...n { stacks[to].push(stacks[from].pop()) }
}
print("Part 1: ", combineStackTops(stacks))

// Part 2: move several blocks at once (to maintain their order, reverse them twice)
stacks = buildStacks(blocks[0])
for (n, from, to) in steps {
  var temp = Stack<Character>()
  for _ in 1...n { temp.push(stacks[from].pop()) }
  for _ in 1...n { stacks[to].push(temp.pop()) }
}
print("Part 2: ", combineStackTops(stacks))
