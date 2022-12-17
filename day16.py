from math import factorial
import numpy as np
from itertools import permutations, combinations
import sys

class Cave:
    def __init__(self):
        self.flowRates, self.allConnections, self.names = Cave.loadInput()
        self.distances = Cave.computeDistances(self.allConnections)
        self.removeBrokenValves()


    def loadInput():
        filename = sys.argv[1] if len(sys.argv) >= 2 else "input16.txt"
        names = []
        nameToIndex = {}
        flowRates = []
        allNamedConnections = []
        # Sort input so that AA is always at index 0
        for index, line in enumerate(sorted(open(filename).readlines())):
            tokens = line.replace(",", "").split()
            name, rate, connections = tokens[1], int(tokens[4][5:-1]), tokens[9:]
            names.append(name)
            nameToIndex[name] = index
            flowRates.append(rate)
            allNamedConnections.append(connections)
        allConnections = [[nameToIndex[name] for name in namedConnections] for namedConnections in allNamedConnections]
        return np.array(flowRates), allConnections, names


    def computeDistances(allConnections):
        n = len(allConnections)
        distances = 99 * np.ones((n, n), dtype="int")
        for start, connections in enumerate(allConnections):
            distances[start][connections] = 1
        for pathLength in range(1, n):
            if np.max(distances) < pathLength:
                break
            for x, y in zip(*np.where(distances == pathLength)):
                distances[x] = np.min(np.vstack([distances[x], (pathLength + 1) * distances[y]]), axis=0)
        # set diagonal to zero ('identity' distance)
        distances.ravel()[::distances.shape[1]+1] = 0
        return distances


    def removeBrokenValves(self):
        working = np.where(self.flowRates > 0)[0]
        # cannot remove starting position
        if working[0] != 0:
            working = np.hstack([[0], working])
        self.flowRates = self.flowRates[working]
        self.distances = self.distances[working][:,working]
        self.names = [self.names[i] for i in working]

    
    def computeReleasedPressure(self, steps, timeLeft):
        assert len(set(steps)) == len(steps), "steps must not contain duplicates"
        pos = 0
        currentFlow = 0
        releasedPressure = 0
        usedSteps = 0
        while usedSteps < len(steps):
            goal = steps[usedSteps]
            # opening valve requires one unit of time
            timeNeeded = self.distances[pos, goal] + 1
            if timeLeft <= timeNeeded:
                break
            timeLeft -= timeNeeded
            releasedPressure += currentFlow * timeNeeded
            pos = goal
            currentFlow += self.flowRates[goal]
            usedSteps += 1
        releasedPressure += currentFlow * timeLeft
        return releasedPressure, usedSteps


    def computeReleasedPressureVerbose(self, steps, timeLeft):
        assert len(set(steps)) == len(steps), "steps must not contain duplicates"
        pos = 0
        currentFlow = 0
        releasedPressure = 0
        usedSteps = 0
        while usedSteps < len(steps):
            goal = steps[usedSteps]
            # opening valve requires one unit of time
            distance = self.distances[pos, goal]
            if timeLeft <= distance + 1:
                break
            timeLeft -= distance + 1
            releasedPressure += currentFlow * (distance + 1)
            print("Current released pressure:", releasedPressure, "-- Remaining time:", timeLeft)
            pos = goal
            print("Move to", self.names[goal], "(distance={})".format(distance), "and open valve")
            currentFlow += self.flowRates[goal]
            print("Increased total flow by", self.flowRates[goal], "-- total is now", currentFlow)
            usedSteps += 1
        releasedPressure += currentFlow * timeLeft
        if timeLeft:
            print("Pressure released during remaining time:", currentFlow * timeLeft)
            print("Total released pressure:", releasedPressure)
        return releasedPressure, usedSteps


    def findMaximalPressure(self):
        best = 0
        bestSeq = []
        nmin = 0 if self.flowRates[0] != 0 else 1
        nmax = self.flowRates.shape[0]
        for seq in permutations(range(nmin, nmax), min(nmax - nmin, 8)):
            pressure, usedSteps = self.computeReleasedPressure(seq, 30)
            if pressure > best:
                best, bestSeq = pressure, seq[:usedSteps]
                print("Max so far:", pressure, " ".join([self.names[i] for i in bestSeq]))
        self.computeReleasedPressureVerbose(bestSeq, 30)
        return best


    def computeReleasedPressureWithElephant(self, steps):
        assert len(set(steps)) == len(steps), "steps must not contain duplicates"
        myGoal, elephantGoal = steps[0], steps[1]
        myCurrentActivityTimer = self.distances[0,myGoal] + 1
        elephantCurrentActivityTimer = self.distances[0,elephantGoal] + 1
        timeLeft = 26
        currentFlow = 0
        releasedPressure = 0
        stepIndex = 2
        for _ in range(timeLeft):
            releasedPressure += currentFlow
            myCurrentActivityTimer -= 1
            if myCurrentActivityTimer == 0:
                currentFlow += self.flowRates[myGoal]
                if stepIndex < len(steps):
                    myPos = myGoal
                    myGoal = steps[stepIndex]
                    myCurrentActivityTimer = self.distances[myPos,myGoal] + 1
                    stepIndex += 1
            elephantCurrentActivityTimer -= 1
            if elephantCurrentActivityTimer == 0:
                currentFlow += self.flowRates[elephantGoal]
                if stepIndex < len(steps):
                    elephantPos = elephantGoal
                    elephantGoal = steps[stepIndex]
                    elephantCurrentActivityTimer = self.distances[elephantPos,elephantGoal] + 1
                    stepIndex += 1
        return releasedPressure, stepIndex


    def computeReleasedPressureWithElephantVerbose(self, steps):
        assert len(set(steps)) == len(steps), "steps must not contain duplicates"
        myGoal, elephantGoal = steps[0], steps[1]
        myCurrentActivityTimer = self.distances[0,myGoal] + 1
        elephantCurrentActivityTimer = self.distances[0,elephantGoal] + 1
        timeLeft = 26
        currentFlow = 0
        releasedPressure = 0
        stepIndex = 2
        for timeStep in range(timeLeft):
            print("Time =", timeStep)
            releasedPressure += currentFlow
            print("  Released pressure:", releasedPressure)

            myCurrentActivityTimer -= 1
            if myCurrentActivityTimer > 0:
                print("  On my way to open valve {} (remaining: {})".format(self.names[myGoal], myCurrentActivityTimer))
            if myCurrentActivityTimer == 0:
                currentFlow += self.flowRates[myGoal]
                print("  I finished opening valve {}, increasing the flow to {}".format(self.names[myGoal], currentFlow))
                if stepIndex < len(steps):
                    myPos = myGoal
                    myGoal = steps[stepIndex]
                    myCurrentActivityTimer = self.distances[myPos,myGoal] + 1
                    print("  Now on my way to open valve {} (remaining: {})".format(self.names[myGoal], myCurrentActivityTimer))
                    stepIndex += 1
                else:
                    print("Nothing left for me to do.")

            elephantCurrentActivityTimer -= 1
            if elephantCurrentActivityTimer > 0:
                print("  Elephant on its way to open valve {} (remaining: {})".format(self.names[elephantGoal], elephantCurrentActivityTimer))
            if elephantCurrentActivityTimer == 0:
                currentFlow += self.flowRates[elephantGoal]
                print("  Elephant finished opening valve {}, increasing the flow to {}".format(self.names[elephantGoal], currentFlow))
                if stepIndex < len(steps):
                    elephantPos = elephantGoal
                    elephantGoal = steps[stepIndex]
                    elephantCurrentActivityTimer = self.distances[elephantPos,elephantGoal] + 1
                    print("  Now on its way to open valve {} (remaining: {})".format(self.names[elephantGoal], elephantCurrentActivityTimer))
                    stepIndex += 1
                else:
                    print("Nothing left for elephant to do.")

        return releasedPressure, stepIndex


    def findMaximalPressureWithElephantOld(self):
        best = 0
        bestSeq = []
        n = self.flowRates.shape[0]
        for seq in permutations(range(1, n), min(n - 1, 8)):
            pressure, usedSteps = self.computeReleasedPressureWithElephant(seq)
            if pressure > best:
                best, bestSeq = pressure, seq[:usedSteps]
                print("Max so far:", pressure, " ".join([self.names[i] for i in bestSeq]))
        self.computeReleasedPressureWithElephantVerbose(bestSeq)
        return best


    def findMaximalPressureWithElephant(self):
        bestOverall = 0
        nmin = 0 if self.flowRates[0] != 0 else 1
        nmax = self.flowRates.shape[0]
        rmax = nmax - nmin - 1
        numCombinations = int(sum(factorial(nmax - nmin) / factorial(r) / factorial(nmax - nmin - r) for r in range(1, rmax)))
        count = 0
        for r in range(1, rmax):
          count += 1
          print("{}/{}".format(count, numCombinations))
          for myGoals in combinations(range(nmin, nmax), r):
            myBest = 0
            skip = (0, -1)
            for seq in permutations(myGoals):
                if seq[skip[0]] == skip[1]:
                    continue
                pressure, usedSteps = self.computeReleasedPressure(seq, 26)
                # if only part of the sequence is used, skip following permutations
                # until there is a change that affects the used part of the sequence
                skip = (usedSteps - 1, seq[usedSteps-1])
                if pressure > myBest:
                    myBest, myBestSeq = pressure, seq[:usedSteps]
            elephantGoals = [goal for goal in range(nmin, nmax) if not goal in myBestSeq]
            elephantBest = 0
            skip = (0, -1)
            for seq in permutations(elephantGoals, 4):
                if seq[skip[0]] == skip[1]:
                    continue
                pressure, usedSteps = self.computeReleasedPressure(seq, 26)
                skip = (usedSteps - 1, seq[usedSteps - 1])
                if pressure > elephantBest:
                    elephantBest, elephantBestSeq = pressure, seq[:usedSteps]
            if myBest + elephantBest > bestOverall:
                bestOverall = myBest + elephantBest
                bestOverallSeqs = (myBestSeq, elephantBestSeq)
                print("Max so far:", bestOverall,
                " ".join([self.names[i] for i in myBestSeq]), "--",
                " ".join([self.names[i] for i in elephantBestSeq]))
        print("My moves:")
        self.computeReleasedPressureVerbose(bestOverallSeqs[0], 26)
        print("Elephant moves:")
        self.computeReleasedPressureVerbose(bestOverallSeqs[1], 26)
        return bestOverall


if __name__ == "__main__":
    cave = Cave()
#    print("Part 1:", cave.findMaximalPressure())
    print("Part 2:", cave.findMaximalPressureWithElephant())

# Max so far: 1720 CA JF LE FP YH UX AR DM
