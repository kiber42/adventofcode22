import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input15.txt"
    sensors = []
    beacons = []
    for line in open(filename).readlines():
        tokens = line.split(" ")
        values = tuple(int(x[2:-1]) for x in tokens if "=" in x)
        sensors.append((values[0], values[1], manhattan(*values)))
        beacons.append((values[2], values[3]))
    return sensors, sorted(set(beacons))


def manhattan(ax, ay, bx, by):
    return abs(ax - bx) + abs(ay - by)


def getSegmentsOnRow(sensors, row):
    segments = []
    for sensorX, sensorY, sensorRange in sensors:
        sensorRange -= abs(sensorY - row)
        if sensorRange < 0:
            continue
        segments.append((sensorX - sensorRange, sensorX + sensorRange))
    return mergeOverlappingSegments(segments)


def mergeOverlappingSegments(segments):
    merged = []
    current = None
    for segment in sorted(segments):
        if current is not None:
            if segment[0] > current[1]:
                merged.append(tuple(current))
                current = None
            elif segment[1] > current[1]:
                current[1] = segment[1]
        if current is None:
            current = list(segment)
    merged.append(tuple(current))
    return merged


def countExcludedPositions(sensors, knownBeacons, targetRow):
    segments = getSegmentsOnRow(sensors, targetRow)
    numCovered = sum(end - start + 1 for start, end in segments)
    numBeacons = sum(1 if y == targetRow else 0 for _, y in knownBeacons)
    return numCovered - numBeacons


def findUncoveredPosition(segments, maxPos):
    cropped = []
    for start, end in segments:
        start = max(0, start)
        end = min(end, maxPos)
        if end >= start:
            cropped.append((start, end))
    if len(cropped) == 1:
        return None
    assert(len(cropped) == 2)
    gap = cropped[0][1] + 1
    assert(cropped[1][0] - 1 == gap)
    return gap


def locateMissingBeacon(sensors, maxPos):
    for row in range(maxPos):
        if row % 100000 == 0 and row > 0:
            print("{:.1%}".format(row / maxPos))
        segments = getSegmentsOnRow(sensors, row)
        col = findUncoveredPosition(segments, maxPos)
        if col is not None:
            tuningFrequency = 4000000 * col + row
            return tuningFrequency
    return -1


if __name__ == "__main__":
    sensors, knownBeacons = loadInput()
    maxPos = 4000000 if len(sensors) > 20 else 20
    targetRow = maxPos // 2
    print("Part 1:", countExcludedPositions(sensors, knownBeacons, targetRow))
    print("Part 2:", locateMissingBeacon(sensors, maxPos))
