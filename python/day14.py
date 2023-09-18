import numpy as np
from itertools import pairwise
import sys

sandSource = [500, 0]

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input14.txt"
    data = open(filename).read().strip().split("\n")
    obstacles = []
    minPos = np.array(sandSource)
    maxPos = np.array(sandSource)
    for lineData in data:
        line = [np.array([int(x) for x in point.split(",")], dtype="int") for point in lineData.split(" -> ")]
        for pos, end in pairwise(line):
            minPos = np.min([minPos, pos, end], axis=0)
            maxPos = np.max([maxPos, pos, end], axis=0)
            dir = np.clip(end - pos, -1, +1)
            while (pos != end).any():       
                obstacles.append(tuple(pos))                
                pos += dir
        obstacles.append(tuple(line[-1]))
    obstacles -= minPos
    caveSize = maxPos - minPos + [1, 1]
    cave = np.zeros(caveSize, dtype="int")
    cave[obstacles[:,0], obstacles[:,1]] = 1
    return cave, tuple(sandSource - minPos)


# drop sand from pos, return True if it settles somewhere, or False if it falls into the abyss.
# (For part 2, one could just set every touched field to 2 directly?)
def dropSand(cave, pos):
    if cave[pos] != 0:
        return False
    x, y = pos
    maxY = cave.shape[1]
    while y < maxY - 1:
        for nextX in [x, x - 1, x + 1]:
            if cave[nextX, y + 1] == 0:
                x = nextX
                y += 1
                break
        else:
            cave[x, y] = 2
            return True
    return False


def simulateCaveIn(cave, sandSource):
    cave = np.copy(cave)
    count = 0
    while dropSand(cave, sandSource):
        count += 1
    return count


def addFloor(cave, sandSource):
    width, height = cave.shape
    # Sand pile cannot be wider than it is high
    bigCave = np.zeros((width + 2 * height, height + 2), dtype="int")
    bigCave[:,-1] = 1
    bigCave[height:height+width,0:height] = cave
    return bigCave, (sandSource[0] + height, sandSource[1])


if __name__ == "__main__":
    cave, source = loadInput()
    print("Part 1:", simulateCaveIn(cave, source))
    cave, source = addFloor(cave, source)
    print("Part 1:", simulateCaveIn(cave, source))
    