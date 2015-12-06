//
//  Utils.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

enum InternalError: ErrorType {
    case UnexpectedSymbol(String, Character)
    case UnrecognizedSymbol(String, String)
    case OutOfRange
    case ParseError
}


internal enum DayOfWeek: Int {
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
}

internal enum Month: Int {
    case January = 1
    case February = 2
    case March = 3
    case April = 4
    case May = 5
    case June = 6
    case July = 7
    case August = 8
    case September = 9
    case October = 10
    case November = 11
    case December = 12
}

internal func lastDayOfMonth(month month: Int, year: Int) -> Int {
    precondition(1...12 ~= month)
    let isLeapYear = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    let ms = [31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return ms[month - 1]
}

internal func getDayOfWeek(day day: Int, month: Int, year: Int) -> DayOfWeek {
    precondition(1...31 ~= day)
    precondition(1...12 ~= month)
    // https://en.wikipedia.org/wiki/Zeller%27s_congruence
    let junOrFeb = month <= 2
    let q = day
    let m = junOrFeb ? month + 12 : month
    let y = junOrFeb ? year - 1 : year
    let K = y % 100
    let J = y / 100
    let h = (q + ((13 * (m + 1)) / 5) + K + (K / 4) + (J / 4) - 2 * J) % 7
    let d = (h + 6) % 7
    assert(0...6 ~= d)
    return DayOfWeek(rawValue: d)!
}
