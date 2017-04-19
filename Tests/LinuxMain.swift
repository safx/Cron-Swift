import XCTest
@testable import CronTests

XCTMain([
    testCase(CronTests.allTests),
    testCase(DatePatternTests.allTests),
    testCase(FieldPatternTests.allTests),
    testCase(NumberSetTests.allTests),
    testCase(ParserTests.allTests),
    testCase(UtilTests.allTests)
])
