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

typealias Number = Int

enum Operation: Character {
  case add = "+"
  case sub = "-"
  case mul = "*"
  case div = "/"

  func apply(_ a: Number, _ b: Number) -> Number {
    switch self {
    case .add: return a + b
    case .sub: return a - b
    case .mul: return a * b
    case .div: return a / b
    }
  }

  // Solve  left op x = result  for x
  func solve(left: Number, _ result: Number) -> Number {
    switch self {
    case .add: return result - left
    case .sub: return left - result
    case .mul: return result / left
    case .div: return left / result
    }
  }

  // Solve  x op right = result  for x
  func solve(right: Number, _ result: Number) -> Number {
    switch self {
    case .add: return result - right
    case .sub: return result + right
    case .mul: return result / right
    case .div: return result * right
    }
  }
}

enum Monkey {
  case Yell(String, Number)
  case Math(String, Int, Operation, Int)
  case Placeholder

  var name: String {
    switch self {
    case .Yell(let name, _): return name
    case .Math(let name, _, _, _): return name
    case .Placeholder: return ""
    }
  }
}

class Parser {
  private(set) var monkeys = [Monkey]()
  private(set) var indices = [String: Int]()

  init(_ input: String) {
    input.split(separator: "\n").forEach { processLine($0) }
  }

  private func processLine(_ data: String.SubSequence) {
    let tokens = data.split(separator: " ")
    let name = String(tokens.first!.dropLast())
    var monkey: Monkey

    if tokens.count == 2 {
      monkey = .Yell(name, Number(Int(tokens[1])!))
    } else {
      let source1 = findOrAddPlaceholder(name: String(tokens[1]))
      let source2 = findOrAddPlaceholder(name: String(tokens[3]))
      let op = Operation(rawValue: tokens[2].first!)!
      monkey = .Math(name, source1, op, source2)
    }

    if let index = indices[name] {
      monkeys[index] = monkey
    } else {
      indices[name] = monkeys.count
      monkeys.append(monkey)
    }
  }

  private func findOrAddPlaceholder(name: String) -> Int {
    if let index = indices[name] {
      return index
    }
    let index = monkeys.count
    indices[name] = index
    monkeys.append(.Placeholder)
    return index
  }
}

func getNumbersAndHumnDependency(monkeys: [Monkey], indexHumn: Int) -> ([Number], Set<Int>) {
  let n = monkeys.count
  var numbers = Array(repeating: Number(0), count: n)
  var dependent = Array(repeating: false, count: n)

  var recurseAndCache: ((Int) -> Void)!
  recurseAndCache = { index in
    if numbers[index] > 0 {
      return
    }
    switch monkeys[index] {
    case .Yell(_, let number):
      numbers[index] = number
      dependent[index] = index == indexHumn
    case .Math(_, let source1, let op, let source2):
      recurseAndCache(source1)
      recurseAndCache(source2)
      numbers[index] = op.apply(numbers[source1], numbers[source2])
      dependent[index] = dependent[source1] || dependent[source2]
    case .Placeholder: abort()
    }
  }

  for index in 0..<n {
    recurseAndCache(index)
  }

  return (
    numbers,
    Set(
      dependent.enumerated().compactMap { (index, dependent) in
        return dependent ? index : nil
      })
  )
}

class Monkeys {
  private let monkeys: [Monkey]
  private let indices: [String: Int]
  private let numbers: [Number]
  private let dependentOnHumn: Set<Int>

  init(_ input: String) {
    let parser = Parser(input)
    monkeys = parser.monkeys
    indices = parser.indices
    (numbers, dependentOnHumn) = getNumbersAndHumnDependency(
      monkeys: monkeys, indexHumn: indices["humn"]!)
  }

  func number(of: String) -> Number {
    return numbers[indices[of]!]
  }

  private func requireMathMonkey(_ index: Int) -> (Int, Operation, Int)? {
    if case .Math(_, let source1, let op, let source2) = monkeys[index] {
      return (source1, op, source2)
    }
    return nil
  }

  private func findTargetValueAndMonkey() -> (Number, Int) {
    let (source1, _, source2) = requireMathMonkey(indices["root"]!)!
    return dependentOnHumn.contains(source1)
      ? (numbers[source2], source1)
      : (numbers[source1], source2)
  }

  private func requiredInput(targetValue: Number, at: Int) -> (Number, Int)? {
    if let (source1, op, source2) = requireMathMonkey(at) {
      return dependentOnHumn.contains(source1)
        ? (op.solve(right: numbers[source2], targetValue), source1)
        : (op.solve(left: numbers[source1], targetValue), source2)
    }
    return nil
  }

  func requiredInput() -> Number {
    var (targetValue, monkeyIndex) = findTargetValueAndMonkey()
    while let updated = requiredInput(targetValue: targetValue, at: monkeyIndex) {
      print("Monkey \(monkeys[monkeyIndex].name) shall yell \(targetValue)")
      (targetValue, monkeyIndex) = updated
    }
    return targetValue
  }
}

// -----------------------------------------------------------------------------

let monkeys = Monkeys(loadInput(exampleFilename: "example21.txt"))
print("Part 1: \(monkeys.number(of: "root"))")
print("Part 2: \(monkeys.requiredInput())")
