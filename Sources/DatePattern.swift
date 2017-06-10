//
//  Date.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/22.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

public struct DatePattern {
    internal let second    : FieldPattern
    internal let minute    : FieldPattern
    internal let hour      : FieldPattern
    internal let dayOfMonth: FieldPattern
    internal let month     : FieldPattern
    internal let dayOfWeek : FieldPattern
    internal let year      : FieldPattern
    internal let hash      : Int64
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
    public init(string: String) throws {
        let p = try parseExpression(string)
        self.second = p.second
        self.minute = p.minute
        self.hour = p.hour
        self.dayOfMonth = p.dayOfMonth
        self.month = p.month
        self.dayOfWeek = p.dayOfWeek
        self.year = p.year
        self.hash = p.hash
    }

    func next(_ date: Date = Date()) -> Date? {
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

    func nextYear(_ date: Date) -> Date? {
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
        return Date(year: y, month: m, day: d,
            hour: firstHour, minute: firstMinute, second: firstSecond)
    }

    func nextMonth(_ date: Date) -> Date? {
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
        return Date(year: y, month: m, day: d,
            hour: firstHour, minute: firstMinute, second: firstSecond)
    }

    func nextDay(_ date: Date) -> Date? {
        guard let nextDay = dayOfMonthPattern(month: date.month, year: date.year).next(date.day) else {
            return nextMonth(date)
        }
        guard let firstHour = firstHour(), let firstMinute = firstMinute(), let firstSecond = firstSecond() else {
            return nil
        }
        return Date(year: date.year, month: date.month, day: nextDay,
            hour: firstHour, minute: firstMinute, second: firstSecond)
    }

    func nextHour(_ date: Date) -> Date? {
        guard let nextHour = hourPattern().next(date.hour) else {
            return nextDay(date)
        }
        guard let firstMinute = firstMinute(), let firstSecond = firstSecond() else {
            return nil
        }
        return Date(year: date.year, month: date.month, day: date.day,
            hour: nextHour, minute: firstMinute, second: firstSecond)
    }

    func nextMinute(_ date: Date) -> Date? {
        guard let nextMinute = minutePattern().next(date.minute) else {
            return nextHour(date)
        }
        guard let firstSecond = firstSecond() else {
            return nil
        }
        return Date(year: date.year, month: date.month, day: date.day,
            hour: date.hour, minute: nextMinute, second: firstSecond)
    }

    func nextSecond(_ date: Date) -> Date? {
        guard let nextSecond = secondPattern().next(date.second) else {
            return nextMinute(date)
        }
        return Date(year: date.year, month: date.month, day: date.day,
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
