//
//  ParserTests.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/01.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Cronexpr


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
        func p(s: String) -> DatePattern {
            do {
                return try parseExpression(s)
            } catch {
                fatalError()
            }
        }

        XCTAssertEqual(DatePattern(second: .Any, minute: .Any, hour: .Any, dayOfMonth: .Any, month: .Any, dayOfWeek: .Any, year: .Any, hash: 0), p("* * * * * * *"))
        XCTAssertEqual(DatePattern(second: .Hash, minute: .Number(1), hour: .Number(2), dayOfMonth: .Number(3), month: .Number(4), dayOfWeek: .Number(5), year: .Any, hash: 0), p("1 2 3 4 5"))
        XCTAssertEqual(DatePattern(second: .Number(1), minute: .Number(2), hour: .Number(3), dayOfMonth: .Number(4), month: .Number(5), dayOfWeek: .Number(6), year: .Any, hash: 0), p("1 2 3 4 5 6"))
        XCTAssertEqual(DatePattern(second: .Number(1), minute: .Number(2), hour: .Number(3), dayOfMonth: .Number(4), month: .Number(5), dayOfWeek: .Number(6), year: .Number(7), hash: 0), p("1 2 3 4 5 6 7"))
        XCTAssertEqual(DatePattern(second: .Step(.Any, 5), minute: .Any, hour: .Any, dayOfMonth: .Any, month: .Any, dayOfWeek: .Any, year: .Any, hash: 0), p("*/5 * * * * * *"))
    }

    func testLex() {
        func l(s: String) -> [Token] {
            return (try? lex(s)) ?? []
        }

        func lt(s: String) -> ErrorType? {
            do {
                try lex(s)
                return nil
            } catch {
                return error
            }
        }

        XCTAssertEqual([.Wildcard], l("*"))
        XCTAssertEqual([.Wildcard], l("?"))
        XCTAssertEqual([.Number(5, .Raw)], l("05"))
        XCTAssertEqual([.Number(6, .DoW)], l("sat"))
        XCTAssertEqual([.Number(10, .Month)], l("Oct"))
        XCTAssertEqual([.Wildcard, .Slash, .Number(15, .Raw)], l("*/15"))
        XCTAssertEqual([.Number(3, .Raw), .Hyphen, .Number(29, .Raw), .Slash, .Number(12, .Raw)], l("3-29/12"))
        XCTAssertEqual([.Number(1, .DoW), .Hyphen, .Number(5, .DoW), .Slash, .Number(2, .Raw)], l("Mon-fRi/2"))
        XCTAssertEqual([.L], l("L"))
        XCTAssertEqual([.Number(13, .Raw), .W], l("13W"))
        XCTAssertEqual([.H], l("H"))
        XCTAssertEqual([.H, .OpenParen, .Number(7, .Raw), .Hyphen, .Number(28, .Raw), .CloseParen], l("H(7-28)"))
        XCTAssertEqual([.H, .OpenParen, .Number(3, .Raw), .Hyphen, .Number(19, .Raw), .CloseParen, .Slash, .Number(6, .Raw)], l("H(3-19)/6"))
        XCTAssertEqual([.Number(0, .Raw), .Hyphen, .Number(20, .Raw), .Slash, .Number(10, .Raw)], l("0-20/10"))

        XCTAssertTrue(lt("Foo") is InternalError)
        XCTAssertTrue(lt("Foobar") is InternalError)
        XCTAssertTrue(lt("0x7f") is InternalError)
        XCTAssertTrue(lt("=") is InternalError)
        XCTAssertTrue(lt("15WX") is InternalError)
        XCTAssertTrue(lt("WL") is InternalError)
    }

    func testParseFieldPattern() {
        func p(t: [Token]) -> FieldPattern {
            do {
                return try parseFieldPattern(t)
            } catch {
                XCTAssert(false)
            }
            fatalError("Unreachable")
        }

        func pt(t: [Token]) -> ErrorType? {
            do {
                try parseFieldPattern(t)
                return nil
            } catch {
                return error
            }
        }

        XCTAssertEqual(FieldPattern.Any, p([.Wildcard]))
        XCTAssertEqual(FieldPattern.Any, p([.Wildcard]))
        XCTAssertEqual(FieldPattern.Number(5), p([.Number(5, .Raw)]))
        XCTAssertEqual(FieldPattern.Number(6), p([.Number(6, .DoW)]))
        XCTAssertEqual(FieldPattern.Number(10), p([.Number(10, .Month)]))
        XCTAssertEqual(FieldPattern.Step(.Any, 15), p([.Wildcard, .Slash, .Number(15, .Raw)]))
        //XCTAssertEqual(FieldPattern), p([.Number(3, .Raw), .Hyphen, .Number(29, .Raw), .Slash, .Number(12, .Raw)]))
        //XCTAssertEqual(FieldPattern), p([.Number(1, .DoW), .Hyphen, .Number(5, .DoW), .Slash, .Number(2, .Raw)]))
        XCTAssertEqual(FieldPattern.LastDayOfMonth, p([.L]))
        XCTAssertEqual(FieldPattern.Weekday(13), p([.Number(13, .Raw), .W]))

        XCTAssertEqual(FieldPattern.Weekday(13), p([.Number(13, .Raw), .W]))
        XCTAssertTrue(pt([.H, .OpenParen, .CloseParen]) is InternalError)
        XCTAssertTrue(pt([.H, .OpenParen, .Number(1, .Raw), .CloseParen]) is InternalError)
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

func == (lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.Number(let (a, b)), .Number(let (c, d))): return a == c && b == d
    case (.Wildcard, .Wildcard): return true
    case (.Slash, .Slash): return true
    case (.Hyphen, .Hyphen): return true
    case (.NumberSign, .NumberSign): return true
    case (.L, .L): return true
    case (.H, .H): return true
    case (.OpenParen, .OpenParen): return true
    case (.CloseParen, .CloseParen): return true
    case (.W, .W): return true
    case (.LW, .LW): return true
    default: return false
    }
}

extension FieldPattern: Equatable {}

func == (lhs: FieldPattern, rhs: FieldPattern) -> Bool {
    switch (lhs, rhs) {
    case (.Any, .Any): return true
    case (.Number(let a), .Number(let b)): return a == b
    case (.Hash, .Hash): return true
    case (.RangedHash(let a), .RangedHash(let b)): return a.0 == b.0 && a.1 == b.1
    case (.Step(let a), .Step(let b)): return a.0 == b.0 && a.1 == b.1
    case (.Range(let a), .Range(let b)): return a.0 == b.0 && a.1 == b.1

    case (.LastDayOfMonth, .LastDayOfMonth): return true
    case (.LastWeekdayOfMonth, .LastWeekdayOfMonth): return true
    case (.Weekday(let a), .Weekday(let b)): return a == b

    case (.LastDayOfWeek(let a), .LastDayOfWeek(let b)): return a == b
    case (.NthDayOfWeek(let a), .NthDayOfWeek(let b)): return a.0 == b.0 && a.1 == b.1

    //case Or

    default: return false
    }
}


extension NumberSet: Equatable {}

func == (lhs: NumberSet, rhs: NumberSet) -> Bool {
    switch (lhs, rhs) {
    case (.Any, .Any): return true
    case (.Number(let a), .Number(let b)): return a == b
    case (.Range(let a), .Range(let b)): return a.0 == b.0 && a.1 == b.1
    case (.Step(let a), .Step(let b)): return a.0 == b.0 && a.1 == b.1
    case (.Or(let a), .Or(let b)): return a.0 == b.0 && a.1 == b.1
    case (.And(let a), .And(let b)): return a.0 == b.0 && a.1 == b.1
    default: return false
    }
}


extension Date: Equatable {}

func == (lhs: Date, rhs: Date) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day && lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
}
