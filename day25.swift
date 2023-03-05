import Foundation

func snafuToDecimal(snafu: String) -> Int {
    let lookup = [
        Character("2") : +2,
        Character("1") : +1,
        Character("0") : +0,
        Character("-") : -1,
        Character("=") : -2,
    ]
    var decimal = 0
    for char in snafu {
        decimal *= 5
        decimal += lookup[char]!
    }
    return decimal
}

func decimalToSnafu(decimal: Int) -> String {
    if decimal == 0 {
        return "0"
    }
    let lookup = [
        +2 : "2",
        +1 : "1",
        +0 : "0",
        -1 : "-",
        -2 : "=",
    ]
    var snafu = ""
    var remainder = decimal
    while remainder > 0 {
        let value = (remainder + 2) % 5 - 2
        snafu += lookup[value]!
        remainder -= value
        remainder /= 5    
    }
    return String(snafu.reversed())
}

let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "input25.txt"
if let data = try? String(contentsOfFile: path)
{
    var sum = 0
    for line in data.split(separator: "\n") {
        sum += snafuToDecimal(snafu: String(line))
    }
    print(sum, decimalToSnafu(decimal: sum))
}
else
{
    print("Could not open file '\(path)'.")
}