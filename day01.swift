import Foundation

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example01.txt"
do
{
    let contents = try String(contentsOfFile: filename)
    let blocks = contents.split(separator: "\n\n")
    let sums = blocks.map({ $0.split(separator: "\n").map({ Int($0)! }).reduce(0, +)})
    let maxSum = sums.max()!
    print("Maximal block sum: \(maxSum)")
    let topThree = sums.sorted().suffix(3).reduce(0, +)
    print("Sum of largest 3 blocks: \(topThree)")
} catch {
    print("Could not load input from '\(filename)'.")
}
