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

class CPU {
  private struct State {
    var X = 1
    var cycle = 0
    var ip = 0

    mutating func advance() -> (Int?, String) {
      let output = abs(X - (cycle % 40)) <= 1 ? "#" : "."
      cycle += 1
      let score = (cycle - 20) % 40 == 0 ? X * cycle : nil
      return (score, output)
    }
  }

  private var state = State()
  private let commands: [String.SubSequence]

  init(data: String) {
    commands = data.split(separator: "\n")
  }

  func runProgram() -> Int {
    state = State()
    return commands.map { processCommand($0).0 }.reduce(0, +)
  }

  func renderOutput() {
    state = State()
    let oneLine = commands.map { processCommand($0).1 }.joined(separator: "")
    print(splitLine(oneLine, length: 40).joined(separator: "\n"))
  }

  private func processCommand(_ cmd: String.SubSequence) -> (Int, String) {
    var (score, output) = state.advance()
    if cmd.starts(with: "addx") {
      let adv = state.advance()
      score = score ?? adv.0
      output += adv.1
      state.X += Int(cmd.split(separator: " ").last!)!
    }
    return (score ?? 0, output)
  }

  private func splitLine(_ s: String, length: Int) -> [String.SubSequence] {
    var lines = [s.prefix(length)]
    var sub = s.dropFirst(length)
    while !sub.isEmpty {
      lines.append(sub.prefix(length))
      sub = sub.dropFirst(length)
    }
    return lines
  }
}

// -----------------------------------------------------------------------------

let cpu = CPU(data: loadInput(exampleFilename: "example10.txt"))
print("Part 1:", cpu.runProgram())
print("Part 2:")
cpu.renderOutput()
