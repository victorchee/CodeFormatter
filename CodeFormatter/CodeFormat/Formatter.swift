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
                        removeCodeLines(in: lines.index(after: startIndex)..<lines.index(after: endIndex)) // 由于是向前查找的，这里的index需要调整，都+1
                    }
                } else {
                    // 前一行不是空行，插入一个空行
                    insertCodeLine("\n", at: index)
                }
                
                break
            }
        }
    }
    
    /// 检测最后一个import之后仅保留一个空行
    func checkAfterLastImportHasOnlyOneEmptyLine() {
        for index in 0 ..< lines.count {
            let line = lines[index]
            let nextLine = lines[lines.index(after: index)]
            if (line.contains("#import") || line.contains("@import")) && !(nextLine.contains("#import") || nextLine.contains("@import")) { // 最后一个import行
                if nextLine == "\n" {
                    // 后一行是空行，删除多余空行，保留一行空行
                    var afterAfterIndex = lines.index(index, offsetBy: 2)
                    var afterAfterLine = lines[afterAfterIndex]
                    let startIndex = afterAfterIndex
                    var endIndex = afterAfterIndex
                    while afterAfterLine == "\n" {
                        afterAfterIndex = lines.index(after: afterAfterIndex)
                        afterAfterLine = lines[afterAfterIndex]
                        endIndex = afterAfterIndex
                    }
                    if endIndex > startIndex {
                        removeCodeLines(in: startIndex..<endIndex)
                    }
                } else {
                    // 后一行不是空行，插入一个空行
                    insertCodeLine("\n", at: lines.index(after: index))
                }
                break
            }
        }
    }
    
    /// 检测@Interface之前仅保留一个空行
    func checkBeforeInterfaceHasOnlyOneEmptyLine() {
        for index in 0 ..< lines.count {
            let line = lines[index]
            if line.hasPrefix("@interface") { // @interface行
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
                        removeCodeLines(in: lines.index(after: startIndex)..<lines.index(after: endIndex)) // 由于是向前查找的，这里的index需要调整，都+1
                    }
                } else {
                    // 前一行不是空行，插入一个空行
                    insertCodeLine("\n", at: index)
                }
            }
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
