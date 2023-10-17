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

class Cave {
  let distances: [[Int]]
  let flowRates: [Int]
  var cache = [[Int]: Int]()

  init(data: String) {
    var nameToIndex = [String: Int]()
    var names = [String]()
    var flowRates = [Int]()
    var allConnectionsByName = [[String]]()
    let template = try! Regex(
      "Valve ([A-Z]{2}) has flow rate=([0-9]+); tunnels? leads? to valves? ([A-Z]{2}(?:, [A-Z]{2})*)"
    )

    // Sort input so that valve AA is always at index 0
    for (index, line) in data.split(separator: "\n").sorted().enumerated() {
      let match = line.firstMatch(of: template)!
      let name = String(match[1].substring!)
      nameToIndex[name] = index
      names.append(name)
      flowRates.append(Int(match[2].substring!)!)
      allConnectionsByName.append(match[3].substring!.split(separator: ", ").map { String($0) })
    }

    let allRawConnections = allConnectionsByName.map { $0.compactMap { nameToIndex[$0] } }
    let allDistances = Cave.runFloydWarshall(allRawConnections)
    let keep = (0..<flowRates.count).map { $0 == 0 || flowRates[$0] > 0 }

    distances = allDistances.enumerated().compactMap {
      index, directConnections in
      return keep[index]
        ? directConnections.enumerated().compactMap { distanceIndex, distance in
          keep[distanceIndex] ? distance : nil
        } : nil
    }
    self.flowRates = flowRates.enumerated().compactMap { index, flow in keep[index] ? flow : nil }
  }

  public func findMaxPressure(x0: Int, pool: [Int], timeLeft: Int) -> Int {
    let lookup = [x0, timeLeft] + pool
    if let cached = cache[lookup] {
      return cached
    }
    var best = 0
    let distancesFromHere = distances[x0]
    for next in pool {
      let timeLeftUpdated = timeLeft - (distancesFromHere[next] + 1)
      if timeLeftUpdated <= 0 {
        continue
      }
      best = max(
        best,
        findMaxPressure(x0: next, pool: pool.filter { $0 != next }, timeLeft: timeLeftUpdated)
          + flowRates[next] * timeLeftUpdated)
    }
    cache[lookup] = best
    return best
  }

  public func partOne() -> Int {
    return findMaxPressure(x0: 0, pool: [Int](1..<cave.distances.count), timeLeft: 30)
  }

  public func partTwo() -> Int {
    var best = 0
    for (part1, part2) in Cave.partitionings(n: cave.distances.count - 1) {
      best = max(best, 
        cave.findMaxPressure(x0: 0, pool: part1, timeLeft: 26)
        + cave.findMaxPressure(x0: 0, pool: part2, timeLeft: 26)
      )
    }
    return best
  }

  // Partition the set [1,2,3,...,n] into two sets.
  // To reduce redundant computations, element 1 always goes to the first output set.
  static func partitionings(n: Int) -> AnyIterator<([Int], [Int])> {
    var p = 0
    let max = 1 << (n-1)
    return AnyIterator<([Int], [Int])> {      
      if p < max {
        var part1 = [1]
        var part2 = [Int]()
        var bits = p
        var k = 2
        while (k <= n)
        {
          if (bits & 1) == 0 {
            part1.append(k)
          }
          else
          {
            part2.append(k)
          }
          k += 1
          bits >>= 1
        }
        p += 1
        return (part1, part2)
      }
      return nil
    }
  }

  private static func runFloydWarshall(_ allRawConnections: [[Int]]) -> [[Int]] {
    let n = allRawConnections.count
    var d = Array(repeating: Array(repeating: 999, count: n), count: n)
    for (from, rawConnections) in allRawConnections.enumerated() {
      for to in rawConnections {
        d[from][to] = 1
        d[to][from] = 1
      }
      d[from][from] = 1
    }
    for k in 0..<n {
      for i in 0..<n {
        for j in 0..<n {
          d[i][j] = min(d[i][j], d[i][k] + d[k][j])
        }
      }
    }
    return d
  }
}

// -----------------------------------------------------------------------------

let cave = Cave(data: loadInput(exampleFilename: "example16.txt"))
print("Part 1:", cave.partOne())
print("Part 2:", cave.partTwo())
