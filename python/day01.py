import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input01.txt"
    data = open(filename).read().split("\n")
    return [int(line) if line else None for line in data]


if __name__ == "__main__":
    counts = loadInput()
    current = 0
    totals = []
    for count in counts:
        if count is None:
            totals.append(current)
            current = 0
        else:
            current += count
    print("Part 1:", max(totals))
    print("Part 2:", sum(sorted(totals)[-3:]))
