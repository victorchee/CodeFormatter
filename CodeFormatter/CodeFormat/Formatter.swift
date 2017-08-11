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
    
    init(_ invocation: XCSourceEditorCommandInvocation) {
        self.invocation = invocation
    }
    
    func format() {
        guard let lines = invocation.buffer.lines as? [String]  else { return }
        let checker = Checker()
        let results = checker.checkBeforeFirstImportHasOnlyOneEmptyLine(lines)
        handleCheckerResults(results)
    }
    
    private func handleCheckerResults(_ results: [Result]) {
        // TODO: - 这边的索引修正只有[Result]是有序的时候才有用，否则会修正失败
        var bound = 0
        for result in results {
            switch result {
            case .deleteLine(let index):
                invocation.buffer.lines.removeObject(at: index + bound)
                bound -= 1
            case .deleteLines(let range):
                let length = range.upperBound - range.lowerBound
                invocation.buffer.lines.removeObjects(in: NSRange(location: range.lowerBound + bound, length: length))
                bound -= length
            case .editLine(let line, let index):
                invocation.buffer.lines[index] = line
            case .insertLine(let line, let index):
                invocation.buffer.lines.insert(line, at: index + bound)
                bound += 1
            }
        }
    }
}
