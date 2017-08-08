//
//  Formatter.swift
//  CodeFormatter
//
//  Created by Victor Chee on 2017/8/6.
//  Copyright © 2017年 VIctorChee. All rights reserved.
//

import Foundation
import XcodeKit

class Formatter {
    var invocation: XCSourceEditorCommandInvocation
    private var lines = [String]()
    
    init(_ invocation: XCSourceEditorCommandInvocation) {
        self.invocation = invocation
        
        if let bufferLines = invocation.buffer.lines as? [String] {
            lines = bufferLines
        }
    }
    
    /// 检测第一个import之前仅保留一个空行
    func checkBeforeFirstImportHasOnlyOneEmptyLine() {
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line.contains("#import") || line.contains("@import") { // 第一个import行
                let beforeIndex = lines.index(before: index)
                if beforeIndex < 0 {
                    // 没有前一行了，插入一个空行
                    // 由于只添加一次，在循环内添加没有问题
                    insertCodeLine("\n", at: index)
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
                            // 由于只删除一次，在循环内删除没有问题
                            removeCodeLines(in: lines.index(after: startIndex)..<lines.index(after: endIndex)) // 由于是向前查找的，这里的index需要调整，都+1
                        }
                    } else {
                        // 前一行不是空行，插入一个空行
                        // 由于只添加一次，在循环内添加没有问题
                        insertCodeLine("\n", at: index)
                    }
                }
                
                break
            }
        }
    }
    
    /// 检测最后一个import之后仅保留一个空行
    func checkAfterLastImportHasOnlyOneEmptyLine() {
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
                        // 由于只删除一次，在循环内删除没有问题
                        removeCodeLines(in: startIndex..<endIndex)
                    }
                } else {
                    // 后一行不是空行，插入一个空行
                    // 由于只添加一次，在循环内添加没有问题
                    insertCodeLine("\n", at: lines.index(after: index))
                }
                break
            }
        }
    }
    
    /// 检测@Interface之前仅保留一个空行
    func checkBeforeInterfaceHasOnlyOneEmptyLine() {
        var deleteRanges = [Range<Int>]()
        var insertIndexes = [Int]()
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line.hasPrefix("@interface") { // @interface行
                let beforeIndex = lines.index(before: index)
                if beforeIndex < 0 {
                    // 没有前一行了，插入一个空行
                    // 由于只添加一次，在循环内添加没有问题
                    insertCodeLine("\n", at: index)
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
                            deleteRanges.append(lines.index(after: startIndex)..<lines.index(after: endIndex)) // 由于是向前查找的，这里的index需要调整，都+1
                        }
                    } else {
                        // 前一行不是空行，插入一个空行
                        insertIndexes.append(index)
                    }
                }
            }
        }
        // 删除
        var bound = 0
        for range in deleteRanges {
            removeCodeLines(in: (range.lowerBound - bound)..<(range.upperBound - bound))
            bound += range.upperBound - range.lowerBound // 调整Range
        }
        // 插入
        bound = -bound
        for index in insertIndexes {
            insertCodeLine("\n", at: index + bound)
            bound += 1
        }
    }
    
    /// 检测@end之后仅保留一个空行（Xcode的最后一行空行，实际在lines里面并没有，导致最后一个@end之后有两个空行）
    func checkAfterEndHasOnlyOneEmptyLine() {
        var deleteRanges = [Range<Int>]()
        var insertIndexes = [Int]()
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line == "@end\n" { // @end行
                let afterIndex = lines.index(after: index)
                if afterIndex >= lines.count {
                    // 没有后一行了，插入一个空行
                    insertIndexes.append(index + 1)
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
                            deleteRanges.append(startIndex..<endIndex)
                        }
                    } else {
                        // 后一行不是空行，插入一个空行
                        insertIndexes.append(lines.index(after: index))
                    }
                }
            }
        }
        // 删除
        var bound = 0
        for range in deleteRanges {
            removeCodeLines(in: (range.lowerBound - bound)..<(range.upperBound - bound))
            bound += range.upperBound - range.lowerBound // 调整Range
        }
        // 插入
        bound = -bound
        for index in insertIndexes {
            insertCodeLine("\n", at: index + bound)
            bound += 1
        }
    }
    
    private func insertCodeLine(_ line: String, at index: Int) {
        lines.insert(line, at: index)
        invocation.buffer.lines.insert(line, at: index)
    }
    
    private func removeCodeLine(at index: Int) {
        lines.remove(at: index)
        invocation.buffer.lines.removeObject(at: index)
    }
    
    private func removeCodeLines(in range: Range<Int>) {
        lines.removeSubrange(range)
        invocation.buffer.lines.removeObjects(in: NSRange(range))
    }
}
