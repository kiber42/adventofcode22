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

struct Packet: Comparable, CustomStringConvertible {
  // Packet either holds a value or data, never both.
  // An empty packet ([]) has neither a value nor any data.
  let value: Int?
  let data: [Packet]

  init(_ v: Int) {
    value = v
    data = [Packet]()
  }

  init(_ sub: [Packet]) {
    value = nil
    data = sub
  }

  var description: String {
    value == nil ? "[\(data.map{ $0.description }.joined(separator:","))]" : String(value!)
  }

  private static func parseChunk(_ str: inout String.SubSequence) -> Packet {
    var data = [Packet]()
    var current = ""
    while let ch = str.popFirst() {
      switch ch {
      case "[":
        assert(current.isEmpty)
        data.append(parseChunk(&str))
      case ",":
        if !current.isEmpty {
          data.append(Packet(Int(current)!))
          current = ""
        }
      case "]":
        if !current.isEmpty {
          data.append(Packet(Int(current)!))
        }
        return Packet(data)
      default:
        current.append(ch)
      }
    }
    assert(false)
  }

  static func parse(_ str: String.SubSequence) -> Packet {
    assert(str.first! == "[")
    var myStr = str.dropFirst()
    return parseChunk(&myStr)
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    if let valueL = lhs.value {
      // Number vs. Number
      if let valueR = rhs.value {
        return valueL < valueR
      }
      // Number vs. List
      return Packet([Packet(valueL)]) < rhs
    }
    // List vs. Number
    if let valueR = rhs.value {
      return lhs < Packet([Packet(valueR)])
    }
    // List vs. List
    return lhs.data.lexicographicallyPrecedes(rhs.data)
  }
}

func comparePacketPairs(_ packets: [Packet]) -> Int {
  (0..<packets.count / 2).compactMap { index in
    packets[index * 2] < packets[index * 2 + 1] ? index + 1 : nil
  }.reduce(0, +)
}

func findDividers(_ packets: [Packet], dividers: [Packet]) -> Int {
  let packetsAndDividers = (packets + dividers).sorted()
  return dividers.map{ (packetsAndDividers.firstIndex(of: $0)! + 1) }.reduce(1, *)
}

// -----------------------------------------------------------------------------

let packets = loadInput(exampleFilename: "example13.txt").split(
  separator: "\n", omittingEmptySubsequences: true
).map { Packet.parse($0) }
print("Part 1:", comparePacketPairs(packets))
print("Part 2:", findDividers(packets, dividers: [Packet(2), Packet(6)]))
