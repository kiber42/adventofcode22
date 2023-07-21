import Foundation

func indexOf(str: String.SubSequence, find: Character) -> Int?
{
    return str.firstIndex(of: find)?.utf16Offset(in: str)
}

struct Pos : Hashable, CustomStringConvertible {
    var x, y: Int
    var description: String {
        return "(\(x)|\(y))"
    }
}

class Map : CustomStringConvertible
{
    var width: Int
    var height: Int
    var startPos: Pos
    var goalPos: Pos
    var blizzards: [Set<Pos>] // Length 4, moving up/down/left/right

    init(raw: String) {
        let rows = raw.split(whereSeparator: \.isNewline)
        (self.width, self.height) = (rows.first!.count, rows.count)
        self.startPos = Pos(x: indexOf(str: rows.first!, find: ".")!, y: 0)
        self.goalPos = Pos(x: indexOf(str: rows.last!, find: ".")!, y: rows.count - 1)  
        self.blizzards =
        [
            Map.findBlizzards(rows: rows, symbol: "^"),
            Map.findBlizzards(rows: rows, symbol: "v"),
            Map.findBlizzards(rows: rows, symbol: "<"),
            Map.findBlizzards(rows: rows, symbol: ">"),
        ]
    }

    var description: String {
        return """
        Size: \(self.width) x \(self.height)
        Path: \(self.startPos) -> \(self.goalPos)
        Blizzards:
          Moving up    \(self.blizzards[0])
          Moving down  \(self.blizzards[1])
          Moving left  \(self.blizzards[2])
          Moving right \(self.blizzards[3])
        """
    }

    func isFree(pos: Pos, turn: Int) -> Bool
    {
        if (pos.x < 1 || pos.x > self.width - 2 || pos.y < 1 || pos.y > self.height - 2)
        {
            return pos == self.startPos || pos == self.goalPos
        }
        // Instead of updating the blizzard positions, compute where a blizzard would have
        // needed to be at the start to be at `pos` after `turn` turns.
        let mod_x = self.width - 2
        let mod_y = self.height - 2
        return !(self.blizzards[0].contains(Pos(x: pos.x, y: ((pos.y + turn - 1) % mod_y + mod_y) % mod_y + 1))
              || self.blizzards[1].contains(Pos(x: pos.x, y: ((pos.y - turn - 1) % mod_y + mod_y) % mod_y + 1))
              || self.blizzards[2].contains(Pos(x: ((pos.x + turn - 1) % mod_x + mod_x) % mod_x + 1, y: pos.y))
              || self.blizzards[3].contains(Pos(x: ((pos.x - turn - 1) % mod_x + mod_x) % mod_x + 1, y: pos.y)))
    }

    func nextPositions(pos: Pos) -> [Pos]
    {
        // Compute adjacent positions.
        // Since waiting is allowed, also include the current position.
        // Validity is checked in `isFree`
        let (x, y) = (pos.x, pos.y)
        return [pos, Pos(x:x, y:y-1), Pos(x:x, y:y+1), Pos(x:x-1, y:y), Pos(x:x+1, y:y)]
    }

    func validNextPositions(pos: Pos, turn: Int) -> [Pos]
    {
        return self.nextPositions(pos: pos).filter({self.isFree(pos: $0, turn: turn)})
    }

    func findMinimumTime(from: Pos, to: Pos, startTurn: Int) -> Int
    {
        var positions : Set = [from]
        var turn = startTurn
        while (!positions.contains(where: {$0 == to}))
        {
            turn += 1
            positions = Set(positions.map({self.validNextPositions(pos: $0, turn: turn)}).joined())
            print("After \(turn) minutes, there are \(positions.count) reachable positions.")
        }
        return turn
    }

    static func findBlizzards(rows: [String.SubSequence], symbol: Character) -> Set<Pos>
    {
        var result = [Pos]();
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == symbol { result.append(Pos(x: x, y: y)) }
            }
        }
        return Set(result)
    }
}

let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example24.txt"
if let data = try? String(contentsOfFile: path)
{
    let map = Map(raw: data)
    print(map)
    let turns1 = map.findMinimumTime(from: map.startPos, to: map.goalPos, startTurn: 0)
    print("Reached exit once after \(turns1) minutes.")
    let turns2 = map.findMinimumTime(from: map.goalPos, to: map.startPos, startTurn: turns1)
    print("Returned to start after \(turns2) minutes.")
    let turns3 = map.findMinimumTime(from: map.startPos, to: map.goalPos, startTurn: turns2)
    print("Reached exit again after \(turns3) minutes.")
    print()
    print("Answers:   Part 1: \(turns1)   Part 2: \(turns3)")
}
else
{
    print("Could not open file '\(path)'.")
}
