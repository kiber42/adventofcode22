import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input04.txt"
    data = open(filename).readlines()
    return [[tuple(int(x) for x in parts.split("-")) for parts in line.split(",")] for line in data]


def oneFullyContainsOther(a, b):
    return (a[0] <= b[0] and a[1] >= b[1]) or (b[0] <= a[0] and b[1] >= a[1])


def haveOverlap(a, b):
    return (a[0] >= b[0] and a[0] <= b[1]) or \
        (a[1] >= b[0] and a[1] <= b[1]) or (b[0] >= a[0] and b[0] <= a[1])


if __name__ == "__main__":
    assignments = loadInput()
    print("Part 1:", sum(1 if oneFullyContainsOther(*assignment) else 0 for assignment in assignments))
    print("Part 2:", sum(1 if haveOverlap(*assignment) else 0 for assignment in assignments))
