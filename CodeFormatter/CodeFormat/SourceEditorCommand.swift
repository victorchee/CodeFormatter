//
//  SourceEditorCommand.swift
//  CodeFormat
//
//  Created by Migu on 2017/8/4.
//  Copyright © 2017年 VIctorChee. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        format(invocation)
        
        completionHandler(nil)
    }
    
    private func format(_ invocation: XCSourceEditorCommandInvocation) {
        guard invocation.buffer.lines.count != 0 else {
            return
        }
        
        let formatter = Formatter(invocation)
        formatter.checkBeforeFirstImportHasOnlyOneEmptyLine()
    }
}
