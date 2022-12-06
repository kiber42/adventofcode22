import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input03.txt"
    return open(filename).read().strip().split("\n")


def prio(item):
    if item <= 'Z':
        return ord(item) - ord('A') + 27
    return ord(item) - ord('a') + 1


def findDuplicate(content):
    num_items = len(content) // 2
    compartmentA, compartmentB = content[:num_items], content[num_items:]
    return next(itemA for itemA in compartmentA if itemA in compartmentB)


def findCommon(contents):
    A, B, C = (sorted(content) for content in contents)
    while A[0] != B[0] or A[0] != C[0]:
        while A[0] < B[0] or A[0] < C[0]:
            A = A[1:]
        while A[0] > B[0]:
            B = B[1:]
        while C[0] < A[0] or C[0] < B[0]:
            C = C[1:]
    return A[0]


if __name__ == "__main__":
    rucksacks = loadInput()
    print("Part 1:", sum(prio(findDuplicate(content.strip())) for content in rucksacks))
    print("Part 2:", sum(prio(findCommon(rucksacks[index:index+3])) for index in range(0, len(rucksacks), 3)))
