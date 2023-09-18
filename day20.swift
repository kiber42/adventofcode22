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

class Node {
  let value: Int
  var next: Node?
  var previous: Node?

  init(_ value: Int, next: Node?, previous: Node?) {
    self.value = value
    self.next = next
    self.previous = previous
  }
}

struct CircularList: CustomStringConvertible {
  let pivot: Node
  let len: Int
  var multiplier: Int

  init(input: String, multiplier: Int = 1) {
    let values = input.split(separator: "\n").map { Int($0)! }

    pivot = Node(values.first!, next: nil, previous: nil)
    len = values.count
    self.multiplier = multiplier

    var node = pivot
    for value in values.dropFirst() {
      node = Node(value, next: nil, previous: node)
    }
    pivot.previous = node

    node.next = pivot
    while node !== pivot {
      let last = node
      node = node.previous!
      node.next = last
    }
  }

  func getNodes() -> [Node] {
    var result = [Node]()
    var node = pivot
    repeat {
      result.append(node)
      node = node.next!
    } while node !== pivot
    return result
  }

  private func next(_ node: Node, dist: Int, mod: Int) -> Node {
    let d = (dist % mod + mod) % mod
    var result = node
    if d > len / 2 {
      for _ in 0..<d {
        result = result.next!
      }
    } else if d > 0 {
      for _ in 0..<(len - d) {
        result = result.previous!
      }
    }
    return result
  }

  private func move(node: Node, by: Int) {
    let before = node.previous!
    let insertAfter = next(node, dist: by * multiplier, mod: len - 1)
    if node === insertAfter {
      return
    }

    before.next = node.next
    node.next!.previous = before
    node.next = insertAfter.next
    insertAfter.next = node
    node.previous = insertAfter
    node.next!.previous = node
  }

  func process(order: [Node]) {
    for node in order {
      move(node: node, by: node.value)
    }
  }

  func score() -> Int {
    var node = pivot
    while node.value != 0 {
      node = node.next!
    }
    let node1 = next(node, dist: 1000, mod: len)
    let node2 = next(node1, dist: 1000, mod: len)
    let node3 = next(node2, dist: 1000, mod: len)
    return (node1.value + node2.value + node3.value) * multiplier
  }

  var description: String {
    var numbers = [String]()
    var node = pivot
    let n = min(10, len)
    for _ in 0..<n {
      numbers.append(String(node.value * multiplier))
      node = node.next!
    }
    return numbers.joined(separator: ", ")
  }
}

func part1() -> Int {
  let list = CircularList(input: loadInput(exampleFilename: "example20.txt"))
  let allNodes = list.getNodes()
  list.process(order: allNodes)
  return list.score()
}

func part2() -> Int {
  let list = CircularList(
    input: loadInput(exampleFilename: "example20.txt"), multiplier: 811_589_153)
  let allNodes = list.getNodes()
  for _ in 1...10 {
    list.process(order: allNodes)
    print(list)
  }
  return list.score()
}

print("Part 1:", part1())
print("Part 2:", part2())
