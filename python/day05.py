import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input05.txt"
    data = open(filename).read()
    lines = [block.split("\n") for block in data.split("\n\n")]
    return parseStack(lines[0]), parseStack(lines[0]), parseCommands(lines[1])


def parseStack(lines):
    numStacks = len(lines[-1].split())
    stacks = [[] for _ in range(numStacks)]
    for line in reversed(lines[:-1]):
        for i, stack in enumerate(stacks):
            if len(line) > i * 4 and line [i * 4] == '[':
                stack.append(line[i * 4 + 1])
    return stacks


def parseCommands(lines):
    commands = []
    for line in lines:
        if not line:
            break
        tokens = line.split()
        commands.append(tuple(int(tokens[i]) for i in [1, 3, 5]))
    return commands
    
if __name__ == "__main__":
    stacks9000, stacks9001, commands = loadInput()
    for n, origin, destination in commands:
        stacks9000[destination - 1].extend(reversed(stacks9000[origin - 1][-n:]))
        stacks9001[destination - 1].extend(stacks9001[origin - 1][-n:])
        stacks9000[origin - 1] = stacks9000[origin - 1][:-n]
        stacks9001[origin - 1] = stacks9001[origin - 1][:-n]
    print("Part 1:", "".join([stack[-1] if stack else ' ' for stack in stacks9000]))
    print("Part 2:", "".join([stack[-1] if stack else ' ' for stack in stacks9001]))
