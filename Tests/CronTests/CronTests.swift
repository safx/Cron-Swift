//
//  CronexprTests.swift
//  CronexprTests
//
//  Created by Safx Developer on 2015/11/20.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cron

typealias NSDate = Foundation.Date

class CronTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func toDate(_ date: String) -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let newDate = dateFormatter.date(from: date) {
            return newDate
        }
        fatalError()
    }

    func testCronJob() {
        let expect = expectation(description: "Job will execute within 3 seconds")

        do {
            _ = try CronJob(pattern: "* * * * * * *") { () -> Void in
                expect.fulfill()
            }
        } catch {
            print(error)
        }

        waitForExpectations(timeout: 3) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCronJob2() {
        let pattern = try! DatePattern("10 13 20 9 3 ? *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-09 20:13:10"))
        XCTAssertEqual(generator.next(), toDate("2017-03-09 20:13:10"))
        XCTAssertEqual(generator.next(), toDate("2018-03-09 20:13:10"))
    }

    func testCronJob3() {
        let pattern = try! DatePattern("0 0 12 ? * SUN *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-06 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-13 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-20 12:00:00"))
    }

    func testCronJob4() {
        let pattern = try! DatePattern("0 0 12 ? * MON *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-07 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-14 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-21 12:00:00"))
    }

    func testCronJob5() {
        let pattern = try! DatePattern("0 0 12 ? * THU *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-03 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-10 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-17 12:00:00"))
    }

    func testCronJob6() {
        let pattern = try! DatePattern("0 0 12 ? * FRI *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-04 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-11 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-18 12:00:00"))
    }

    func testCronJob7() {
        let pattern = try! DatePattern("56 34 12 31 * * 2016", hash: 0)
        let currentDate = toDate("2016-01-01 23:59:59")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-01-31 12:34:56"))
        XCTAssertEqual(generator.next(), toDate("2016-03-31 12:34:56"))
        XCTAssertEqual(generator.next(), toDate("2016-05-31 12:34:56"))
        XCTAssertEqual(generator.next(), toDate("2016-07-31 12:34:56"))
        XCTAssertEqual(generator.next(), toDate("2016-08-31 12:34:56"))
        XCTAssertEqual(generator.next(), toDate("2016-10-31 12:34:56"))
        XCTAssertEqual(generator.next(), toDate("2016-12-31 12:34:56"))
        XCTAssertNil(generator.next())
    }

    func testCronJob8() {
        let pattern = try! DatePattern("34 56 12 18 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-18 12:56:34"))
        XCTAssertNil(generator.next())
    }

    func testCronJob9() {
        let pattern = try! DatePattern("34 56 12 18 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-18 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertNil(generator.next())
    }

    func testCronJob10() {
        let pattern = try! DatePattern("15 0 12 * 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-18 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-19 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-20 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-21 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-22 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-23 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-24 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-25 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-26 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-27 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-28 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-29 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-30 12:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-31 12:00:15"))
        XCTAssertNil(generator.next())
    }

    func testCronJob11() {
        let pattern = try! DatePattern("15 0 * 18 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-18 20:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-18 21:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-18 22:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-18 23:00:15"))
        XCTAssertNil(generator.next())
    }

    func testCronJob12() {
        let pattern = try! DatePattern("0 8 * * *", hash: 0)
        let currentDate = toDate("2016-06-09 18:15:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-06-10 08:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-06-11 08:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-06-12 08:00:00"))
    }

    func testCronJobDoW() {
        let pattern = try! DatePattern("34 56 12 * * WED 2016", hash: 0)
        let currentDate = toDate("2016-02-28 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-02 12:56:34"))
        XCTAssertEqual(generator.next(), toDate("2016-03-09 12:56:34"))
        XCTAssertEqual(generator.next(), toDate("2016-03-16 12:56:34"))
        XCTAssertEqual(generator.next(), toDate("2016-03-23 12:56:34"))
        XCTAssertEqual(generator.next(), toDate("2016-03-30 12:56:34"))
        XCTAssertEqual(generator.next(), toDate("2016-04-06 12:56:34"))
    }

    func testCronJobDoW2() {
        let pattern = try! DatePattern("4 8 9 * * MON-WED 2016", hash: 0)
        let currentDate = toDate("2016-02-08 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-02-09 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-10 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-15 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-16 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-17 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-22 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-23 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-24 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-29 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-03-01 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-03-02 09:08:04"))
    }

    func testCronJobDoW3() {
        let pattern = try! DatePattern("4 8 9 * * MON,WED 2016", hash: 0)
        let currentDate = toDate("2016-02-08 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-02-10 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-15 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-17 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-22 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-24 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-29 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-03-02 09:08:04"))
    }

    func testCronJobDoW4() {
        let pattern = try! DatePattern("4 8 9 4-15 2 MON-WED 2016", hash: 0)
        let currentDate = toDate("2016-02-08 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-02-09 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-10 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-15 09:08:04"))
        XCTAssertNil(generator.next())
    }

    func testCronJobLeaps() {
        let pattern = try! DatePattern("05 43 21 29 2 * *", hash: 0)
        let currentDate = toDate("1999-01-11 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2000-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2004-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2008-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2012-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2016-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2020-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2024-02-29 21:43:05"))
        XCTAssertEqual(generator.next(), toDate("2028-02-29 21:43:05"))
    }
}

#if os(Linux)
extension CronTests {
    static var allTests: [(String, (CronTests) -> () throws -> Void)] {
        return [
            ("testCronJob", testCronJob),
            ("testCronJob2", testCronJob2),
            ("testCronJob3", testCronJob3),
            ("testCronJob4", testCronJob4),
            ("testCronJob5", testCronJob5),
            ("testCronJob6", testCronJob6),
            ("testCronJob7", testCronJob7),
            ("testCronJob8", testCronJob8),
            ("testCronJob9", testCronJob9),
            ("testCronJob10", testCronJob10),
            ("testCronJob11", testCronJob11),
            ("testCronJob12", testCronJob12),
            ("testCronJobDoW", testCronJobDoW),
            ("testCronJobDoW2", testCronJobDoW2),
            ("testCronJobDoW3", testCronJobDoW3),
            ("testCronJobDoW4", testCronJobDoW4),
            ("testCronJobLeaps", testCronJobLeaps)
        ]
    }
}
#endif
