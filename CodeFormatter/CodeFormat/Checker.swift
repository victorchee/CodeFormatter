//
//  Checker.swift
//  CodeFormatter
//
//  Created by Migu on 2017/8/10.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

import Foundation

enum Result {
    case insertLine(line: String, index: Int)
    case deleteLine(index: Int)
    case deleteLines(range: Range<Int>)
    case editLine(line: String, index: Int)
}

class Checker {
    /// 检测第一个import之前仅保留一个空行
    func checkBeforeFirstImportHasOnlyOneEmptyLine(_ lines: [String]) -> [Result] {
        var results = [Result]()
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line.contains("#import") || line.contains("@import") { // 第一个import行
                let beforeIndex = lines.index(before: index)
                if beforeIndex < 0 {
                    // 没有前一行了，插入一个空行
                    results.append(Result.insertLine(line: "\n", index: index))
                } else {
                    let beforeLine = lines[beforeIndex]
                    if beforeLine == "\n" {
                        // 前一行是空行，删除多余空行，保留一行空行
                        var beforeBeforeIndex = lines.index(index, offsetBy: -2)
                        if beforeBeforeIndex < 0 {
                            break
                        }
                        var beforeBeforeLine = lines[beforeBeforeIndex]
                        let endIndex = beforeBeforeIndex
                        var startIndex = beforeBeforeIndex
                        while beforeBeforeLine == "\n" {
                            beforeBeforeIndex = lines.index(before: beforeBeforeIndex)
                            if beforeBeforeIndex < 0 {
                                break
                            }
                            beforeBeforeLine = lines[beforeBeforeIndex]
                            startIndex = beforeBeforeIndex
                        }
                        if endIndex >= startIndex {
                            results.append(Result.deleteLines(range: lines.index(after: startIndex)..<lines.index(after: endIndex))) // 由于是向前查找的，这里的index需要调整，都+1
                        }
                    } else {
                        // 前一行不是空行，插入一个空行
                        results.append(Result.insertLine(line: "\n", index: index))
                    }
                }
                
                break
            }
        }
        return results
    }
    
    /// 检测最后一个import之后仅保留一个空行
    func checkAfterLastImportHasOnlyOneEmptyLine(_ lines: [String]) -> [Result] {
        var results = [Result]()
        for index in 0 ..< lines.count {
            let line = lines[index]
            let afterIndex = lines.index(after: index)
            guard afterIndex < lines.count else {
                break
            }
            let afterLine = lines[afterIndex]
            if (line.contains("#import") || line.contains("@import")) && !(afterLine.contains("#import") || afterLine.contains("@import")) { // 最后一个import行
                if afterLine == "\n" {
                    // 后一行是空行，删除多余空行，保留一行空行
                    var afterAfterIndex = lines.index(index, offsetBy: 2)
                    guard afterAfterIndex < lines.count else {
                        break
                    }
                    var afterAfterLine = lines[afterAfterIndex]
                    let startIndex = afterAfterIndex
                    var endIndex = afterAfterIndex
                    while afterAfterLine == "\n" {
                        afterAfterIndex = lines.index(after: afterAfterIndex)
                        guard afterAfterIndex < lines.count else {
                            break
                        }
                        afterAfterLine = lines[afterAfterIndex]
                        endIndex = afterAfterIndex
                    }
                    if endIndex > startIndex {
                        results.append(Result.deleteLines(range: startIndex..<endIndex))
                    }
                } else {
                    // 后一行不是空行，插入一个空行
                    results.append(Result.insertLine(line: "\n", index: lines.index(after: index)))
                }
                break
            }
        }
        return results
    }
    
    /// 检测@Interface之前仅保留一个空行
    func checkBeforeInterfaceHasOnlyOneEmptyLine(_ lines: [String]) -> [Result] {
        var results = [Result]()
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line.hasPrefix("@interface") { // @interface行
                let beforeIndex = lines.index(before: index)
                if beforeIndex < 0 {
                    // 没有前一行了，插入一个空行
                    results.append(Result.insertLine(line: "\n", index: index))
                } else {
                    let beforeLine = lines[beforeIndex]
                    if beforeLine == "\n" {
                        // 前一行是空行，删除多余空行，保留一行空行
                        var beforeBeforeIndex = lines.index(index, offsetBy: -2)
                        if beforeBeforeIndex < 0 {
                            break
                        }
                        var beforeBeforeLine = lines[beforeBeforeIndex]
                        let endIndex = beforeBeforeIndex
                        var startIndex = beforeBeforeIndex
                        while beforeBeforeLine == "\n" {
                            beforeBeforeIndex = lines.index(before: beforeBeforeIndex)
                            if beforeBeforeIndex < 0 {
                                break
                            }
                            beforeBeforeLine = lines[beforeBeforeIndex]
                            startIndex = beforeBeforeIndex
                        }
                        if endIndex > startIndex {
                            results.append(Result.deleteLines(range: lines.index(after: startIndex)..<lines.index(after: endIndex))) // 由于是向前查找的，这里的index需要调整，都+1
                        }
                    } else {
                        // 前一行不是空行，插入一个空行
                        results.append(Result.insertLine(line: "\n", index: index))
                    }
                }
            }
        }
        return results
    }
    
    /// 检测@end之后仅保留一个空行（Xcode的最后一行空行，实际在lines里面并没有，导致最后一个@end之后有两个空行）
    func checkAfterEndHasOnlyOneEmptyLine(_ lines: [String]) -> [Result] {
        var results = [Result]()
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line == "@end\n" { // @end行
                let afterIndex = lines.index(after: index)
                if afterIndex >= lines.count {
                    // 没有后一行了，插入一个空行
                    results.append(Result.insertLine(line: "\n", index: lines.index(after: index)))
                } else {
                    let afterLine = lines[afterIndex]
                    if afterLine == "\n" {
                        // 后一行是空行，删除多余空行，保留一行空行
                        var afterAfterIndex = lines.index(after: afterIndex)
                        guard afterAfterIndex < lines.count else {
                            break
                        }
                        var afterAfterLine = lines[afterAfterIndex]
                        var endIndex = afterAfterIndex
                        let startIndex = afterAfterIndex
                        while afterAfterLine == "\n" {
                            afterAfterIndex = lines.index(after: afterAfterIndex)
                            endIndex = afterAfterIndex
                            guard afterAfterIndex < lines.count else {
                                break
                            }
                            afterAfterLine = lines[afterAfterIndex]
                        }
                        if endIndex > startIndex {
                            results.append(Result.deleteLines(range: startIndex..<endIndex))
                        }
                    } else {
                        // 后一行不是空行，插入一个空行
                        results.append(Result.insertLine(line: "\n", index: lines.index(after: index)))
                    }
                }
            }
        }
        return results
    }
}
