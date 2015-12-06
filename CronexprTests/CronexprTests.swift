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
    
    func testCronJob() {
        let expectation = expectationWithDescription("Job will execute in 3 seconds")

        _ = try! CronJob(pattern: "* * * * * * *") { () -> Void in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

}
