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

protocol XYPair: Hashable, CustomStringConvertible {
  var x: Int { get }
  var y: Int { get }
}

extension XYPair {
  var description: String {
    "(\(x),\(y))"
  }
}

struct Vector: XYPair {
  let x: Int
  let y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  static func * (scalar: Int, rhs: Vector) -> Vector {
    return Vector(scalar * rhs.x, scalar * rhs.y)
  }
}

struct Pos: XYPair {
  let x: Int
  let y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  static func + (lhs: Pos, rhs: Vector) -> Pos {
    return Pos(lhs.x + rhs.x, lhs.y + rhs.y)
  }

  static func + (lhs: Vector, rhs: Pos) -> Pos {
    return Pos(lhs.x + rhs.x, lhs.y + rhs.y)
  }

  static func - (lhs: Pos, rhs: Vector) -> Pos {
    return Pos(lhs.x - rhs.x, lhs.y - rhs.y)
  }

  static func - (lhs: Pos, rhs: Pos) -> Vector {
    return Vector(lhs.x - rhs.x, lhs.y - rhs.y)
  }

  func isValid(maxXY: Int) -> Bool {
    return x >= 0 && y >= 0 && x < maxXY && y < maxXY
  }
}

func manhattanDistance(_ a: Pos, _ b: Pos) -> Int {
  return abs(a.x - b.x) + abs(a.y - b.y)
}

struct Sensor {
  let pos: Pos
  let range: Int

  func outOfRange(_ other: Pos) -> Bool {
    return manhattanDistance(pos, other) > range
  }
}

typealias Beacon = Pos

func parseInput(data: String) -> ([Sensor], [Beacon]) {
  let lines = data.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ":", with: "")
    .split(separator: "\n")
  let positions: [(Pos, Pos)] = lines.map {
    let values = $0.split(separator: " ").filter { $0.contains("=") }.map { Int($0.dropFirst(2))! }
    return (Pos(values[0], values[1]), Pos(values[2], values[3]))
  }
  return (
    positions.map { Sensor(pos: $0.0, range: manhattanDistance($0.0, $0.1)) },
    positions.map { $0.1 }
  )
}

// Part 1

func countExcludedPositions(sensors: [Sensor], beacons: [Beacon], targetRow: Int) -> Int {
  let rangesTemp = sensors.compactMap {
    let netRange = $0.range - abs($0.pos.y - targetRow)
    return netRange > 0 ? ($0.pos.x - netRange, $0.pos.x + netRange) : nil
  }
  let excludedRanges = rangesTemp.sorted(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) })

  var excludedPositions = 0
  var currentRange = excludedRanges.first!
  for excludedRange in excludedRanges.dropFirst() {
    if excludedRange.0 > currentRange.1 {
      excludedPositions += currentRange.1 - currentRange.0 + 1
      currentRange = excludedRange
    } else {
      currentRange.1 = max(excludedRange.1, currentRange.1)
    }
  }
  excludedPositions += currentRange.1 - currentRange.0 + 1

  let uniqueBeacons = Set(beacons.compactMap { $0.y == targetRow ? $0.x : nil }).count
  return excludedPositions - uniqueBeacons
}

// Part 2

struct LineSegment {
  let start: Pos
  let dir: Vector
  let len: Int
}

// Intersection of two orthogonal, diagonal line segments.
func intersection(a: LineSegment, b: LineSegment) -> Pos? {
  if b.dir.x == a.dir.y && b.dir.y == -a.dir.x {
    return intersection(a: b, b: a)
  }

  let delta = b.start - a.start
  //         delta.x = t * a.dir.x - u * b.dir.x
  //     and delta.y = t * a.dir.y - u * b.dir.y
  // =>      delta.x / b.dir.x = t * a.dir.x / b.dir.x - u
  //     and delta.y / b.dir.y = t * a.dir.y / b.dir.y - u
  // =>  delta.x / b.dir.x - delta.y / b.dir.y = t * (a.dir.x / b.dir.x - a.dir.y / b.dir.y)
  let t = (delta.x / b.dir.x - delta.y / b.dir.y) / (a.dir.x / b.dir.x - a.dir.y / b.dir.y)
  let u = -(delta.x / a.dir.x - delta.y / a.dir.y) / (b.dir.x / a.dir.x - b.dir.y / a.dir.y)

  // Confirm that there is any intersection at all
  if t >= 0 && t <= a.len && u >= 0 && u <= b.len {
    return a.start + t * a.dir
  }
  return nil
}

// Find intersections of two diamond shapes (=contours of sensor range outlines).
// Do not report common points between parallel sides, those are not of interest here.
// Overlaps at corners will be reported twice.
func diamondIntersection(center1: Pos, radius1: Int, center2: Pos, radius2: Int) -> [Pos] {
  let centerDist = manhattanDistance(center1, center2)
  if radius1 + radius2 < centerDist || abs(radius2 - radius1) > centerDist
    || (radius1 + radius2 + centerDist) % 2 == 1
  {
    return []
  }

  // Split diamonds into line segments.
  let corners = [Vector(+1, 0), Vector(0, +1), Vector(-1, 0), Vector(0, -1)]
  let dirs = (0..<4).map { corners[($0 + 1) % 4] - corners[$0] }
  let segments1 = (0..<4).map {
    LineSegment(start: center1 + radius1 * corners[$0], dir: dirs[$0], len: radius1)
  }
  let segments2 = (0..<4).map {
    LineSegment(start: center2 + radius2 * corners[$0], dir: dirs[$0], len: radius2)
  }

  // Find intersections through a pairwise comparison of orthogonal sides between diamonds.
  let pairings = [(0, 1), (1, 2), (2, 3), (3, 0), (0, 3), (1, 0), (2, 1), (3, 2)]
  return pairings.compactMap { index1, index2 in
    return intersection(a: segments1[index1], b: segments2[index2])
  }
}

func locateMissingBeacon(sensors: [Sensor], maxPos: Int) -> Pos? {
  // If there's only one uncovered position, it needs to be just outside a sensor's range,
  // for multiple sensors (limit to two sensors here)
  var candidates = Set<Pos>()
  for s1 in 0..<sensors.count {
    for s2 in (s1 + 1)..<sensors.count {
      diamondIntersection(
        center1: sensors[s1].pos, radius1: sensors[s1].range + 1, center2: sensors[s2].pos,
        radius2: sensors[s2].range + 1
      ).filter { $0.isValid(maxXY: maxPos) }.forEach { candidates.insert($0) }
    }
  }
  return candidates.first { candidate in
    sensors.allSatisfy { sensor in sensor.outOfRange(candidate) }
  }
}

func tuningFrequency(pos: Pos) -> Int {
  return 4_000_000 * pos.x + pos.y
}

// -----------------------------------------------------------------------------

let (sensors, beacons) = parseInput(data: loadInput(exampleFilename: "example15.txt"))
let maxPos = sensors.count > 20 ? 4_000_000 : 20
print("Part 1:", countExcludedPositions(sensors: sensors, beacons: beacons, targetRow: maxPos / 2))
print("Part 2:", tuningFrequency(pos: locateMissingBeacon(sensors: sensors, maxPos: maxPos)!))
