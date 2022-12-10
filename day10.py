import sys

class CPU:
    def __init__(self):
        filename = sys.argv[1] if len(sys.argv) >= 2 else "input10.txt"
        self.commands = open(filename).readlines()
        self.reset()


    def reset(self):
        self.X = 1
        self.cycle = 0
        self.ip = 0


    def processCommand(self, command):        
        score = 0
        output = "#" if abs(self.X - (self.cycle % 40)) <= 1 else "."
        self.cycle += 1
        if (self.cycle - 20) % 40 == 0:
            score = self.X * self.cycle
        if command.startswith("addx"):
            output += "#" if abs(self.X - (self.cycle % 40)) <= 1 else "."
            self.cycle += 1
            if (self.cycle - 20) % 40 == 0:
                score = self.X * self.cycle
            self.X += int(command.split()[1])        
        return score, output


    def runProgram(self):
        self.reset()
        return sum(self.processCommand(cmd)[0] for cmd in self.commands)


    def renderOutput(self):
        self.reset()
        output = "".join(self.processCommand(cmd)[1] for cmd in self.commands)
        return "\n".join(output[pos:pos + 40] for pos in range(0, 240, 40))


if __name__ == "__main__":
    cpu = CPU()
    print("Part 1:", cpu.runProgram())
    print("Part 2:\n" + cpu.renderOutput())
