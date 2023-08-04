import Foundation

struct Pos : Hashable, CustomStringConvertible {
    var x, y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    var description: String {
        return "(\(x)|\(y))"
    }
}

class Field : CustomStringConvertible
{
    var turn: Int
    var elves: Set<Pos>

    init(raw: String) {
        self.turn = 0
        self.elves = []
        let rows = raw.split(whereSeparator: \.isNewline)
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "#" { self.elves.insert(Pos(x, y)) }
            }
        }
    }

    func minMaxPos() -> (Pos, Pos) {
        let pos0 = self.elves.count > 0 ? self.elves.first! : Pos(0, 0)
        return self.elves.reduce(
            (pos0, pos0),
            { minMax, pos in
                (Pos(min(minMax.0.x, pos.x), min(minMax.0.y, pos.y)),
                 Pos(max(minMax.1.x, pos.x), max(minMax.1.y, pos.y)))
            })
    }

    func size() -> (Int, Int) {
        let (minPos, maxPos) = self.minMaxPos()
        return (maxPos.x - minPos.x + 1, maxPos.y - minPos.y + 1)
    }

    func score() -> Int {
        let (width, height) = self.size()
        return width * height - self.elves.count
    }

    var description: String {
        let (minPos, maxPos) = self.minMaxPos()
        return (minPos.y...maxPos.y).map{ y in
            (minPos.x...maxPos.x).map{ x in
                self.elves.contains(Pos(x, y)) ? "#" : "." }.joined()
        }.joined(separator: "\n")
    }

    func status() -> String {
        return "After \(self.turn) turns: Size = \(self.size()); Score = \(self.score())"
    }

    func proposeMove(_ elf: Pos) -> Pos
    {
        let hasNeighbour = self.elves.contains {
            other in
            return other != elf && abs(other.x - elf.x) <= 1 && abs(other.y - elf.y) <= 1
        }
        if (hasNeighbour)
        {
            for d in (0...4) {
                let dir = (d + self.turn) % 4
                let targetPos : Pos
                switch(dir) {
                    case 0: targetPos = Pos(elf.x, elf.y - 1)
                    case 1: targetPos = Pos(elf.x, elf.y + 1)
                    case 2: targetPos = Pos(elf.x - 1, elf.y)
                    case 3, _: targetPos = Pos(elf.x + 1, elf.y)
                }
                let side1 = dir < 2 ? Pos(targetPos.x - 1, targetPos.y) : Pos(targetPos.x, targetPos.y - 1)
                let side2 = dir < 2 ? Pos(targetPos.x + 1, targetPos.y) : Pos(targetPos.x, targetPos.y + 1)
                if !self.elves.contains(targetPos) && !self.elves.contains(side1) && !self.elves.contains(side2) {
                    return targetPos
                }
            }
        }
        return elf
    }

    func move() -> Bool {
        var plans: [(Pos, Pos)] = []
        var targetCounts : [Pos : Int]  = [:]
        for elf in self.elves {
            let newPos = proposeMove(elf)
            plans.append((elf, newPos))
            targetCounts[newPos] = (targetCounts[newPos] ?? 0) + 1
        }
        var moveCount = 0
        self.elves = Set(plans.map({(from, to) in
            if to != from && targetCounts[to] == 1 {
                moveCount += 1
                return to
            }
            return from
        }))
        self.turn += 1
        return moveCount > 0
    }
}

let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example23_1.txt"
if let data = try? String(contentsOfFile: path)
{
    let field = Field(raw: data)
    while (field.move()) {
        if (field.turn <= 10) {
            print(field)
            print(field.status())
        }
        else if (field.turn % 100 == 0) {
            print(field.status())
        }
    }
    print("First turn without any moves: \(field.turn)")
    print(field.status())
}
else
{
    print("Could not open file '\(path)'.")
}
