//
//  NumberSetTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/21.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cron

class NumberSetTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - contains

    func test_contains_any() {
        XCTAssertEqual(NumberSet.any.contains(1), true)
        XCTAssertEqual(NumberSet.any.contains(2), true)
        XCTAssertEqual(NumberSet.any.contains(3), true)
        XCTAssertEqual(NumberSet.any.contains(4), true)
        XCTAssertEqual(NumberSet.any.contains(2001), true)
        XCTAssertEqual(NumberSet.any.contains(2014), true)
    }

    func test_contains_set() {
        let s = NumberSet.or(.number(4), NumberSet.or(.number(8), .number(7)))
        XCTAssertEqual(s.contains(0), false)
        XCTAssertEqual(s.contains(1), false)
        XCTAssertEqual(s.contains(2), false)
        XCTAssertEqual(s.contains(3), false)
        XCTAssertEqual(s.contains(5), false)
        XCTAssertEqual(s.contains(6), false)
        XCTAssertEqual(s.contains(9), false)

        XCTAssertEqual(s.contains(4), true)
        XCTAssertEqual(s.contains(7), true)
        XCTAssertEqual(s.contains(8), true)
    }


    func test_contains_range() {
        XCTAssertEqual(NumberSet.range(5,5).contains(4), false)
        XCTAssertEqual(NumberSet.range(5,5).contains(5), true)
        XCTAssertEqual(NumberSet.range(5,5).contains(6), false)

        XCTAssertEqual(NumberSet.range(1,2).contains(0), false)
        XCTAssertEqual(NumberSet.range(1,2).contains(1), true)
        XCTAssertEqual(NumberSet.range(1,2).contains(2), true)
        XCTAssertEqual(NumberSet.range(1,2).contains(3), false)
    }

    func test_contains_range2() {
        XCTAssertEqual(NumberSet.range(1995,2014).contains(0), false)
        XCTAssertEqual(NumberSet.range(1995,2014).contains(1994), false)
        XCTAssertEqual(NumberSet.range(1995,2014).contains(1995), true)
        XCTAssertEqual(NumberSet.range(1995,2014).contains(2000), true)
        XCTAssertEqual(NumberSet.range(1995,2014).contains(2014), true)
        XCTAssertEqual(NumberSet.range(1995,2014).contains(2015), false)
        XCTAssertEqual(NumberSet.range(1995,2014).contains(9999), false)
    }

    func test_contains_repeat() {
        XCTAssertEqual(NumberSet.step(4,3).contains(4), true)
        XCTAssertEqual(NumberSet.step(4,3).contains(7), true)
        XCTAssertEqual(NumberSet.step(4,3).contains(10), true)

        XCTAssertEqual(NumberSet.step(4,3).contains(3), false)
        XCTAssertEqual(NumberSet.step(4,3).contains(5), false)
        XCTAssertEqual(NumberSet.step(4,3).contains(6), false)
        XCTAssertEqual(NumberSet.step(4,3).contains(8), false)
        XCTAssertEqual(NumberSet.step(4,3).contains(9), false)
        XCTAssertEqual(NumberSet.step(4,3).contains(11), false)
    }

    func test_contains_and() {
        XCTAssertEqual(NumberSet.and(.any, .step(4,3)).contains(11), false)

        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(7), false)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(8), true)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(9), false)

        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(17), false)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(18), true)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(19), false)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(20), false)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(21), false)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(22), false)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).contains(23), false)
    }

    func test_contains_or() {
        XCTAssertEqual(NumberSet.or(.any, .range(4,11)).contains(20), true)

        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(2), false)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(3), true)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(4), true)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(5), true)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(6), true)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(19), true)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(20), true)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(21), false)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(22), false)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).contains(23), true)
    }

    // MARK: - next

    func test_next_any() {
        XCTAssertEqual(NumberSet.any.next(1), 2)
        XCTAssertEqual(NumberSet.any.next(2001), 2002)
    }

    func test_next_set() {
        let s = NumberSet.or(.number(4), NumberSet.or(.number(8), .number(7)))
        XCTAssertEqual(s.next(2), 4)
        XCTAssertEqual(s.next(3), 4)
        XCTAssertEqual(s.next(4), 7)
        XCTAssertEqual(s.next(5), 7)
        XCTAssertEqual(s.next(6), 7)
        XCTAssertEqual(s.next(7), 8)
        XCTAssertEqual(s.next(8), nil)
    }

    func test_next_range() {
        XCTAssertEqual(NumberSet.range(5,7).next(3), 5)
        XCTAssertEqual(NumberSet.range(5,7).next(4), 5)
        XCTAssertEqual(NumberSet.range(5,7).next(5), 6)
        XCTAssertEqual(NumberSet.range(5,7).next(6), 7)
        XCTAssertEqual(NumberSet.range(5,7).next(7), nil)
    }

    func test_next_repeat() {
        XCTAssertEqual(NumberSet.step(8,5).next(1), 3)
        XCTAssertEqual(NumberSet.step(8,5).next(2), 3)
        XCTAssertEqual(NumberSet.step(8,5).next(3), 8)
        XCTAssertEqual(NumberSet.step(8,5).next(4), 8)
        XCTAssertEqual(NumberSet.step(8,5).next(5), 8)
        XCTAssertEqual(NumberSet.step(8,5).next(6), 8)
        XCTAssertEqual(NumberSet.step(8,5).next(7), 8)
        XCTAssertEqual(NumberSet.step(8,5).next(8), 13)
        XCTAssertEqual(NumberSet.step(8,5).next(9), 13)

        XCTAssertEqual(NumberSet.step(3,7).next(9),  10)
        XCTAssertEqual(NumberSet.step(3,7).next(10), 17)
        XCTAssertEqual(NumberSet.step(3,7).next(11), 17)

        XCTAssertEqual(NumberSet.step(3,7).next(2), 3)
        XCTAssertEqual(NumberSet.step(3,7).next(3), 10)
        XCTAssertEqual(NumberSet.step(3,7).next(4), 10)
    }


    func test_next_and() {
        XCTAssertEqual(NumberSet.and(.any, .step(4,3)).next(11), 13)

        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).next(7), 8)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).next(8), 13)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).next(9), 13)

        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).next(17), 18)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).next(18), nil)
        XCTAssertEqual(NumberSet.and(.range(4,20), .step(8,5)).next(19), nil)
    }

    func test_next_or() {
        XCTAssertEqual(NumberSet.or(.any, .range(4,11)).next(20), 21)

        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(1), 3)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(2), 3)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(3), 4)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(4), 5)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(5), 6)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(6), 7)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(19), 20)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(20), 23)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(21), 23)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(22), 23)
        XCTAssertEqual(NumberSet.or(.range(4,20), .step(8,5)).next(23), 28)
    }

}

#if os(Linux)
extension NumberSetTests {
    static var allTests: [(String, (NumberSetTests) -> () throws -> Void)] {
        return [
            ("test_contains_any", test_contains_any),
            ("test_contains_set", test_contains_set),
            ("test_contains_range", test_contains_range),
            ("test_contains_range2", test_contains_range2),
            ("test_contains_repeat", test_contains_repeat),
            ("test_contains_and", test_contains_and),
            ("test_contains_or", test_contains_or),
            ("test_next_any", test_next_any),
            ("test_next_set", test_next_set),
            ("test_next_range", test_next_range),
            ("test_next_repeat", test_next_repeat),
            ("test_next_and", test_next_and),
            ("test_next_or", test_next_or)
        ]
    }
}
#endif
