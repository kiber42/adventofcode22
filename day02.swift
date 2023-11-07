import Foundation

// Parse input and return the choices for each round
func getChoices(args: [String]) -> [(Int, Int)] {
  let filename = args.count > 1 ? args[1] : "example02.txt"
  let data = try! String(contentsOfFile: filename)

  // Convert choices (A,B,C or X,Y,Z) to numeric values (1,2,3)
  return data.split(separator: "\n").map {
    // First item = opponent's choice
    let opponent = Int($0.first!.asciiValue!) - Int(("A" as Character).asciiValue!) + 1
    // Second item = my choice (part 1) OR desired outcome (part 2)
    let mine = Int($0.last!.asciiValue!) - Int(("X" as Character).asciiValue!) + 1
    return (opponent, mine)
  }
}

func computeScore(opponentsChoice: Int, myChoice: Int) -> Int {
  let outcome = (myChoice - opponentsChoice + 4) % 3  // +1: win, -1: loss, 0: draw
  return 3 * outcome + myChoice
}

func pickResponseFor(opponentsChoice: Int, desiredOutcome: Int) -> (Int, Int) {
  // return a pair that also has opponentsChoice again, to allow easy chaining of functions
  return (opponentsChoice, (opponentsChoice + desiredOutcome) % 3 + 1)
}

let choices = getChoices(args: CommandLine.arguments)
print("Part 1:", choices.map(computeScore).reduce(0, +))
print("Part 2:", choices.map(pickResponseFor).map(computeScore).reduce(0, +))
