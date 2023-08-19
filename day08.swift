import Foundation

// -----------------------------------------------------------------------------

// General functionality

func loadInput() -> String {
    let filename = CommandLine.arguments.count > 1 ?
        CommandLine.arguments[1] : exampleFilename
    do
    {
        return try String(contentsOfFile: filename)
    }
    catch {
        print("Could not load input from '\(filename)'.")
        exit(1)
    }
}

struct Pos : Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

extension Array<Array<Int>> {
    // Transpose a regular m x n array of integers.
    // Returns transposed n x m array.
    func transposed() -> [[Int]] {
        var t : [[Int]] = []
        for row in self {
            for (index, cell) in row.enumerated() {
                while t.count <= index
                {
                    t.append([])
                }
                t[index].append(cell)
            }
        }
        return t
    }
}

// -----------------------------------------------------------------------------

// Functionality for part 1

func visibleFromStart<T: Collection<Int>>(_ lineOfTrees: T) -> [Int] {
    var indices: [Int] = []
    var tallest = -1
    for (x, h) in lineOfTrees.enumerated() {
        if h > tallest {
            indices.append(x)
            tallest = h
        }
    }
    return indices
}

func visibleFromEnd(_ lineOfTrees: [Int]) -> [Int] {
    return visibleFromStart(lineOfTrees.reversed()).map{lineOfTrees.count - 1 - $0}
}

// -----------------------------------------------------------------------------

// Functionality for part 2

func viewingDistancesForward<T: Collection<Int>>(_ lineOfTrees: T) -> [Int] {    
    var heightAndDistanceStack = Array<(Int, Int)>()
    var distances: [Int] = []
    for current in lineOfTrees {
        var distance = heightAndDistanceStack.isEmpty ? 0 : 1
        while let (height, count) = heightAndDistanceStack.last, current > height {
            heightAndDistanceStack.removeLast()
            distance += count
        }
        distances.append(distance)
        heightAndDistanceStack.append((current, distance))
    }
    return distances
}

func viewingDistancesBackward(_ lineOfTrees: [Int]) -> [Int] {
    return viewingDistancesForward(lineOfTrees.reversed()).reversed()
}

// -----------------------------------------------------------------------------

let exampleFilename = "example08.txt"

let treeRows = loadInput().split(separator: "\n").map({ $0.map({ Int(String($0))! })})
let treeColumns = treeRows.transposed()

let visiblePositions =
    treeRows.enumerated().flatMap({(y, row) in
        [visibleFromStart(row), visibleFromEnd(row)].joined().map{ x in Pos(x, y) }
    }) +
    treeColumns.enumerated().flatMap({(x, col) in
        [visibleFromStart(col), visibleFromEnd(col)].joined().map{ y in Pos(x, y) }
    })
let uniquePositions = Set(visiblePositions)
print("Part 1: \(uniquePositions.count)")

let distances = [
    treeRows.map{viewingDistancesForward($0)},
    treeRows.map{viewingDistancesBackward($0)},
    treeColumns.map({viewingDistancesForward($0)}).transposed(),
    treeColumns.map({viewingDistancesBackward($0)}).transposed(),
]
let scenicScores = (0..<treeRows.first!.count).flatMap{y in
    (0..<treeRows.count).map{x in
        (0...3).map({distances[$0][y][x]}).reduce(1, *)
    }
}
print("Part 2: \(scenicScores.max()!)")
