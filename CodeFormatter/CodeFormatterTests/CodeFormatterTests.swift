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
    
    // MARK: - checkBeforeFirstImportHasOnlyOneEmptyLine
    func testCheckBeforeFirstImportHasOnlyOneEmptyLineFromOnlyEmptyLines() {
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
        let input = ["\n", "\n", "\n", "@interface UIKit", "\n"]
        let output = ["\n", "\n", "\n", "@interface UIKit", "\n"]
        assert(input: input, checker: Checker().checkBeforeFirstImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckBeforeFirstImportHasOnlyOneEmptyLineFromMulipuleImportLines() {
        let input = ["\n", "\n", "\n", "@import UIKit", "\n", "\n", "@import UIKit",]
        let output = ["\n", "@import UIKit", "\n", "\n", "@import UIKit",]
        assert(input: input, checker: Checker().checkBeforeFirstImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckBeforeFirstImportHasOnlyOneEmptyLineFromNormalLines() {
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
    
    // MARK: - checkAfterLastImportHasOnlyOneEmptyLine
    func testCheckAfterLastImportHasOnlyOneEmptyLineFromEmptyLines() {
        let inputs = [
            ["\n", "#import UIKit"],
            ["\n", "#import UIKit", "\n"],
            ["\n", "#import UIKit", "\n", "\n"],
            ["\n", "#import UIKit", "\n", "\n", "\n"],
            ["\n", "#import UIKit", "\n", "\n", "\n", "\n"],
            ]
        let output = ["\n", "#impot UIKit", "\n"]
        for input in inputs {
            assert(input: input, checker: Checker().checkAfterLastImportHasOnlyOneEmptyLine(_:), output: output)
        }
    }
    
    func testCheckAfterLastImportHasOnlyOneEmptyLineFromNoImportLines() {
        let input = ["\n", "@interface UIKit", "\n", "\n", "\n"]
        let output = ["\n", "@interface UIKit", "\n", "\n", "\n"]
        assert(input: input, checker: Checker().checkAfterLastImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckAfterLastImportHasOnlyOneEmptyLineFromMulipuleImportLines() {
        let input = ["\n", "\n", "@import UIKit", "\n", "\n", "\n", "@import UIKit", "\n", "\n", "\n"]
        let output = ["\n", "\n", "@import UIKit", "\n", "@import UIKit", "\n"]
        assert(input: input, checker: Checker().checkAfterLastImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckAfterLastImportHasOnlyOneEmptyLineFromNormalLines() {
        let input = ["//\n",
                     "//  AppDelegate.m\n",
                     "//  FormatTestProject\n",
                     "//\n",
                     "//  Created by Migu on 2017/8/4.\n",
                     "//  Copyright © 2017年 VIctorChee. All rights reserved.\n",
                     "\n",
                     "\n",
                     "@import UIKit;\n",
                     "#import \"AppDelegate.h\"\n",
                     "\n",
                     "\n",
                     "\n",
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
        assert(input: input, checker: Checker().checkAfterLastImportHasOnlyOneEmptyLine(_:), output: output)
    }
    
    // MARK: - checkBeforeInterfaceHasOnlyOneEmptyLine
    func testCheckBeforeInterfaceHasOnlyOneEmptyLineFromOnlyEmptyLines() {
        let inputs = [
            ["@interface UIKit", "\n"],
            ["\n", "@interface UIKit", "\n"],
            ["\n", "\n", "@interface UIKit", "\n"],
            ["\n", "\n", "\n", "@interface UIKit", "\n"],
            ["\n", "\n", "\n", "\n", "@interface UIKit", "\n"],
            ]
        let output = ["\n", "@interface UIKit", "\n"]
        for input in inputs {
            assert(input: input, checker: Checker().checkBeforeInterfaceHasOnlyOneEmptyLine(_:), output: output)
        }
    }
    
    func testCheckBeforeInterfaceHasOnlyOneEmptyLineFromNoInterfaceLines() {
        let input = ["\n", "\n", "\n", "@import UIKit", "\n"]
        let output = ["\n", "\n", "\n", "@import UIKit", "\n"]
        assert(input: input, checker: Checker().checkBeforeInterfaceHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckBeforeInterfaceHasOnlyOneEmptyLineFromMulipuleImportLines() {
        let input = ["\n", "\n", "\n", "@interface UIKit", "\n", "\n", "@interface UIKit",]
        let output = ["\n", "@interface UIKit", "\n", "\n", "@interface UIKit",]
        assert(input: input, checker: Checker().checkBeforeInterfaceHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckBeforeInterfaceHasOnlyOneEmptyLineFromNormalLines() {
        let input = ["//\n",
                     "//  AppDelegate.m\n",
                     "//  FormatTestProject\n",
                     "//\n",
                     "//  Created by Migu on 2017/8/4.\n",
                     "//  Copyright © 2017年 VIctorChee. All rights reserved.\n",
                     "\n",
                     "@import UIKit;\n",
                     "#import \"AppDelegate.h\"\n",
                     "\n",
                     "\n",
                     "\n",
                     "\n",
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
        assert(input: input, checker: Checker().checkBeforeInterfaceHasOnlyOneEmptyLine(_:), output: output)
    }
    
    // MARK: - checkAfterEndHasOnlyOneEmptyLine
    func testCheckAfterEndHasOnlyOneEmptyLineFromOnlyEmptyLines() {
        let inputs = [
            ["\n", "@end"],
            ["\n", "@end", "\n"],
            ["\n", "@end", "\n", "\n"],
            ["\n", "@end", "\n", "\n", "\n"],
            ["\n", "@end", "\n", "\n", "\n", "\n"],
            ]
        let output = ["\n", "@end", "\n"]
        for input in inputs {
            assert(input: input, checker: Checker().checkAfterEndHasOnlyOneEmptyLine(_:), output: output)
        }
    }
    
    func testCheckAfterEndHasOnlyOneEmptyLineFromNoEndLines() {
        let input = ["\n", "@import UIKit", "\n", "\n", "\n"]
        let output = ["\n", "@import UIKit", "\n", "\n", "\n"]
        assert(input: input, checker: Checker().checkAfterEndHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckAfterEndHasOnlyOneEmptyLineFromMulipuleImportLines() {
        let input = ["\n", "@end", "\n", "\n", "@end", "\n", "\n", "\n"]
        let output = ["\n", "@end", "\n", "\n", "@end", "\n"]
        assert(input: input, checker: Checker().checkAfterEndHasOnlyOneEmptyLine(_:), output: output)
    }
    
    func testCheckAfterEndHasOnlyOneEmptyLineFromNormalLines() {
        let input = ["//\n",
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
                     "\n",
                     "\n",
                     "\n",
                     "\n",
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
                      "\n",
                      ]
        assert(input: input, checker: Checker().checkAfterEndHasOnlyOneEmptyLine(_:), output: output)
    }
}
