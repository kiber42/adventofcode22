from functools import cmp_to_key
import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input13.txt"
    lines = [line.strip() for line in open(filename).readlines()]
    return [eval(line) for line in lines if line]


def compare(x, y):
    if isinstance(x, list):
        if not isinstance(y, list):
            y = [y]            
        for x_, y_ in zip(x, y):
            result = compare(x_, y_)
            if result != 0:
                return result        
        return len(x) - len(y)
    elif isinstance(y, list):
        return -compare(y, x)
    return x - y


def inCorrectOrder(x, y):
    return compare(x, y) < 0


def processPairs(packets):
    score = 0
    for pairIndex in range(len(packets) // 2):
        if inCorrectOrder(packets[2 * pairIndex], packets[2 * pairIndex + 1]):
            score += pairIndex + 1
    return score


def findDividers(packets, dividers):
    packets.extend(dividers)
    packets = sorted(packets, key=cmp_to_key(compare))
    dividerIndices = [packets.index(divider) + 1 for divider in dividers]
    return dividerIndices[0] * dividerIndices[1]


if __name__ == "__main__":
    packets = loadInput()
    dividers = [[[2]], [[6]]]
    print("Part 1:", processPairs(packets))
    print("Part 2:", findDividers(packets, dividers))
