import Foundation

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example01.txt"
let data = try! String(contentsOfFile: filename)

let numberBlocks = data.split(separator: "\n\n")
let blockSums = numberBlocks.map { block in
  block.split(separator: "\n").map({ Int($0)! }).reduce(0, +)
}.sorted()

print("Part 1:", blockSums.last!)
print("Part 2:", blockSums.suffix(3).reduce(0, +))
