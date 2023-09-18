import numpy as np
import sys




def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input12.txt"
    return open(filename).readlines()


def prepareMap(heights):
    area = np.empty((len(heights[0]), len(heights)), dtype="int")
    for y, row in enumerate(heights):
        for x, cell in enumerate(row):
            if cell == "S":
                cell = "a"
                start = (x, y)
            elif cell == "E":
                cell = "z"
                goal = (x, y)
            area[x, y] = ord(cell) - ord('a')
    return area, start, goal


def runFloodFill(area, start, goal):
    justReached = [start]
    distances = np.zeros(area.shape, dtype="int")
    directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    while distances[goal] == 0:
        pos = justReached.pop(0)
        steps = distances[pos] + 1
        for dir in directions:
            newPos = np.array(pos) + dir
            if min(newPos) < 0 or min(area.shape - newPos) <= 0:
                continue
            newPos = tuple(newPos)
            if area[newPos] > area[pos] + 1:
                continue
            oldDist = distances[newPos]
            if (oldDist == 0 or oldDist > steps):
                distances[newPos] = steps
                justReached.append(newPos)
    return distances[goal]


def runFloodFill2(area, _, goal):
    justReached = [goal]
    distances = np.zeros(area.shape, dtype="int")
    directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    while True:
        pos = justReached.pop(0)
        steps = distances[pos] + 1
        for dir in directions:
            newPos = np.array(pos) + dir
            if min(newPos) < 0 or min(area.shape - newPos) <= 0:
                continue
            newPos = tuple(newPos)
            if area[newPos] < area[pos] - 1:
                continue
            oldDist = distances[newPos]
            if (oldDist == 0 or oldDist > steps):
                distances[newPos] = steps
                if area[newPos] == 0:
                    return steps
                justReached.append(newPos)
    return distances[goal]


if __name__ == "__main__":
    mapData = prepareMap(loadInput())
    print("Part 1:", runFloodFill(*mapData))
    print("Part 2:", runFloodFill2(*mapData))
