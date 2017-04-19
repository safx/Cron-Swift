//
//  UtilTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cron

class UtilTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetDayOfWeek() {
        XCTAssertEqual(DayOfWeek.thursday, getDayOfWeek(day: 8, month: 10, year: 2015))
        XCTAssertEqual(DayOfWeek.sunday, getDayOfWeek(day: 4, month: 1, year: 2015))
        XCTAssertEqual(DayOfWeek.saturday, getDayOfWeek(day: 1, month: 1, year: 2000))
        XCTAssertEqual(DayOfWeek.wednesday, getDayOfWeek(day: 1, month: 3, year: 2000))
    }

    func testLastDayOfMonth() {
        XCTAssertEqual(29, getLastDayOfMonth(month: 2, year: 2000))
        XCTAssertEqual(31, getLastDayOfMonth(month: 1, year: 2000))
        XCTAssertEqual(28, getLastDayOfMonth(month: 2, year: 2001))
    }
}

#if os(Linux)
extension UtilTests {
    static var allTests: [(String, (UtilTests) -> () throws -> Void)] {
        return [
            ("testGetDayOfWeek", testGetDayOfWeek),
            ("testLastDayOfMonth", testLastDayOfMonth)
        ]
    }
}
#endif
