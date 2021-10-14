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

    func toDate(_ date: String) -> Foundation.Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let newDate = dateFormatter.date(from: date) {
            return newDate
        }
        fatalError()
    }

    
    func testCertainDateTimeEveryYear() {
        let pattern = try! DatePattern("10 13 20 9 3 ? *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-09 20:13:10"))
        XCTAssertEqual(generator.next(), toDate("2017-03-09 20:13:10"))
        XCTAssertEqual(generator.next(), toDate("2018-03-09 20:13:10"))
    }
    
    func testACertainDateTimeInTheFuture() {
        let pattern = try! DatePattern("34 56 12 18 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-18 12:56:34"))
        XCTAssertNil(generator.next())
    }

    func testACertainDateTimeInThePast() {
        let pattern = try! DatePattern("34 56 12 18 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-18 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertNil(generator.next())
    }
    
    func testEveryHourUntilEndOfCertainDay() {
        let pattern = try! DatePattern("15 0 * 18 3 * 2016", hash: 0)
        let currentDate = toDate("2016-03-18 20:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-18 21:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-18 22:00:15"))
        XCTAssertEqual(generator.next(), toDate("2016-03-18 23:00:15"))
        XCTAssertNil(generator.next())
    }

    func testEveryDayAtCertainTime() {
        let pattern = try! DatePattern("0 8 * * *", hash: 0)
        let currentDate = toDate("2016-06-09 18:15:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-06-10 08:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-06-11 08:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-06-12 08:00:00"))
    }


    // MARK: - Day Of Week
    func testEverySundaySymbol() {
        let pattern = try! DatePattern("0 0 12 ? * SUN *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-06 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-13 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-20 12:00:00"))
    }
    
    func testEverySundayNumber() {
        let pattern = try! DatePattern("0 0 12 ? * 1 *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-06 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-13 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-20 12:00:00"))
    }

    func testEveryMondaySymbol() {
        let pattern = try! DatePattern("0 0 12 ? * MON *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-07 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-14 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-21 12:00:00"))
    }
    
    func testEveryMondayNumber() {
        let pattern = try! DatePattern("0 0 12 ? * 2 *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-07 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-14 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-21 12:00:00"))
    }

    func testEveryThursdaySymbol() {
        let pattern = try! DatePattern("0 0 12 ? * THU *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-03 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-10 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-17 12:00:00"))
    }
    
    func testEveryThursdayNumber() {
        let pattern = try! DatePattern("0 0 12 ? * 5 *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-03 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-10 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-17 12:00:00"))
    }

    func testEverySaturdaySymbol() {
        let pattern = try! DatePattern("0 0 12 ? * SAT *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-05 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-12 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-19 12:00:00"))
    }
    
    func testEverySaturdayNumber() {
        let pattern = try! DatePattern("0 0 12 ? * SAT *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-05 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-12 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2016-03-19 12:00:00"))
    }
    
    func testEveryWednesday_WildcardDayOfMonth() {
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

    func testDayOfWeekRangeSymbol() {
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

    func testDayOfWeekRangeNumber() {
        let pattern = try! DatePattern("4 8 9 * * 2-4 2016", hash: 0)
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
    
    func testEveryMondayWednesdaySymbol() {
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
    
    func testEveryMondayWednesdayNumber() {
        let pattern = try! DatePattern("4 8 9 * * 2,4 2016", hash: 0)
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

    func testWeekDayRangeForCertainDayRange() {
        let pattern = try! DatePattern("4 8 9 4-15 2 MON-WED 2016", hash: 0)
        let currentDate = toDate("2016-02-08 12:57:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-02-09 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-10 09:08:04"))
        XCTAssertEqual(generator.next(), toDate("2016-02-15 09:08:04"))
        XCTAssertNil(generator.next())
    }

    // MARK: DayOfMonth
    
    func testEvery31stOfTheMonthAtCertainTime() {
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

    func testEveryDayUntilEndOfCertainMonth() {
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

    func testLeapDays() {
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
    
    func testCronEveryFirstFridayOfMonth() {
        let pattern = try! DatePattern("0 0 12 ? * FRI#1 *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-06-07 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-05 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-02 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-06 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-04 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-11-01 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-12-06 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-01-03 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-02-07 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-03-06 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-04-03 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-05-01 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-06-05 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-07-03 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-08-07 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-09-04 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-10-02 12:00:00"))
    }
    
    func testCronEveryLastDayOfMonth() {
        let pattern = try! DatePattern("0 0 12 L * ? *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-05-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-06-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-11-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-12-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-01-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-02-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-03-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-04-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-05-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-06-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-07-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-08-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-09-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-10-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-11-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-12-31 12:00:00"))
    }
    
    
    func testCronEveryLastWeekdayDayOfMonth() {
        let pattern = try! DatePattern("0 0 12 LW * ? *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-05-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-06-28 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-11-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-12-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-01-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-02-28 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-03-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-04-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-05-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-06-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-07-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-08-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-09-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-10-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-11-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2020-12-31 12:00:00"))
    }
    
    func testCronEveryLastSundayOfMonthNumber() {
        let pattern = try! DatePattern("0 0 12 ? * 1L *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-06-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-28 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-25 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-27 12:00:00"))
    }
    
    func testCronEveryLastSundayOfMonthSymbol() {
        let pattern = try! DatePattern("0 0 12 ? * SUNL *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-06-30 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-28 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-25 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-27 12:00:00"))
    }
    
    func testCronEveryLastMondayOfMonthNumber() {
        let pattern = try! DatePattern("0 0 12 ? * 2L *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-05-27 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-06-24 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-26 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-30 12:00:00"))
    }
    
    func testCronEveryLastSaturdayOfMonth() {
        let pattern = try! DatePattern("0 0 12 ? * 7L *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-06-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-27 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-28 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-26 12:00:00"))
    }
    
    func testCronEveryLastSaturdayOfMonthSymbol() {
        let pattern = try! DatePattern("0 0 12 ? * SATL *")
        let currentDate = toDate("2019-05-27 05:01:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2019-06-29 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-07-27 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-08-31 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-09-28 12:00:00"))
        XCTAssertEqual(generator.next(), toDate("2019-10-26 12:00:00"))
    }
    
    func testCronEveryOtherDay() {
        let pattern = try! DatePattern("59 59 23 1/2 * ? *")
        let currentDate = toDate("2020-02-01 12:00:00")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2020-02-01 23:59:59"))
        XCTAssertEqual(generator.next(), toDate("2020-02-03 23:59:59"))
        XCTAssertEqual(generator.next(), toDate("2020-02-05 23:59:59"))
        XCTAssertEqual(generator.next(), toDate("2020-02-07 23:59:59"))
        XCTAssertEqual(generator.next(), toDate("2020-02-09 23:59:59"))
        XCTAssertEqual(generator.next(), toDate("2020-02-11 23:59:59"))
        XCTAssertEqual(generator.next(), toDate("2020-02-13 23:59:59"))
    }
}

#if os(Linux)
extension CronTests {
    static var allTests: [(String, (CronTests) -> () throws -> Void)] {
        return [
            ("testCertainDateTimeEveryYear", testCertainDateTimeEveryYear),
            ("testACertainDateTimeInTheFuture", testACertainDateTimeInTheFuture),
            ("testACertainDateTimeInThePast", testACertainDateTimeInThePast),
            ("testEveryHourUntilEndOfCertainDay", testEveryHourUntilEndOfCertainDay),
            ("testEveryDayAtCertainTime", testEveryDayAtCertainTime),
            ("testEverySundaySymbol", testEverySundaySymbol),
            ("testEverySundayNumber", testEverySundayNumber),
            ("testEveryMondaySymbol", testEveryMondaySymbol),
            ("testEveryMondayNumber", testEveryMondayNumber),
            ("testEveryThursdaySymbol", testEveryThursdaySymbol),
            ("testEveryThursdayNumber", testEveryThursdayNumber),
            ("testEverySaturdaySymbol", testEverySaturdaySymbol),
            ("testEverySaturdayNumber", testEverySaturdayNumber),
            ("testEveryWednesday_WildcardDayOfMonth", testEveryWednesday_WildcardDayOfMonth),
            ("testDayOfWeekRangeSymbol", testDayOfWeekRangeSymbol),
            ("testDayOfWeekRangeNumber", testDayOfWeekRangeNumber),
            ("testEveryMondayWednesdaySymbol", testEveryMondayWednesdaySymbol),
            ("testEveryMondayWednesdayNumber", testEveryMondayWednesdayNumber),
            ("testWeekDayRangeForCertainDayRange", testWeekDayRangeForCertainDayRange),
            ("testEvery31stOfTheMonthAtCertainTime", testEvery31stOfTheMonthAtCertainTime),
            ("testEveryDayUntilEndOfCertainMonth", testEveryDayUntilEndOfCertainMonth),
            ("testLeapDays", testLeapDays),
            ("testCronEveryFirstFridayOfMonth", testCronEveryFirstFridayOfMonth),
            ("testCronEveryLastDayOfMonth", testCronEveryLastDayOfMonth),
            ("testCronEveryLastWeekdayDayOfMonth", testCronEveryLastWeekdayDayOfMonth),
            ("testCronEveryLastSundayOfMonthNumber", testCronEveryLastSundayOfMonthNumber),
            ("testCronEveryLastSundayOfMonthSymbol", testCronEveryLastSundayOfMonthSymbol),
            ("testCronEveryLastMondayOfMonthNumber", testCronEveryLastMondayOfMonthNumber),
            ("testCronEveryLastSaturdayOfMonth", testCronEveryLastSaturdayOfMonth),
            ("testCronEveryLastSaturdayOfMonthSymbol", testCronEveryLastSaturdayOfMonthSymbol),
            ("testCronEveryOtherDay", testCronEveryOtherDay)
        ]
    }
}
#endif

