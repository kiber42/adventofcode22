import numpy as np
import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input09.txt"
    data = [line.split() for line in open(filename).read().strip().split("\n")]
    directions = {'R': (1, 0), 'L': (-1, 0), 'U': (0, -1), 'D': (0, +1)}
    return [(np.array(directions[d], dtype="int"), int(num)) for d, num in data]


def updateKnot(lead, follow):
    dist = lead - follow
    if max(abs(dist)) < 2:
        return follow
    dist = np.clip(dist, -1, +1)
    return follow + dist


def moveRope(steps, ropeLength):
    visited = set()
    knots = [np.zeros((2), dtype="int") for _ in range(ropeLength)]
    for dir, num in steps:        
        for i in range(num):
            knots[0] += dir
            for i in range(1, ropeLength):
                knots[i] = updateKnot(knots[i-1], knots[i])
            visited.add(tuple(knots[-1]))
    return len(visited)


if __name__ == "__main__":
    steps = loadInput()    
    print("Part 1:", moveRope(steps, 2))
    print("Part 2:", moveRope(steps, 10))
