import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input02.txt"
    return [parse(line) for line in open(filename).readlines()]


def parse(turn):
    itemA, itemB = turn.split()
    return ord(itemA) - ord('A'), ord(itemB) - ord('X')


def score(shapeA, shapeB):
    outcome = (shapeB - shapeA + 4) % 3
    return 3 * outcome + shapeB + 1


def score2(shapeA, outcome):
    shapeB = (shapeA + outcome + 2) % 3
    return 3 * outcome + shapeB + 1


if __name__ == "__main__":
    turns = loadInput()
    print("Part 1:", sum(score(*turn) for turn in turns))
    print("Part 2:", sum(score2(*turn) for turn in turns))
