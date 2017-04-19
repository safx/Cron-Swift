//
//  ParserTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/01.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cron

class ParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseExpression() {
        func p(_ s: String) -> DatePattern {
            do {
                return try parseExpression(s)
            } catch {
                fatalError()
            }
        }

        XCTAssertEqual(DatePattern(second: .any, minute: .any, hour: .any, dayOfMonth: .any, month: .any, dayOfWeek: .any, year: .any, hash: 0), p("* * * * * * *"))
        XCTAssertEqual(DatePattern(second: .hash, minute: .number(1), hour: .number(2), dayOfMonth: .number(3), month: .number(4), dayOfWeek: .number(5), year: .any, hash: 0), p("1 2 3 4 5"))
        XCTAssertEqual(DatePattern(second: .number(1), minute: .number(2), hour: .number(3), dayOfMonth: .number(4), month: .number(5), dayOfWeek: .number(6), year: .any, hash: 0), p("1 2 3 4 5 6"))
        XCTAssertEqual(DatePattern(second: .number(1), minute: .number(2), hour: .number(3), dayOfMonth: .number(4), month: .number(5), dayOfWeek: .number(6), year: .number(7), hash: 0), p("1 2 3 4 5 6 7"))
        XCTAssertEqual(DatePattern(second: .step(.any, 5), minute: .any, hour: .any, dayOfMonth: .any, month: .any, dayOfWeek: .any, year: .any, hash: 0), p("*/5 * * * * * *"))
    }

    func testLex() {
        func l(_ s: String) -> [Token] {
            return (try? lex(s)) ?? []
        }

        func lt(_ s: String) -> Error? {
            do {
                try lex(s)
                return nil
            } catch {
                return error
            }
        }

        XCTAssertEqual([.wildcard], l("*"))
        XCTAssertEqual([.wildcard], l("?"))
        XCTAssertEqual([.number(5, .raw)], l("05"))
        XCTAssertEqual([.number(6, .doW)], l("sat"))
        XCTAssertEqual([.number(10, .month)], l("Oct"))
        XCTAssertEqual([.wildcard, .slash, .number(15, .raw)], l("*/15"))
        XCTAssertEqual([.number(3, .raw), .hyphen, .number(29, .raw), .slash, .number(12, .raw)], l("3-29/12"))
        XCTAssertEqual([.number(1, .doW), .hyphen, .number(5, .doW), .slash, .number(2, .raw)], l("Mon-fRi/2"))
        XCTAssertEqual([.l], l("L"))
        XCTAssertEqual([.number(13, .raw), .w], l("13W"))
        XCTAssertEqual([.h], l("H"))
        XCTAssertEqual([.h, .openParen, .number(7, .raw), .hyphen, .number(28, .raw), .closeParen], l("H(7-28)"))
        XCTAssertEqual([.h, .openParen, .number(3, .raw), .hyphen, .number(19, .raw), .closeParen, .slash, .number(6, .raw)], l("H(3-19)/6"))
        XCTAssertEqual([.number(0, .raw), .hyphen, .number(20, .raw), .slash, .number(10, .raw)], l("0-20/10"))

        XCTAssertTrue(lt("Foo") is InternalError)
        XCTAssertTrue(lt("Foobar") is InternalError)
        XCTAssertTrue(lt("0x7f") is InternalError)
        XCTAssertTrue(lt("=") is InternalError)
        XCTAssertTrue(lt("15WX") is InternalError)
        XCTAssertTrue(lt("WL") is InternalError)
    }

    func testParseFieldPattern() {
        func p(_ t: [Token]) -> FieldPattern {
            do {
                return try parseFieldPattern(t)
            } catch {
                XCTAssert(false)
            }
            fatalError("Unreachable")
        }

        func pt(_ t: [Token]) -> Error? {
            do {
                try parseFieldPattern(t)
                return nil
            } catch {
                return error
            }
        }

        XCTAssertEqual(FieldPattern.any, p([.wildcard]))
        XCTAssertEqual(FieldPattern.any, p([.wildcard]))
        XCTAssertEqual(FieldPattern.number(5), p([.number(5, .raw)]))
        XCTAssertEqual(FieldPattern.number(6), p([.number(6, .doW)]))
        XCTAssertEqual(FieldPattern.number(10), p([.number(10, .month)]))
        XCTAssertEqual(FieldPattern.step(.any, 15), p([.wildcard, .slash, .number(15, .raw)]))
        //XCTAssertEqual(FieldPattern), p([.number(3, .raw), .hyphen, .number(29, .raw), .slash, .number(12, .raw)]))
        //XCTAssertEqual(FieldPattern), p([.number(1, .doW), .hyphen, .number(5, .doW), .slash, .number(2, .raw)]))
        XCTAssertEqual(FieldPattern.lastDayOfMonth, p([.l]))
        XCTAssertEqual(FieldPattern.weekday(13), p([.number(13, .raw), .w]))

        XCTAssertEqual(FieldPattern.weekday(13), p([.number(13, .raw), .w]))
        XCTAssertTrue(pt([.h, .openParen, .closeParen]) is InternalError)
        XCTAssertTrue(pt([.h, .openParen, .number(1, .raw), .closeParen]) is InternalError)
    }
}

extension DatePattern: Equatable {}

public func == (lhs: DatePattern, rhs: DatePattern) -> Bool {
    return lhs.second == rhs.second &&
    lhs.second     == rhs.second &&
    lhs.minute     == rhs.minute &&
    lhs.hour       == rhs.hour &&
    lhs.dayOfMonth == rhs.dayOfMonth &&
    lhs.month      == rhs.month &&
    lhs.dayOfWeek  == rhs.dayOfWeek &&
    lhs.year       == rhs.year
}

extension Token: Equatable {}

public func == (lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.number(let (a, b)), .number(let (c, d))): return a == c && b == d
    case (.wildcard, .wildcard): return true
    case (.slash, .slash): return true
    case (.hyphen, .hyphen): return true
    case (.numberSign, .numberSign): return true
    case (.l, .l): return true
    case (.h, .h): return true
    case (.openParen, .openParen): return true
    case (.closeParen, .closeParen): return true
    case (.w, .w): return true
    case (.lW, .lW): return true
    default: return false
    }
}

extension FieldPattern: Equatable {}

public func == (lhs: FieldPattern, rhs: FieldPattern) -> Bool {
    switch (lhs, rhs) {
    case (.any, .any): return true
    case (.number(let a), .number(let b)): return a == b
    case (.hash, .hash): return true
    case (.rangedHash(let a), .rangedHash(let b)): return a.0 == b.0 && a.1 == b.1
    case (.step(let a), .step(let b)): return a.0 == b.0 && a.1 == b.1
    case (.range(let a), .range(let b)): return a.0 == b.0 && a.1 == b.1

    case (.lastDayOfMonth, .lastDayOfMonth): return true
    case (.lastWeekdayOfMonth, .lastWeekdayOfMonth): return true
    case (.weekday(let a), .weekday(let b)): return a == b

    case (.lastDayOfWeek(let a), .lastDayOfWeek(let b)): return a == b
    case (.nthDayOfWeek(let a), .nthDayOfWeek(let b)): return a.0 == b.0 && a.1 == b.1

    //case Or

    default: return false
    }
}


extension NumberSet: Equatable {}

public func == (lhs: NumberSet, rhs: NumberSet) -> Bool {
    switch (lhs, rhs) {
    case (.any, .any): return true
    case (.number(let a), .number(let b)): return a == b
    case (.range(let a), .range(let b)): return a.0 == b.0 && a.1 == b.1
    case (.step(let a), .step(let b)): return a.0 == b.0 && a.1 == b.1
    case (.or(let a), .or(let b)): return a.0 == b.0 && a.1 == b.1
    case (.and(let a), .and(let b)): return a.0 == b.0 && a.1 == b.1
    default: return false
    }
}


extension Cron.Date: Equatable {}

public func == (lhs: Cron.Date, rhs: Cron.Date) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day && lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
}
