//
//  SourceEditorCommand.swift
//  CodeFormat
//
//  Created by Victor Chee on 2017/8/6.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        print("Source Editor Command")
        format(invocation)
        
        completionHandler(nil)
    }
    
    private func format(_ invocation: XCSourceEditorCommandInvocation) {
        guard invocation.buffer.lines.count != 0 else {
            return
        }
        
        let formatter = Formatter(invocation)
        formatter.checkBeforeFirstImportHasOnlyOneEmptyLine()
        formatter.checkAfterLastImportHasOnlyOneEmptyLine()
        formatter.checkBeforeInterfaceHasOnlyOneEmptyLine()
    }
    
}
