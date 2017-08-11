//
//  CodeFormatterTests.swift
//  CodeFormatterTests
//
//  Created by Migu on 2017/8/8.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

import XCTest

class CodeFormatterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func assert(input: [String], checker: (([String]) -> [Result]), output: [String]) {
        var lines = input
        let results = checker(lines)
        
        func handleCheckerResults(_ results: [Result]) {
            // TODO: - 这边的索引修正只有[Result]是有序的时候才有用，否则会修正失败
            var bound = 0
            for result in results {
                switch result {
                case .deleteLine(let index):
                    lines.remove(at: index + bound)
                    bound -= 1
                case .deleteLines(let range):
                    lines.removeSubrange((range.lowerBound + bound)..<(range.upperBound + bound))
                    bound -= range.upperBound - range.lowerBound
                case .editLine(let line, let index):
                    lines[index] = line
                case .insertLine(let line, let index):
                    lines.insert(line, at: index + bound)
                    bound += 1
                }
            }
        }
        
        handleCheckerResults(results)
        XCTAssertEqual(lines, output)
    }
    
    func testCheckBeforeFirstImportHasOnlyOneEmptyLineFromOnlyEmptyLines() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let inputs = [
            ["@import UIKit", "\n"],
            ["\n", "@import UIKit", "\n"],
            ["\n", "\n", "@import UIKit", "\n"],
            ["\n", "\n", "\n", "@import UIKit", "\n"],
            ["\n", "\n", "\n", "\n", "@import UIKit", "\n"],
        ]
        let output = ["\n", "@impot UIKit", "\n"]
        for input in inputs {
            assert(input: input, checker: Checker().checkBeforeFirstImportHasOnlyOneEmptyLine(_:), output: output)
        }
    }
    
    func testCheckBeforeFirstImportHasOnlyOneEmptyLineFromNoImportLines() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let input = ["\n", "\n", "\n", "@interface UIKit", "\n"]
        let output = ["\n", "\n", "\n", "@interface UIKit", "\n"]
        assert(input: input, checker: Checker().checkBeforeFirstImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckBeforeFirstImportHasOnlyOneEmptyLineFromMulipuleImportLines() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let input = ["\n", "\n", "\n", "@import UIKit", "\n", "\n", "@import UIKit",]
        let output = ["\n", "@import UIKit", "\n", "\n", "@import UIKit",]
        assert(input: input, checker: Checker().checkBeforeFirstImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckBeforeFirstImportHasOnlyOneEmptyLinePerformance() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let input = ["//\n",
                     "//  AppDelegate.m\n",
                     "//  FormatTestProject\n",
                     "//\n",
                     "//  Created by Migu on 2017/8/4.\n",
                     "//  Copyright © 2017年 VIctorChee. All rights reserved.\n",
                     "\n",
                     "\n",
                     "\n",
                     "\n",
                     "\n",
                     "@import UIKit;\n",
                     "#import \"AppDelegate.h\"\n",
                     "\n",
                     "@interface AppDelegate ()\n",
                     "@end\n",
                     "\n",
                     "@implementation AppDelegate\n",
                     "\n",
                     "- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {\n",
                     "// Override point for customization after application launch.\n",
                     "return YES;\n",
                     "}]\n",
                     "@end\n",
                     ]
        let output = ["//\n",
                      "//  AppDelegate.m\n",
                      "//  FormatTestProject\n",
                      "//\n",
                      "//  Created by Migu on 2017/8/4.\n",
                      "//  Copyright © 2017年 VIctorChee. All rights reserved.\n",
                      "\n",
                      "@import UIKit;\n",
                      "#import \"AppDelegate.h\"\n",
                      "\n",
                      "@interface AppDelegate ()\n",
                      "@end\n",
                      "\n",
                      "@implementation AppDelegate\n",
                      "\n",
                      "- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {\n",
                      "// Override point for customization after application launch.\n",
                      "return YES;\n",
                      "}]\n",
                      "@end\n",
                      ]
        assert(input: input, checker: Checker().checkBeforeFirstImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
}
