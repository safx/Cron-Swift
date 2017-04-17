//
//  Parser.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/01.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation

public func parseExpression(_ expr: String, hash: Int64 = 0) throws -> DatePattern {
    let fields = expr.components(separatedBy: CharacterSet.whitespaces)
                     .filter { $0.characters.count > 0 }

    guard (5...7).contains(fields.count) else {
        throw InternalError.parseError
    }

    let patterns = try fields.map(parseField)
                             .map { e -> FieldPattern in
                                precondition(e.count > 0)
                                return e.count == 1 ?  e.first! : FieldPattern.or(e)
                             }

    let appendedPatterns = (patterns.count <= 5 ? [.hash] : []) + patterns + (patterns.count <= 6 ? [.any] : [])
    precondition(appendedPatterns.count == 7)

    return DatePattern(
        second     : appendedPatterns[0],
        minute     : appendedPatterns[1],
        hour       : appendedPatterns[2],
        dayOfMonth : appendedPatterns[3],
        month      : appendedPatterns[4],
        dayOfWeek  : appendedPatterns[5],
        year       : appendedPatterns[6],
        hash       : hash)
}

func parseField(string: String) throws -> [FieldPattern] {
    return try string.components(separatedBy: ",")
                     .map(lex)
                     .map(parseFieldPattern)
}

internal func parseFieldPattern(ts: [Token]) throws -> FieldPattern {
    guard let first = ts.first else { throw InternalError.parseError }
    guard let second: Token = ts.count > 1 ? ts[1] : nil else {
        switch (first) {
        case .wildcard: return .any
        case .number(let num): return .number(num.0)
        case .h: return .hash
        case .l: return .lastDayOfMonth
        case .lW: return .lastWeekdayOfMonth
        default: ()
        }
        throw InternalError.parseError
    }

    guard let third: Token = ts.count > 2 ? ts[2] : nil else {
        switch (first, second) {
        case let (.slash, .number(step)):
            return .step(.any, step.0)
        case let (.number(dow), .l):
            guard 0...7 ~= dow.0 else {
                throw InternalError.parseError
            }
            return .lastDayOfWeek(DayOfWeek(rawValue: dow.0 % 7)!)
        case let (.number(num), .w):
            return .weekday(num.0)
        default:
            throw InternalError.parseError
        }
    }

    guard let forth: Token = ts.count > 3 ? ts[3] : nil else {
        switch (first, second, third) {
        case let (.number(begin), .hyphen, .number(end)):
            return .range(begin.0, end.0)
        case let (.wildcard, .slash, .number(step)):
            return .step(.any, step.0)
        case let (.number(num), .slash, .number(step)):
            return .step(.number(num.0), step.0)
        case let (.h, .hyphen, .number(step)):
            return .step(.hash, step.0)
        case let (.number(dow), .numberSign, .number(num)):
            guard 0...7 ~= dow.0 else {
                throw InternalError.parseError
            }
            return .nthDayOfWeek(DayOfWeek(rawValue: dow.0 % 7)!, num.0)
        default:
            throw InternalError.parseError
        }
    }

    guard let fifth: Token = ts.count > 4 ? ts[4] : nil else {
        throw InternalError.parseError
    }

    guard let sixth: Token = ts.count > 5 ? ts[5] : nil else {
        switch (first, second, third, forth, fifth) {
        case let (.number(begin), .hyphen, .number(end), .slash, .number(step)):
            return .step(.range(begin.0, end.0), step.0)
        default:
            throw InternalError.parseError
        }
    }

    guard let seventh: Token = ts.count > 6 ? ts[6] : nil else {
        switch (first, second, third, forth, fifth, sixth) {
        case let (.h, .openParen, .number(begin), .hyphen, .number(end), .closeParen):
            return .rangedHash(begin.0, end.0)
        default:
            throw InternalError.parseError
        }
    }

    guard let eighth: Token = ts.count > 7 ? ts[7] : nil else {
        throw InternalError.parseError
    }

    guard let _: Token = ts.count > 8 ? ts[8] : nil else {
        switch (first, second, third, forth, fifth, sixth, seventh, eighth) {
        case let (.h, .openParen, .number(begin), .hyphen, .number(end), .closeParen, .slash, .number(step)):
            return .step(.rangedHash(begin.0, end.0), step.0)
        default:
            throw InternalError.parseError
        }
    }

    throw InternalError.parseError
}

internal func lex(entry: String) throws -> [Token] {
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

        switch s.uppercased() {
        case "H": return [.h] + (try lexMain(es))
        case "L": return [.l] + (try lexMain(es))
        case "W": return [.w] + (try lexMain(es))
        case "LW": return [.lW] + (try lexMain(es))
        case "SUN": return [.number(0, .doW)] + (try lexMain(es))
        case "MON": return [.number(1, .doW)] + (try lexMain(es))
        case "TUE": return [.number(2, .doW)] + (try lexMain(es))
        case "WED": return [.number(3, .doW)] + (try lexMain(es))
        case "THU": return [.number(4, .doW)] + (try lexMain(es))
        case "FRI": return [.number(5, .doW)] + (try lexMain(es))
        case "SAT": return [.number(6, .doW)] + (try lexMain(es))
        case "JAN": return [.number(1, .month)] + (try lexMain(es))
        case "FEB": return [.number(2, .month)] + (try lexMain(es))
        case "MAR": return [.number(3, .month)] + (try lexMain(es))
        case "APR": return [.number(4, .month)] + (try lexMain(es))
        case "MAY": return [.number(5, .month)] + (try lexMain(es))
        case "JUN": return [.number(6, .month)] + (try lexMain(es))
        case "JUL": return [.number(7, .month)] + (try lexMain(es))
        case "AUG": return [.number(8, .month)] + (try lexMain(es))
        case "SEP": return [.number(9, .month)] + (try lexMain(es))
        case "OCT": return [.number(10, .month)] + (try lexMain(es))
        case "NOV": return [.number(11, .month)] + (try lexMain(es))
        case "DEC": return [.number(12, .month)] + (try lexMain(es))
        default: throw InternalError.unrecognizedSymbol(entry, s)
        }
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

    let es = (entry + "\0").characters.map { $0 }
    return try lexMain(es)
}

internal enum NumberType {
    case raw
    case doW
    case month
}

internal enum Token {
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
