import Foundation

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example02.txt"
do
{
    let rounds = try String(contentsOfFile: filename).split(separator:"\n")
    let choices = rounds.map({
        // Opponent's choice
        let first = Int($0.first!.asciiValue!) - Int(("A" as Character).asciiValue!) + 1
        // My choice (part 1) or desired outcome (part 2)
        let second = Int($0.last!.asciiValue!) - Int(("X" as Character).asciiValue!) + 1
        return (first, second)
    })

    let computeScore = { opponent, mine in
        3 * ((mine - opponent + 4) % 3) + mine
    }
    let scoreOne = choices.map(computeScore).reduce(0, +)
    let scoreTwo = choices.map({ (opponent, outcome) in
        computeScore(opponent, (opponent + outcome) % 3 + 1)
    }).reduce(0, +)

    print("Part 1: \(scoreOne)")
    print("Part 2: \(scoreTwo)")
} catch {
    print("Could not load input from '\(filename)'.")
}
