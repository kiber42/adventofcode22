import sys

class Monkey:
    RelaxFactor = 3
    CombinedTestFactor = 1

    def __init__(self, description):
        self.items = [int(x.strip(",")) for x in description[1].split()[2:]]
        self.operation = parseOperation(description[2].split()[3:])
        self.divisionTest = int(description[3].split()[-1])
        self.targetTrue = int(description[4].split()[-1])
        self.targetFalse = int(description[5].split()[-1])
        self.numInspections = 0
        Monkey.CombinedTestFactor *= self.divisionTest


    def inspect(self, worryLevel):
        worryLevel = self.operation(worryLevel) // Monkey.RelaxFactor
        worryLevel %= Monkey.CombinedTestFactor
        test = worryLevel % self.divisionTest == 0
        target = self.targetTrue if test else self.targetFalse
        return worryLevel, target


    def doTurn(self):
        throws = []
        for item in self.items:
            throws.append(self.inspect(item))
        self.numInspections += len(self.items)
        self.items = []
        return throws


def parseOperation(op):
    if op[0] == "old":
        if op[2] == "old":
            assert(op[1] == "*")
            return lambda old: old * old
        operand = int(op[2])
        if op[1] == "+":
            return lambda old: old + operand
        if op[1] == "*":
            return lambda old: old * operand
    raise "Unknow operation: " + " ".join(op)   


def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input11.txt"
    return [Monkey(description.split("\n")) for description in open(filename).read().split("\n\n")]


def runRound(monkeys):
    for monkey in monkeys:
        throws = monkey.doTurn()
        for item, target in throws:
            monkeys[target].items.append(item)


def runGame(monkeys, rounds):
    for _ in range(rounds):
        runRound(monkeys)
    inspections = sorted(m.numInspections for m in monkeys)
    return inspections[-2] * inspections[-1]


if __name__ == "__main__":
    monkeys = loadInput()
    Monkey.RelaxFactor = 3
    print("Part 1:", runGame(monkeys, 20))
    monkeys = loadInput()
    Monkey.RelaxFactor = 1
    print("Part 2:", runGame(monkeys, 10000))
