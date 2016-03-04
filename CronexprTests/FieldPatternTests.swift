//
//  FieldPatternTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cronexpr


class FieldPatternTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetPattern() {
        func t(f: FieldPattern) -> NumberSet {
            do {
                return try f.getPattern { e in
                    return nil
                }
            } catch {
                XCTAssert(false)
            }
            fatalError("Unreachable")
        }

        func c(f: FieldPattern) -> [Int] {
            let t = t(f)
            return (0...59).filter { t.contains($0) }
        }

        XCTAssertEqual(NumberSet.Or(.And(.Range(0,20), .Step(0,10)), .Number(57)), t(.Or([.Step(.Range(0, 20), 10), .Number(57)])))

        XCTAssertEqual([0,10,20, 57], c(.Or([.Step(.Range(0, 20), 10), .Number(57)])))
        XCTAssertEqual([5, 15, 57], c(.Or([.Step(.Range(5, 20), 10), .Number(57)])))
        XCTAssertEqual([7, 11, 33, 55], c(.Or([.Step(.Number(11), 22), .Number(7)])))
    }
    
}
