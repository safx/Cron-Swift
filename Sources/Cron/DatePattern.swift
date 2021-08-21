//
//  Date.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/22.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation

public struct DatePattern: Equatable {
    public let second    : FieldPattern
    public let minute    : FieldPattern
    public let hour      : FieldPattern
    public let dayOfMonth: FieldPattern
    public let month     : FieldPattern
    public let dayOfWeek : FieldPattern
    public let year      : FieldPattern
    public let hash      : Int64
    public let string    : String

    public init(_ expr: String, hash: Int64 = 0) throws {
        let fields = expr.components(separatedBy: CharacterSet.whitespaces)
            .filter { $0.count > 0 }

        guard (5...7).contains(fields.count) else {
            throw InternalError.parseError
        }

        let patterns = try fields.enumerated().map { try DatePattern.parseField($0.element, fieldIndex: $0.offset) }
            .map { e -> FieldPattern in
                precondition(e.count > 0)
                return e.count == 1 ?  e.first! : FieldPattern.or(e)
        }

        let appendedPatterns = (patterns.count <= 5 ? [.hash] : []) + patterns + (patterns.count <= 6 ? [.any] : [])
        precondition(appendedPatterns.count == 7)

        self.second     = appendedPatterns[0]
        self.minute     = appendedPatterns[1]
        self.hour       = appendedPatterns[2]
        self.dayOfMonth = appendedPatterns[3]
        self.month      = appendedPatterns[4]
        self.dayOfWeek  = appendedPatterns[5]
        self.year       = appendedPatterns[6]
        self.hash       = hash
        self.string     = expr
    }

    internal static func parseField(_ string: String, fieldIndex: Int) throws -> [FieldPattern] {
        return try string.components(separatedBy: ",")
            .map(DatePattern.lex)
            .map { tokens in
                try DatePattern.parseFieldPattern(tokens, fieldIndex: fieldIndex)
            }
    }

    @discardableResult
    internal static func parseFieldPattern(_ ts: [Token], fieldIndex: Int) throws -> FieldPattern {
        let isDayOfWeekField = fieldIndex == 5
        guard let first = ts.first else { throw InternalError.parseError }
        guard let second: Token = ts.count > 1 ? ts[1] : nil else {
            switch (first) {
            case .wildcard: return .any
            case .number(let num, _):
                if isDayOfWeekField {
                    return .number(num - 1)
                }
                return .number(num)
            case .h: return .hash
            case .l: return .lastDayOfMonth
            case .lW: return .lastWeekdayOfMonth
            default: ()
            }
            throw InternalError.parseError
        }

        guard let third: Token = ts.count > 2 ? ts[2] : nil else {
            switch (first, second) {
            case let (.slash, .number(num, _)):
                return .step(.any, num)
            case let (.number(num, _), .l):
                guard 1...7 ~= num else {
                    throw InternalError.parseError
                }
                return .lastDayOfWeek(DayOfWeek(rawValue: (num - 1) % 7)!)
            case let (.number(num, _), .w):
                return .weekday(num)
            default:
                throw InternalError.parseError
            }
        }

        guard let forth: Token = ts.count > 3 ? ts[3] : nil else {
            switch (first, second, third) {
            case let (.number(beginNum, _), .hyphen, .number(endNum, _)):
                if isDayOfWeekField{
                    return .range(beginNum - 1, endNum - 1)
                }
                return .range(beginNum, endNum)
            case let (.wildcard, .slash, .number(stepNum, _)):
                return .step(.any, stepNum)
            case let (.number(num, _), .slash, .number(stepNum, _)):
                return .step(.number(num), stepNum)
            case let (.h, .hyphen, .number(stepNum, _)):
                return .step(.hash, stepNum)
            case let (.number(dowNum, _), .numberSign, .number(num, _)):
                guard 1...7 ~= dowNum else {
                    throw InternalError.parseError
                }
                return .nthDayOfWeek(DayOfWeek(rawValue: (dowNum - 1) % 7)!, num - 1)
            default:
                throw InternalError.parseError
            }
        }

        guard let fifth: Token = ts.count > 4 ? ts[4] : nil else {
            throw InternalError.parseError
        }

        guard let sixth: Token = ts.count > 5 ? ts[5] : nil else {
            switch (first, second, third, forth, fifth) {
            case let (.number(beginNum, _), .hyphen, .number(endNum, _), .slash, .number(stepNum, _)):
                return .step(.range(beginNum, endNum), stepNum)
            default:
                throw InternalError.parseError
            }
        }

        guard let seventh: Token = ts.count > 6 ? ts[6] : nil else {
            switch (first, second, third, forth, fifth, sixth) {
            case let (.h, .openParen, .number(beginNum, _), .hyphen, .number(endNum, _), .closeParen):
                return .rangedHash(beginNum, endNum)
            default:
                throw InternalError.parseError
            }
        }

        guard let eighth: Token = ts.count > 7 ? ts[7] : nil else {
            throw InternalError.parseError
        }

        guard let _: Token = ts.count > 8 ? ts[8] : nil else {
            switch (first, second, third, forth, fifth, sixth, seventh, eighth) {
            case let (.h, .openParen, .number(beginNum, _), .hyphen, .number(endNum, _), .closeParen, .slash, .number(stepNum, _)):
                return .step(.rangedHash(beginNum, endNum), stepNum)
            default:
                throw InternalError.parseError
            }
        }

        throw InternalError.parseError
    }

    @discardableResult
    internal static func lex(_ entry: String) throws -> [Token] {
        func lexNum(_ es: [Character], n: Int = 0) throws -> [Token] {
            guard let e = es.first else {
                return []
            }
            let tail = Array(es.dropFirst(1))

            switch e {
            case "0"..."9":
                guard let v = Int(String(e), radix: 10) else {
                    fatalError("Unreacahble")
                }
                return try lexNum(tail, n: n * 10 + v)
            default:
                return [.number(n, .raw)] + (try lexMain(es))
            }
        }

        func parseSym(s: String) throws -> [Token]{
            switch s.uppercased() {
            case "H": return [.h]
            case "L": return [.l]
            case "W": return [.w]
            case "LW": return [.lW]
            case "SUN": return [.number(1, .doW)]
            case "MON": return [.number(2, .doW)]
            case "TUE": return [.number(3, .doW)]
            case "WED": return [.number(4, .doW)]
            case "THU": return [.number(5, .doW)]
            case "FRI": return [.number(6, .doW)]
            case "SAT": return [.number(7, .doW)]
            case "JAN": return [.number(1, .month)]
            case "FEB": return [.number(2, .month)]
            case "MAR": return [.number(3, .month)]
            case "APR": return [.number(4, .month)]
            case "MAY": return [.number(5, .month)]
            case "JUN": return [.number(6, .month)]
            case "JUL": return [.number(7, .month)]
            case "AUG": return [.number(8, .month)]
            case "SEP": return [.number(9, .month)]
            case "OCT": return [.number(10, .month)]
            case "NOV": return [.number(11, .month)]
            case "DEC": return [.number(12, .month)]
            default: throw InternalError.unrecognizedSymbol(entry, s)
            }
        }
        
        func lexSym(_ es: [Character], s: String = "") throws -> [Token] {
            guard let e = es.first else {
                return []
            }
            let tail = Array(es.dropFirst(1))

            switch e {
            case "a"..."z": fallthrough
            case "A"..."Z": return try lexSym(tail, s: s + String(e))
            default: ()
            }

            if s.count == 4 && s.hasSuffix("L") && !s.hasSuffix("JUL"){
                return (try parseSym(s: String(s.dropLast()))) + [.l] + (try lexMain(es))
            }
            
            return (try parseSym(s: s)) + (try lexMain(es))
        }

        func lexMain(_ es: [Character]) throws -> [Token] {
            guard let e = es.first else {
                return []
            }
            let tail = Array(es.dropFirst(1))

            switch e {
            case "*": fallthrough
            case "?": return [.wildcard] + (try lexMain(tail))
            case "-": return [.hyphen] + (try lexMain(tail))
            case "/": return [.slash] + (try lexMain(tail))
            case "#": return [.numberSign] + (try lexMain(tail))
            case "(": return [.openParen] + (try lexMain(tail))
            case ")": return [.closeParen] + (try lexMain(tail))
            case "a"..."z": fallthrough
            case "A"..."Z": return try lexSym(es)
            case "0"..."9": return try lexNum(es)
            case "\0": return [] // success
            default: throw InternalError.unexpectedSymbol(entry, e)
            }
        }
        
        let es = (entry + "\0").map { $0 }
        return try lexMain(es)
    }
}

internal extension DatePattern {
    func secondPattern() -> NumberSet {
        return (try? second.toSecondPattern(hash)) ?? .none
    }
    func minutePattern() -> NumberSet {
        return (try? minute.toMinutePattern(hash)) ?? .none
    }
    func hourPattern() -> NumberSet {
        return (try? hour.toHourPattern(hash)) ?? .none
    }
    func dayOfMonthPattern(month: Int, year: Int) -> NumberSet {
        precondition(1...12 ~= month)
        let dayValue  = (try? dayOfMonth.toDayOfMonthPattern(month: month, year: year, hash: hash)) ?? .none
        let weekValue = (try? dayOfWeek.toDayOfWeekPattern(month: month, year: year, hash: hash)) ?? .none
        return .and(dayValue, weekValue)
    }
    func monthPattern() -> NumberSet {
        return (try? self.month.toMonthPattern()) ?? .none
    }
    func yearPattern() -> NumberSet {
        return (try? self.year.toYearPattern()) ?? .none
    }
}

public extension DatePattern {
    func next(_ date: CronDate = CronDate()) -> CronDate? {
        if !yearPattern().contains(date.year) {
            return nextYear(date)
        }

        if !monthPattern().contains(date.month) {
            return nextMonth(date)
        }

        if !dayOfMonthPattern(month: date.month, year: date.year).contains(date.day) {
            return nextDay(date)
        }

        if !hourPattern().contains(date.hour) {
            return nextHour(date)
        }

        if !minutePattern().contains(date.minute) {
            return nextMinute(date)
        }

        return nextSecond(date)
    }
}

internal extension DatePattern {
    private func nextYMD(_ year: Int, month: Int?) -> (Int, Int, Int)? {
        var y: Int = year
        var mo: Int? = month
        while true {
            if let m = mo {
                if let d = firstDay(month: m, year: y) {
                    return (y, m, d)
                }

                mo = monthPattern().next(m)
            } else {
                guard let ny = yearPattern().next(y) else {
                    return nil
                }
                y = ny
                mo = firstMonth()
            }
        }
        fatalError("unreachable")
    }

    func nextYear(_ date: CronDate) -> CronDate? {
        guard let nextYear = yearPattern().next(date.year) else {
            return nil
        }

        guard let ymd = nextYMD(nextYear, month: firstMonth()) else {
            return nil
        }

        guard let firstHour = firstHour(), let firstMinute = firstMinute(), let firstSecond = firstSecond() else {
            return nil
        }

        let (y, m, d) = ymd
        return CronDate(year: y, month: m, day: d,
            hour: firstHour, minute: firstMinute, second: firstSecond)
    }

    func nextMonth(_ date: CronDate) -> CronDate? {
        guard let nextMonth = monthPattern().next(date.month) else {
            return nextYear(date)
        }

        guard let ymd = nextYMD(date.year, month: nextMonth) else {
            return nil
        }

        guard let firstHour = firstHour(), let firstMinute = firstMinute(), let firstSecond = firstSecond() else {
            return nil
        }

        let (y, m, d) = ymd
        return CronDate(year: y, month: m, day: d,
            hour: firstHour, minute: firstMinute, second: firstSecond)
    }

    func nextDay(_ date: CronDate) -> CronDate? {
        guard let nextDay = dayOfMonthPattern(month: date.month, year: date.year).next(date.day) else {
            return nextMonth(date)
        }
        guard let firstHour = firstHour(), let firstMinute = firstMinute(), let firstSecond = firstSecond() else {
            return nil
        }
        return CronDate(year: date.year, month: date.month, day: nextDay,
            hour: firstHour, minute: firstMinute, second: firstSecond)
    }

    func nextHour(_ date: CronDate) -> CronDate? {
        guard let nextHour = hourPattern().next(date.hour) else {
            return nextDay(date)
        }
        guard let firstMinute = firstMinute(), let firstSecond = firstSecond() else {
            return nil
        }
        return CronDate(year: date.year, month: date.month, day: date.day,
            hour: nextHour, minute: firstMinute, second: firstSecond)
    }

    func nextMinute(_ date: CronDate) -> CronDate? {
        guard let nextMinute = minutePattern().next(date.minute) else {
            return nextHour(date)
        }
        guard let firstSecond = firstSecond() else {
            return nil
        }
        return CronDate(year: date.year, month: date.month, day: date.day,
            hour: date.hour, minute: nextMinute, second: firstSecond)
    }

    func nextSecond(_ date: CronDate) -> CronDate? {
        guard let nextSecond = secondPattern().next(date.second) else {
            return nextMinute(date)
        }
        return CronDate(year: date.year, month: date.month, day: date.day,
            hour: date.hour, minute: date.minute, second: nextSecond)
    }
}

fileprivate extension DatePattern {
    func firstMonth() -> Int? {
        return monthPattern().next(0)
    }
    func firstDay(month: Int, year: Int) -> Int? {
        return dayOfMonthPattern(month: month, year: year).next(0)
    }
    func firstHour() -> Int? {
        return hourPattern().next(-1)
    }
    func firstMinute() -> Int? {
        return minutePattern().next(-1)
    }
    func firstSecond() -> Int? {
        return secondPattern().next(-1)
    }
}

extension Cron.DatePattern: Codable {
    enum CodingKeys: String, CodingKey {
        case pattern
        case hash
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let p = try DatePattern(values.decode(String.self, forKey: .pattern))

        self.second     = p.second
        self.minute     = p.minute
        self.hour       = p.hour
        self.dayOfMonth = p.dayOfMonth
        self.month      = p.month
        self.dayOfWeek  = p.dayOfWeek
        self.year       = p.year
        self.hash       = try values.decode(Int64.self, forKey: .hash)
        self.string     = p.string
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(string, forKey: .pattern)
        try container.encode(hash, forKey: .hash)
    }
}


