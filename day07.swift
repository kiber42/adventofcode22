import Foundation

class Directory
{
    let name : String
    let parent : Directory?
    let path : String

    var files : [String : Int] = [:]
    var subdirectories : [Directory] = []
    var fileSize = 0

    private init(_ name : String, _ parent: Directory?) {
        self.name = name
        self.parent = parent
        if let parent {
            self.path = parent.path + name + "/"
        }
        else {
            self.path = "/"
        }
    }

    static func makeRoot() -> Directory {
        return Directory("", nil)
    }

    func cd(dirName: String) -> Directory {
        if let existing = self.subdirectories.filter({$0.name == dirName}).first {
            return existing
        }
        self.subdirectories.append(Directory(dirName, self))
        return self.subdirectories.last!
    }

    func addItem(size: Int) {
        self.fileSize += size
    }

    func getTotalSize() -> Int {
        return self.subdirectories.map({$0.getTotalSize()}).reduce(self.fileSize, +)
    }

    func getAllDirs() -> [Directory] {
        return self.subdirectories.map({$0.getAllDirs()}).reduce(self.subdirectories, +)
    }
}

struct DirectoryParser
{
    let root = Directory.makeRoot()
    var pwd : Directory

    init() {
        self.pwd = self.root
    }

    mutating func cd(dirName : String) {
        if dirName == "/" {
            self.pwd = self.root
        }
        else if dirName == ".." {
            self.pwd = self.pwd.parent!
        }
        else {
            self.pwd = self.pwd.cd(dirName: dirName)
        }
    }

    func addItem(size: Int) {
        self.pwd.addItem(size: size)
    }

    func getAllDirs() -> [Directory] {
        return self.root.getAllDirs()
    }
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "example07.txt"
do
{
    var parser = DirectoryParser();
    let lines = try String(contentsOfFile: filename).split(separator: "\n")
    for line in lines {
        if line.starts(with: "$ cd") {
            parser.cd(dirName: String(line.split(separator: " ").last!))
        } else if !line.starts(with: "$") && !line.starts(with: "dir") {
            // Must be parsing a file entry in the output of an "ls" command
            parser.addItem(size: Int(line.prefix(upTo: line.firstIndex(of: " ")!))!)
        }
    }

    // Find combined size of all directories with a total size of at most 100000
    let allDirSizes = parser.getAllDirs().map({$0.getTotalSize()})
    let result1 = allDirSizes.filter({$0 <= 100000}).reduce(0, +)
    print("Part 1: \(result1)")

    // From all sufficiently large directories, pick the smallest one
    let maxAllowedSize = 70000000 - 30000000
    let bytesToDelete = parser.root.getTotalSize() - maxAllowedSize
    let result2 = allDirSizes.filter({$0 >= bytesToDelete}).min()!
    print("Part 2: \(result2)")
} catch {
    print("Could not load input from '\(filename)'.")
}
