//
//  FieldPatternTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cron

class FieldPatternTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetPattern() {
        func t(_ f: FieldPattern) -> NumberSet {
            do {
                return try f.getPattern { e in
                    return nil
                }
            } catch {
                XCTAssert(false)
            }
            fatalError("Unreachable")
        }

        func c(_ f: FieldPattern) -> [Int] {
            let tVar = t(f)
            return (0...59).filter { tVar.contains($0) }
        }

        XCTAssertEqual(NumberSet.or(.and(.range(0,20), .step(0,10)), .number(57)), t(.or([.step(.range(0, 20), 10), .number(57)])))

        XCTAssertEqual([0,10,20, 57], c(.or([.step(.range(0, 20), 10), .number(57)])))
        XCTAssertEqual([5, 15, 57], c(.or([.step(.range(5, 20), 10), .number(57)])))
        XCTAssertEqual([7, 11, 33, 55], c(.or([.step(.number(11), 22), .number(7)])))
    }
    
}

#if os(Linux)
extension FieldPatternTests {
    static var allTests: [(String, (FieldPatternTests) -> () throws -> Void)] {
        return [
            ("testGetPattern", testGetPattern)
        ]
    }
}
#endif
