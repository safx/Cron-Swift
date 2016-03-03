//
//  CronexprTests.swift
//  CronexprTests
//
//  Created by Safx Developer on 2015/11/20.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cronexpr

class CronexprTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func toDate(date: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let newDate = dateFormatter.dateFromString(date) {
            return newDate
        }
        fatalError()
    }

    func testCronJob() {
        let expectation = expectationWithDescription("Job will execute within 3 seconds")

        _ = try! CronJob(pattern: "* * * * * * *") { () -> Void in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCronJob2() {
        let pattern = try! parseExpression("10 13 20 9 3 ? *", hash: 0)
        let currentDate = toDate("2016-03-02 09:08:07")
        var generator = DateGenerator(pattern: pattern, hash: 0, date: currentDate)
        XCTAssertEqual(generator.next(), toDate("2016-03-09 20:13:10"))
        XCTAssertEqual(generator.next(), toDate("2017-03-09 20:13:10"))
        XCTAssertEqual(generator.next(), toDate("2018-03-09 20:13:10"))
    }

}
