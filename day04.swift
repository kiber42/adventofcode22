import Foundation

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example04.txt"
do
{
    let input = try String(contentsOfFile: filename).split(separator: "\n")
    let assignments = input.map({ row in
            row.split(separator: ",")
                .map({ $0.split(separator: "-").map({ Int($0)! }) })
                .map({ $0[0]...$0[1] })
        })
    let numFullOverlap = assignments.filter({ranges in
        ranges[0].contains(ranges[1]) || ranges[1].contains(ranges[0])}).count
    print("Part 1: \(numFullOverlap)")
    let numPartialOverlap = assignments.filter({ranges in
        ranges[0].overlaps(ranges[1]) || ranges[1].overlaps(ranges[0])}).count
    print("Part 2: \(numPartialOverlap)")
} catch {
    print("Could not load input from '\(filename)'.")
}
