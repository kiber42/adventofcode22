import numpy as np
import sys

class Forest:
    Directions = [[-1, 0], [+1, 0], [0, -1], [0, +1]]
    
    def __init__(self):
        filename = sys.argv[1] if len(sys.argv) >= 2 else "input08.txt"
        data = open(filename).read().strip().split("\n")
        self.trees = np.array([np.array([int(t) for t in row]) for row in data])
        self.height, self.width = self.trees.shape


    def isValidPos(self, x, y):
        return x >= 0 and y >= 0 and x < self.width and y < self.height


    # Determine how far one can see in a given directory.
    # Second returned value indicates whether one can see the border.
    def viewingDistance(self, x, y, dx, dy):
        dist = 0
        height = self.trees[y, x]
        while True:
            if not self.isValidPos(x, y):
                return dist - 1, True
            if dist > 0 and self.trees[y, x] >= height:
                return dist, False
            dist += 1
            x += dx
            y += dy


    def canSeeBorder(self, x, y, dx, dy):
        return self.viewingDistance(x, y, dx, dy)[1]


    def isVisible(self, x, y):
        return any(self.canSeeBorder(x, y, dx, dy) for dx, dy in Forest.Directions)


    def countVisible(self):
        return sum(self.isVisible(x, y) for x in range(self.width) for y in range(self.height))


    def sceneScore(self, x, y):
        score = 1
        for dx, dy in Forest.Directions:
            score *= self.viewingDistance(x, y, dx, dy)[0]
        return score


    def bestSceneScore(self):
        return max(self.sceneScore(x, y) for x in range(self.width) for y in range(self.height))

    
if __name__ == "__main__":
    forest = Forest()
    print("Part 1:", forest.countVisible())
    print("Part 1:", forest.bestSceneScore())
