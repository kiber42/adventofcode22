import Foundation

// -----------------------------------------------------------------------------

func loadInput() -> String {
  let filename = CommandLine.arguments.count > 1 ?
    CommandLine.arguments[1] : exampleFilename
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

  static func + (lhs: Vector, rhs: Vector) -> Vector {
    return Vector(lhs.x + rhs.x, lhs.y + rhs.y)
  }

  static func - (lhs: Vector, rhs: Vector) -> Vector {
    return Vector(lhs.x - rhs.x, lhs.y - rhs.y)
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

  @discardableResult static func += (lhs: inout Pos, rhs: Vector) -> Pos {
    lhs = lhs + rhs
    return lhs
  }

  func isValid(maxXY: Int) -> Bool {
    return x >= 0 && y >= 0 && x < maxXY && y < maxXY
  }

  func isValid<T: XYPair>(maxXY: T) -> Bool {
    return x >= 0 && y >= 0 && x < maxXY.x && y < maxXY.y
  }

  // Return a position with each coordinate restricted to the
  // interval 0..<maxXY, wrapping around if needed.
  func wrapped(maxXY: Int) -> Pos {
    return Pos(
      ((x % maxXY) + maxXY) % maxXY,
      ((y % maxXY) + maxXY) % maxXY)
  }
}

enum Direction: Int, CaseIterable {
  case right = 0
  case down = 1
  case left = 2
  case up = 3

  func turnLeft() -> Direction {
    return Direction(rawValue: (rawValue + 3) % 4)!
  }

  func turnRight() -> Direction {
    return Direction(rawValue: (rawValue + 1) % 4)!
  }

  func reverse() -> Direction {
    return Direction(rawValue: (rawValue + 2) % 4)!
  }

  func toVector() -> Vector {
    switch self {
    case .right: return Vector(1, 0)
    case .down: return Vector(0, 1)
    case .left: return Vector(-1, 0)
    case .up: return Vector(0, -1)
    }
  }
}

enum Orientation: Int {
  case initial = 0
  case rotLeft = 1
  case rot180 = 2
  case rotRight = 3

  static func * (_ lhs: Orientation, _ rhs: Orientation) -> Orientation {
    return Orientation(rawValue: (lhs.rawValue + rhs.rawValue) % 4)!
  }

  static func / (_ lhs: Orientation, _ rhs: Orientation) -> Orientation {
    return Orientation(rawValue: (lhs.rawValue - rhs.rawValue + 4) % 4)!
  }

  // Actively change position and direction by applying a rotation corresponding
  // to this orientation
  func apply(pos: Pos, direction: Direction, maxXY: Int) -> (Pos, Direction)
  {
    let inverted = .initial / self
    return inverted.applyPassive(pos: pos, direction: direction, maxXY: maxXY)
  }

  // Return position/direction as they would appear from an updated coordinate
  // system (passive transformation).
  func applyPassive(pos: Pos, maxXY: Int) -> Pos
  {
    let n = maxXY - 1
    var updated : Pos
    switch self {
    case .initial: updated = pos
    case .rotLeft: updated = Pos(n - pos.y, pos.x)
    case .rot180: updated = Pos(n - pos.x, n - pos.y)
    case .rotRight: updated = Pos(pos.y, n - pos.x)
    }
    return updated.wrapped(maxXY: maxXY)
  }

  func applyPassive(direction: Direction) -> Direction
  {
    switch self {
    case .initial: return direction
    case .rotLeft: return direction.turnRight()
    case .rot180: return direction.reverse()
    case .rotRight: return direction.turnLeft()
    }
  }

  func applyPassive(pos: Pos, direction: Direction, maxXY: Int) -> (Pos, Direction)
  {
    return (applyPassive(pos: pos, maxXY: maxXY), applyPassive(direction: direction))
  }
}

enum CubeSide {
  case top
  case left
  case front
  case right
  case back
  case bottom

  /*
    Orientations are always updated with respect to this reference unfolding
        /---/
        | Bk|
    /---+---+---/
    | L | T | R |
    /---+---+---/
        | F |
        +---+
        | Bt|
        /---/

    When moving across one of the connected edges in this reference cube, the
    orientation does not change (e.g. Front and Top have the same orientation).
    When moving across an unconnected edge (e.g. from Right to Bottom), the
    orientation may change (from Right to Bottom, it is rotated by 180 degree;
    from Front to Right, there is a rotation of 90 degree; from Bottom to Back
    it would not change).

    An Orientation of "rotated right" means that the target tile needs to be
    rotated clockwise to determine the side on which one enters.  For example,
    when moving from Front to Right, i.e. moving "right" in the reference
    unfolding, one exits the Front tile to the right but enters the Right tile
    from below.  This is equivalent to rotating the Right tile clockwise by 90
    degree and pretending it is directly adjacent to the Front tile.
  */

  func neighbour(direction: Direction) -> (CubeSide, Orientation) {
    switch direction {
    case .left:  return left()
    case .right: return right()
    case .up:    return up()
    case .down:  return down()
    }
  }

  /*
    Matters become slightly more complicated when starting from a tile that is
    not in its default orientation: the meaning of left/right/up/down changes,
    and the neighbour's orientation is the result of the initial orientation of
    the starting tile and the relative orientation between the tiles.
  */
  func neighbour(direction: Direction, startingOrientation: Orientation) -> (CubeSide, Orientation) {
    let relativeDir = startingOrientation.applyPassive(direction: direction)
    let (newSide, relativeOrientation) = neighbour(direction: relativeDir)
    let newOrientation = relativeOrientation * startingOrientation
    return (newSide, newOrientation)
  }

  func left() -> (CubeSide, Orientation) {
    switch self {
      case .top: return (.left, .initial)
      case .left: return (.bottom, .rot180)
      case .front: return (.left, .rotLeft)
      case .right: return (.top, .initial)
      case .back: return (.left, .rotRight)
      case .bottom: return (.left, .rot180)
    }
  }

  func right() -> (CubeSide, Orientation) {
    switch self {
      case .top: return (.right, .initial)
      case .left: return (.top, .initial)
      case .front: return (.right, .rotRight)
      case .right: return (.bottom, .rot180)
      case .back: return (.right, .rotLeft)
      case .bottom: return (.right, .rot180)
    }
  }

  func up() -> (CubeSide, Orientation) {
    switch self {
      case .top: return (.back, .initial)
      case .left: return (.back, .rotLeft)
      case .front: return (.top, .initial)
      case .right: return (.back, .rotRight)
      case .back: return (.bottom, .initial)
      case .bottom: return (.front, .initial)
    }
  }

  func down() -> (CubeSide, Orientation) {
    switch self {
      case .top: return (.front, .initial)
      case .left: return (.front, .rotRight)
      case .front: return (.bottom, .initial)
      case .right: return (.front, .rotLeft)
      case .back: return (.top, .initial)
      case .bottom: return (.back, .initial)
    }
  }
}

struct State {
  let side: CubeSide
  let relativePos: Pos
  let dir: Direction
}

struct SectorMap: CustomStringConvertible {
  // Offset of top left cell of sector in original map
  private let topLeft: Vector
  // Orientation relative to reference grid orientation for this sector
  private let orientation: Orientation
  private let obstacles: [Pos]
  private let size: Int

  init(_ lines: [Substring.SubSequence], sectorPos: Pos, sectorSize: Int, orientation: Orientation) {
    let p0 = Pos(sectorPos.x * sectorSize, sectorPos.y * sectorSize)
    let p1 = p0 + Vector(sectorSize, sectorSize)

    self.topLeft = Vector(p0.x, p0.y)
    self.orientation = orientation
    self.obstacles = lines[p0.y..<p1.y].enumerated().flatMap({ (y, row) in
      row.enumerated().compactMap({ (x, ch) in
        ch == "#" && (p0.x..<p1.x).contains(x) ? Pos(x - p0.x, y) : nil
      }).map{orientation.applyPassive(pos: $0, maxXY: sectorSize)}
    })
    self.size = sectorSize
  }

  func hasObstacle(at: Pos) -> Bool {
    return obstacles.contains(at)
  }

  func convertToOriginalMap(localPos: Pos, localDir: Direction) -> (Pos, Direction) {
    let (pos, dir) = orientation.apply(pos: localPos, direction: localDir, maxXY: size)
    return (pos + topLeft, dir)
  }

  var description: String {
    "\(obstacles)"
  }
}

struct Cube {
  let sides: [CubeSide: SectorMap]
  let sectorSize: Int

  init(_ input: String.SubSequence) {
    let lines = input.split(separator: "\n")

    // Automatically pick size for example or full input
    let sectorSize = lines.count < 100 ? 4 : 50

    // Find non-empty blocks in input and lay them out on reference cube
    let validPositions = Cube.locateSectors(lines: lines, sectorSize: sectorSize)
    let arrangement = Cube.findArrangement(validPositions: validPositions, sectorSize: sectorSize)

    self.sides = arrangement.mapValues({ offset, orientation in
      return SectorMap(lines, sectorPos: offset, sectorSize: sectorSize, orientation: orientation)
    })
    self.sectorSize = sectorSize
  }

  private static func locateSectors(lines: [Substring.SubSequence], sectorSize: Int) -> [Pos] {
    let numSectors = Pos(
      lines.map({ $0.count }).max()! / sectorSize,
      lines.count / sectorSize)
    return (0..<numSectors.y).flatMap { y in
      (0..<numSectors.x).compactMap { x in
        let topLeftChar = lines[y * sectorSize].dropFirst(x * sectorSize).first
        return topLeftChar != nil && topLeftChar! != " " ? Pos(x, y) : nil
      }
    }
  }

  private static func findArrangement(validPositions: [Pos], sectorSize: Int)
    -> [CubeSide: (Pos, Orientation)]
  {
    // Determine cube arrangement by following connected edges, create mapping
    // from position in input to cube sides based on reference unfolding
    var arrangement = [CubeSide: (Pos, Orientation)]()
    // Define first detected tile as cube top
    let startIndex = Pos(validPositions.first!.x, 0)
    var indicesToCheck = [(startIndex, (CubeSide.top, Orientation.initial))]

    while !indicesToCheck.isEmpty {
      let (sidePos, (cubeSide, orientation)) = indicesToCheck.removeLast()
      // Check that our strategy does not map any part of the input to multiple,
      // different cube sides
      if let (existingPos, existingOrientation) = arrangement[cubeSide] {
        assert(existingPos == sidePos)
        assert(existingOrientation == orientation)
        continue
      }
      arrangement[cubeSide] = (sidePos, orientation)

      // Enqueue neighbours of newly mapped tile for processing
      for dir in Direction.allCases {
        let newIndex = sidePos + dir.toVector()
        if validPositions.contains(newIndex) {
          indicesToCheck.append((newIndex, cubeSide.neighbour(direction: dir, startingOrientation: orientation)))
        }
      }
    }
    // The mapping is easy to get wrong, therefore, instead of stopping after 6
    // sides were found, process all enqueued tiles and check that everything is
    // consistent.
    assert(arrangement.count == 6)
    return arrangement
  }

  private func stepOne(state: State) -> State? {
    let ahead = state.relativePos + state.dir.toVector()
    // Simple case, target cell is on same side
    if ahead.isValid(maxXY: sectorSize) {
      let start = self.sides[state.side]!
      return start.hasObstacle(at: ahead) ? nil :
        State(side: state.side, relativePos: ahead, dir: state.dir)
    }

    // Determine target cube side and deal with the relative orientation
    let (newSide, relativeOrientation) = state.side.neighbour(direction: state.dir)
    let (newPos, newDir) = relativeOrientation.applyPassive(pos: ahead, direction: state.dir, maxXY: sectorSize)
    let destination = self.sides[newSide]!
    return destination.hasObstacle(at: newPos) ? nil :
      State(side: newSide, relativePos: newPos, dir: newDir)
  }

  func apply(state: inout State, move: Move) {
    switch move {
    case .left:
      state = State(side: state.side, relativePos: state.relativePos, dir: state.dir.turnLeft())
    case .right:
      state = State(side: state.side, relativePos: state.relativePos, dir: state.dir.turnRight())
    case let .go(distance):
      for _ in 1...distance {
        if let updated = self.stepOne(state: state) {
          state = updated
        } else {
          break
        }
      }
    }
  }

  func convertToOriginalMap(state: State) -> (Pos, Direction) {
    let side = sides[state.side]!
    return side.convertToOriginalMap(localPos: state.relativePos, localDir: state.dir)
  }

  func score(state: State) -> Int {
    let (globalPos, globalDir) = convertToOriginalMap(state: state)
    return 1000 * (globalPos.y + 1) + 4 * (globalPos.x + 1) + globalDir.rawValue
  }    
}

enum Move: CustomStringConvertible {
  case left
  case right
  case go(Int)

  var description: String {
    switch self {
    case .left:
      return "L"
    case .right:
      return "R"
    case let .go(distance):
      return "Go \(distance)"
    }
  }
}

func parseMoves(_ input: String.SubSequence) -> [Move] {
  var value = 0
  var seq: [Move] = []
  for ch in input {
    switch ch {
    case "0"..."9":
      value = value * 10 + Int(String(ch))!
    case "L", "R":
      seq.append(.go(value))
      seq.append(ch == "L" ? .left : .right)
      value = 0
    default:
      break
    }
  }
  seq.append(.go(value))
  return seq
}

// -----------------------------------------------------------------------------

let exampleFilename = "example22.txt"

let inputParts = loadInput().split(separator: "\n\n")
let cube = Cube(inputParts[0])
let moves = parseMoves(inputParts[1])

var state = State(side: .top, relativePos: Pos(0, 0), dir: Direction.right)
for move in moves {
  cube.apply(state: &state, move: move)
  let global = cube.convertToOriginalMap(state: state)
  print("\(move) -> \(global.0), facing \(global.1)")
}
print("Part 2: \(cube.score(state: state))")
