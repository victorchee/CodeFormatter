//
//  Formatter.swift
//  CodeFormatter
//
//  Created by Migu on 2017/8/4.
//  Copyright © 2017年 VIctorChee. All rights reserved.
//

import Foundation
import XcodeKit

class Formatter {
    private var codeLines = [String]()
    
    var invocation: XCSourceEditorCommandInvocation {
        didSet {
            if let lines = invocation.buffer.lines as? [String] {
                codeLines = lines
            }
        }
    }
    
    init(_ invocation: XCSourceEditorCommandInvocation) {
        self.invocation = invocation
    }
    
    /// 检测第一个#import之前要仅保留一行空格
    func checkBeforeFirstImportHasOnlyOneEmptyLine() {
        for index in 0 ..< codeLines.count {
            let line = codeLines[index]
            if line.contains("#import") {
                let beforeLine = codeLines[codeLines.index(before: index)]
                if beforeLine == "\n" {
                    var beforeBeforeIndex = index - 2
                    if beforeBeforeIndex == 1 { break }
                    var beforeBeforeLine = codeLines[beforeBeforeIndex]
                    while beforeBeforeLine == "\n" {
                        removeCodeLine(at: beforeBeforeIndex)
                        beforeBeforeIndex -= 1
                        beforeBeforeLine = codeLines[beforeBeforeIndex]
                    }
                } else {
                    insertCodeLine("\n", at: index)
                }
                
                break
            }
        }
    }
    
    private func insertCodeLine(_ line: String, at index: Int) {
        codeLines.insert(line, at: index)
        invocation.buffer.lines.insert(line, at: index)
    }
    
    private func removeCodeLine(at index: Int) {
        codeLines.remove(at: index)
        invocation.buffer.lines.removeObject(at: index)
    }
}
