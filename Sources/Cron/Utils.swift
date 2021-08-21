//
//  Utils.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

enum InternalError: Error {
    case unexpectedSymbol(String, Character)
    case unrecognizedSymbol(String, String)
    case outOfRange
    case parseError
}


public enum DayOfWeek: Int {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
}

internal enum Month: Int {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
}

internal func getLastDayOfMonth(month: Int, year: Int) -> Int {
    precondition(1...12 ~= month)
    let isLeapYear = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    let ms = [31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return ms[month - 1]
}

internal func getDayOfWeek(day: Int, month: Int, year: Int) -> DayOfWeek {
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

public enum CronFieldType: Equatable {
    case number
    case range
    case step
    case composited
}

internal enum NumberType: Equatable {
    case raw
    case doW
    case month
}

internal enum Token: Equatable {
    case number(Int, NumberType)
    case wildcard
    case slash
    case hyphen
    case numberSign
    case openParen
    case closeParen
    case h
    case l
    case w
    case lW
    case end
}
