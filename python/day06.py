import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input06.txt"
    return open(filename).read().strip()


def scanForDuplicate(segment):
    for pos in range(len(segment)):
        if segment[pos] in segment[pos+1:]:
            return pos
    return None


def findMarker(message, markerLength):
    pos = 0
    while pos <= len(message) - markerLength:
        segment = message[pos : pos + markerLength]
        duplicatePos = scanForDuplicate(segment)
        if duplicatePos is None:
            return pos + markerLength, segment
        pos += duplicatePos + 1
    raise "No marker detected"


if __name__ == "__main__":
    message = loadInput()
    for part, markerLength in enumerate([4, 14]):
        print("Part {0}: Found marker '{2}' at position {1}".format(part + 1, *findMarker(message, markerLength)))
