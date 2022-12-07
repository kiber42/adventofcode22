import sys

def loadInput():
    filename = sys.argv[1] if len(sys.argv) >= 2 else "input07.txt"
    return open(filename).read().strip().split("\n")


def processLog(lines):
    pwd = [""]
    files = {}
    dirs = []
    while len(lines) > 0:
        line = lines.pop(0)
        if line.startswith("$ cd"):
            arg = line.split()[2]
            if arg == "/":
                pwd = [""]
            elif arg == "..":
                pwd.pop()
            else:
                pwd.append(arg)
        elif line.startswith("$ ls"):
            dir = "/".join(pwd) + "/"
            files.update(processDir(lines, dir))
            dirs.append(dir)
    return files.items(), dirs


def processDir(lines, prefix):
    files = {}
    while len(lines) > 0 and lines[0][0] != "$":
        entry = lines.pop(0)
        tokens = entry.split()
        if tokens[0] != "dir":
            files[prefix + tokens[1]] = int(tokens[0])
    return files


def directoryInfo(filedata, dirnames):
    return dict((dir, sum(size if path.startswith(dir) else 0 for path, size in filedata)) for dir in dirnames)


def findSizeA(dirsizes):
    return sum(dirsize if dirsize <= 100000 else 0 for dirsize in dirsizes)


def findSizeB(dirinfo):
    usedSpace = dirinfo["/"]
    unusedSpace = 70000000 - usedSpace
    minCleanupSize = 30000000 - unusedSpace
    return min(size for size in dirinfo.values() if size >= minCleanupSize)


if __name__ == "__main__":
    dirInfo = directoryInfo(*processLog(loadInput()))
    print("Part 1:", findSizeA(dirInfo.values()))
    print("Part 2:", findSizeB(dirInfo))
