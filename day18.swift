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

struct Point3: Hashable, CustomStringConvertible {
  let x: Int
  let y: Int
  let z: Int

  init(_ x: Int, _ y: Int, _ z: Int) {
    self.x = x
    self.y = y
    self.z = z
  }

  static func fromData(_ data: [Int]) -> Point3 {
    assert(data.count == 3)
    return Point3(data[0], data[1], data[2])
  }

  var description: String {
    "(\(x),\(y),\(z))"
  }

  func isValid(bounds: Point3) -> Bool {
    return x >= -1 && y >= -1 && z >= -1 && x <= bounds.x + 1 && y <= bounds.y + 1
      && z <= bounds.z + 1
  }

  func neighbours() -> [Point3] {
    return [
      Point3(x + 1, y + 0, z + 0),
      Point3(x - 1, y + 0, z + 0),
      Point3(x + 0, y + 1, z + 0),
      Point3(x + 0, y - 1, z + 0),
      Point3(x + 0, y + 0, z + 1),
      Point3(x + 0, y + 0, z - 1),
    ]
  }
}

func getSurfaceArea(voxels: [Point3]) -> Int {
  var surface = 0
  var droplet = Set<Point3>()
  for voxel in voxels {
    for neighbour in voxel.neighbours() {
      surface += droplet.contains(neighbour) ? -1 : +1
    }
    droplet.insert(voxel)
  }
  return surface
}

func getBounds(voxels: [Point3]) -> Point3 {
  var x = 0
  var y = 0
  var z = 0
  for voxel in voxels {
    x = max(x, voxel.x)
    y = max(y, voxel.y)
    z = max(z, voxel.z)
  }
  return Point3(x, y, z)
}

func getExposedSurfaceArea(voxels: [Point3]) -> Int {
  let start = Point3(0, 0, 0)
  assert(!voxels.contains(start))

  var newSteam = Set([start])
  var allSteam = Set<Point3>()

  let bounds = getBounds(voxels: voxels)
  var exposedSurface = 0
  while let steam = newSteam.popFirst() {
    for neighbour in steam.neighbours() {
      if neighbour.isValid(bounds: bounds) && !allSteam.contains(neighbour) {
        if voxels.contains(neighbour) {
          exposedSurface += 1
        } else {
          allSteam.insert(neighbour)
          newSteam.insert(neighbour)
        }
      }
    }
  }
  return exposedSurface
}

// -----------------------------------------------------------------------------

let voxels = loadInput(exampleFilename: "example18.txt").split(separator: "\n").map { line in
  return Point3.fromData(line.split(separator: ",").compactMap { Int($0) })
}

print("Part 1:", getSurfaceArea(voxels: voxels))
print("Part 2:", getExposedSurfaceArea(voxels: voxels))
