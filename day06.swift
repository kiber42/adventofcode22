import Foundation

func findMarker(_ message: String.SubSequence, markerLen: Int) -> Int {
  var seen: [Character: Int] = [:]
  var firstValidPos = markerLen
  for (i, ch) in message.enumerated() {
    // If the character has occured before, update minimum acceptable position
    firstValidPos = max(firstValidPos, (seen[ch] ?? -1) + markerLen)
    if i >= firstValidPos {
      // Return end position of valid marker (1-based)
      return i + 1
    }
    seen[ch] = i
  }
  return -1
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example06.txt"
do {
  // Support multiple messages in input file (there are multiple examples), process one line at a time
  let messages = try String(contentsOfFile: filename).split(separator: "\n")
  for message in messages {
    if messages.count > 1 {
      print(message)
    }
    print("  Start of packet: ", findMarker(message, markerLen: 4))
    print("  Start of message:", findMarker(message, markerLen: 14))
  }
} catch {
  print("Could not load input from '\(filename)'.")
}
