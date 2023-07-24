import Foundation

struct Stack<T>
{
    private var data = Array<T>()

    public mutating func push(_ val : T) {
        data.append(val)
    }

    public mutating func pop() -> T {
        let result = top()!
        data.removeLast()
        return result
    }

    public func top() -> T? {
        return data.last
    }
}

func buildStacks(_ stackInput : [Substring.SubSequence]) -> [Stack<Character>]
{
    let stackData = stackInput.reversed().dropFirst(1)
    let numStacks = (stackData.first!.count + 1) / 4
    var stacks = Array(repeating: Stack<Character>(), count: numStacks)
    for line in stackData {
        for pos in 0..<numStacks {
            let crate = line[line.index(line.startIndex, offsetBy: 4 * pos + 1)]
            if crate != " " { stacks[pos].push(crate) }
        }
    }
    return stacks
}

func buildSteps(_ stepInput : [Substring.SubSequence]) -> [(Int, Int, Int)]
{
    return stepInput
        .map({ $0.split(separator: " ")
            .map({ Int($0) ?? -1 }).filter({ $0 > 0 })
        })
        .map({ ($0[0], $0[1] - 1, $0[2] - 1) })
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example05.txt"
do
{
    let blocks = try String(contentsOfFile: filename)
        .split(separator: "\n\n").map({ $0.split(separator: "\n") })
    let steps = buildSteps(blocks[1])

    var stacks = buildStacks(blocks[0])
    for (n, from, to) in steps {
        for _ in 1...n { stacks[to].push(stacks[from].pop()) }
    }
    let answer1 = String(stacks.map({ $0.top() ?? Character("_") }))

    stacks = buildStacks(blocks[0])
    for (n, from, to) in steps {
        var temp = Stack<Character>()
        for _ in 1...n { temp.push(stacks[from].pop()) }
        for _ in 1...n { stacks[to].push(temp.pop()) }
    }
    let answer2 = String(stacks.map({ $0.top() ?? Character("_") }))

    print("Part 1: ", answer1)
    print("Part 2: ", answer2)
} catch {
    print("Could not load input from '\(filename)'.")
}
