//: Playground - noun: a place where people can play

import Cocoa

var lines = [
                "a",
                "b",
                "\n",
                "\n",
                "\n",
                "@import",
                "@import",
                "\n",
                "\n",
                "\n"
            ]

func checkBeforeImportHasOnlyOneEmptyLine() {
    var deleteRanges = [Range<Int>]()
    var insertIndexes = [Int]()
    for index in 0 ..< lines.count {
        let line = lines[index]
        if line.contains("#import") || line.contains("@import") { // 第一个import行
            let beforeLine = lines[lines.index(before: index)]
            if beforeLine == "\n" {
                // 前一行是空行，删除多余空行，保留一行空行
                var beforeBeforeIndex = lines.index(index, offsetBy: -2)
                var beforeBeforeLine = lines[beforeBeforeIndex]
                let endIndex = beforeBeforeIndex
                var startIndex = beforeBeforeIndex
                while beforeBeforeLine == "\n" {
                    beforeBeforeIndex = lines.index(before: beforeBeforeIndex)
                    beforeBeforeLine = lines[beforeBeforeIndex]
                    startIndex = beforeBeforeIndex
                }
                if endIndex > startIndex {
                    deleteRanges.append(lines.index(after: startIndex)..<lines.index(after: endIndex))
                    // 由于是向前查找的，这里的index需要调整，都+1
                }
            } else {
                // 前一行不是空行，插入一个空行
                insertIndexes.append(index)
            }
        }
    }
    var bound = 0
    for range in deleteRanges {
        lines.removeSubrange((range.lowerBound - bound)..<(range.upperBound - bound))
        bound += range.upperBound - range.lowerBound // 调整Range
    }
    bound = -bound
    for index in insertIndexes {
        lines.insert("\n", at: index + bound)
        bound += 1
    }
}

checkBeforeImportHasOnlyOneEmptyLine()
lines
