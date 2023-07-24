import Foundation

func findMarker(_ message : String.SubSequence, markerLen : Int) -> Int {
    var seen : [Character : Int] = [:]
    var minValidPos = 0
    for (i, ch) in message.enumerated() {
        // If character occured before, may have to increase the minimum
        // possible position
        minValidPos = max(minValidPos, (seen[ch] ?? -1) + markerLen)
        seen[ch] = i
        if i >= minValidPos {
            // Return 1-based index of last processed character
            return i + 1
        }
    }
    return -1
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example06.txt"
do
{
    // Support multiple messages in input file (there are multiple examples)
    let messages = try String(contentsOfFile: filename).split(separator: "\n")
    for message in messages {
        if (message.count < 100)
        {
            print(message)
        }
        print("  Start of packet:  \(findMarker(message, markerLen: 4))")
        print("  Start of message: \(findMarker(message, markerLen: 14))")
    }
} catch {
    print("Could not load input from '\(filename)'.")
}
