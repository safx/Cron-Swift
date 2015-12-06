//
//  NumberSetTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/21.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cronexpr

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
        XCTAssertEqual(NumberSet.Any.contains(1), true)
        XCTAssertEqual(NumberSet.Any.contains(2), true)
        XCTAssertEqual(NumberSet.Any.contains(3), true)
        XCTAssertEqual(NumberSet.Any.contains(4), true)
        XCTAssertEqual(NumberSet.Any.contains(2001), true)
        XCTAssertEqual(NumberSet.Any.contains(2014), true)
    }

    func test_contains_set() {
        let s = NumberSet.Or(.Number(4), NumberSet.Or(.Number(8), .Number(7)))
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
        XCTAssertEqual(NumberSet.Range(5,5).contains(4), false)
        XCTAssertEqual(NumberSet.Range(5,5).contains(5), true)
        XCTAssertEqual(NumberSet.Range(5,5).contains(6), false)

        XCTAssertEqual(NumberSet.Range(1,2).contains(0), false)
        XCTAssertEqual(NumberSet.Range(1,2).contains(1), true)
        XCTAssertEqual(NumberSet.Range(1,2).contains(2), true)
        XCTAssertEqual(NumberSet.Range(1,2).contains(3), false)
    }

    func test_contains_range2() {
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(0), false)
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(1994), false)
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(1995), true)
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(2000), true)
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(2014), true)
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(2015), false)
        XCTAssertEqual(NumberSet.Range(1995,2014).contains(9999), false)
    }

    func test_contains_repeat() {
        XCTAssertEqual(NumberSet.Step(4,3).contains(4), true)
        XCTAssertEqual(NumberSet.Step(4,3).contains(7), true)
        XCTAssertEqual(NumberSet.Step(4,3).contains(10), true)

        XCTAssertEqual(NumberSet.Step(4,3).contains(3), false)
        XCTAssertEqual(NumberSet.Step(4,3).contains(5), false)
        XCTAssertEqual(NumberSet.Step(4,3).contains(6), false)
        XCTAssertEqual(NumberSet.Step(4,3).contains(8), false)
        XCTAssertEqual(NumberSet.Step(4,3).contains(9), false)
        XCTAssertEqual(NumberSet.Step(4,3).contains(11), false)
    }

    func test_contains_and() {
        XCTAssertEqual(NumberSet.And(.Any, .Step(4,3)).contains(11), false)

        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(7), false)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(8), true)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(9), false)

        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(17), false)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(18), true)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(19), false)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(20), false)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(21), false)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(22), false)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).contains(23), false)
    }

    func test_contains_or() {
        XCTAssertEqual(NumberSet.Or(.Any, .Range(4,11)).contains(20), true)

        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(2), false)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(3), true)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(4), true)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(5), true)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(6), true)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(19), true)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(20), true)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(21), false)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(22), false)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).contains(23), true)
    }

    // MARK: - next

    func test_next_any() {
        XCTAssertEqual(NumberSet.Any.next(1), 2)
        XCTAssertEqual(NumberSet.Any.next(2001), 2002)
    }

    func test_next_set() {
        let s = NumberSet.Or(.Number(4), NumberSet.Or(.Number(8), .Number(7)))
        XCTAssertEqual(s.next(2), 4)
        XCTAssertEqual(s.next(3), 4)
        XCTAssertEqual(s.next(4), 7)
        XCTAssertEqual(s.next(5), 7)
        XCTAssertEqual(s.next(6), 7)
        XCTAssertEqual(s.next(7), 8)
        XCTAssertEqual(s.next(8), nil)
    }

    func test_next_range() {
        XCTAssertEqual(NumberSet.Range(5,7).next(3), 5)
        XCTAssertEqual(NumberSet.Range(5,7).next(4), 5)
        XCTAssertEqual(NumberSet.Range(5,7).next(5), 6)
        XCTAssertEqual(NumberSet.Range(5,7).next(6), 7)
        XCTAssertEqual(NumberSet.Range(5,7).next(7), nil)
    }

    func test_next_repeat() {
        XCTAssertEqual(NumberSet.Step(8,5).next(1), 3)
        XCTAssertEqual(NumberSet.Step(8,5).next(2), 3)
        XCTAssertEqual(NumberSet.Step(8,5).next(3), 8)
        XCTAssertEqual(NumberSet.Step(8,5).next(4), 8)
        XCTAssertEqual(NumberSet.Step(8,5).next(5), 8)
        XCTAssertEqual(NumberSet.Step(8,5).next(6), 8)
        XCTAssertEqual(NumberSet.Step(8,5).next(7), 8)
        XCTAssertEqual(NumberSet.Step(8,5).next(8), 13)
        XCTAssertEqual(NumberSet.Step(8,5).next(9), 13)

        XCTAssertEqual(NumberSet.Step(3,7).next(9),  10)
        XCTAssertEqual(NumberSet.Step(3,7).next(10), 17)
        XCTAssertEqual(NumberSet.Step(3,7).next(11), 17)

        XCTAssertEqual(NumberSet.Step(3,7).next(2), 3)
        XCTAssertEqual(NumberSet.Step(3,7).next(3), 10)
        XCTAssertEqual(NumberSet.Step(3,7).next(4), 10)
    }


    func test_next_and() {
        XCTAssertEqual(NumberSet.And(.Any, .Step(4,3)).next(11), 13)

        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).next(7), 8)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).next(8), 13)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).next(9), 13)

        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).next(17), 18)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).next(18), nil)
        XCTAssertEqual(NumberSet.And(.Range(4,20), .Step(8,5)).next(19), nil)
    }

    func test_next_or() {
        XCTAssertEqual(NumberSet.Or(.Any, .Range(4,11)).next(20), 21)

        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(1), 3)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(2), 3)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(3), 4)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(4), 5)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(5), 6)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(6), 7)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(19), 20)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(20), 23)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(21), 23)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(22), 23)
        XCTAssertEqual(NumberSet.Or(.Range(4,20), .Step(8,5)).next(23), 28)
    }

}
