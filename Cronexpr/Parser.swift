//
//  Parser.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/01.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//


func parseExpression(expr: String, hash: Int64 = 0) throws -> DatePattern {
    let fields = expr.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                     .filter { $0.characters.count > 0 }

    guard (5...7).contains(fields.count) else {
        throw InternalError.ParseError
    }

    let patterns = try fields.map(parseField)
                             .map { e -> FieldPattern in
                                precondition(e.count > 0)
                                return e.count == 1 ?  e.first! : FieldPattern.Or(e)
                             }

    let appendedPatterns = (patterns.count <= 5 ? [.Hash] : []) + patterns + (patterns.count <= 6 ? [.Any] : [])
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
    return try string.componentsSeparatedByString(",")
                     .map(lex)
                     .map(parseFieldPattern)
}

internal func parseFieldPattern(ts: [Token]) throws -> FieldPattern {
    guard let first = ts.first else { throw InternalError.ParseError }
    guard let second: Token = ts.count > 1 ? ts[1] : nil else {
        switch (first) {
        case .Wildcard: return .Any
        case .Number(let num): return .Number(num.0)
        case .H: return .Hash
        case .L: return .LastDayOfMonth
        case .LW: return .LastWeekdayOfMonth
        default: ()
        }
        throw InternalError.ParseError
    }

    guard let third: Token = ts.count > 2 ? ts[2] : nil else {
        switch (first, second) {
        case let (.Slash, .Number(step)):
            return .Step(.Any, step.0)
        case let (.Number(dow), .L):
            guard 0...7 ~= dow.0 else {
                throw InternalError.ParseError
            }
            return .LastDayOfWeek(DayOfWeek(rawValue: dow.0 % 7)!)
        case let (.Number(num), .W):
            return .Weekday(num.0)
        default:
            throw InternalError.ParseError
        }
    }

    guard let forth: Token = ts.count > 3 ? ts[3] : nil else {
        switch (first, second, third) {
        case let (.Number(begin), .Hyphen, .Number(end)):
            return .Range(begin.0, end.0)
        case let (.Wildcard, .Slash, .Number(step)):
            return .Step(.Any, step.0)
        case let (.Number(num), .Slash, .Number(step)):
            return .Step(.Number(num.0), step.0)
        case let (.H, .Hyphen, .Number(step)):
            return .Step(.Hash, step.0)
        case let (.Number(dow), .NumberSign, .Number(num)):
            guard 0...7 ~= dow.0 else {
                throw InternalError.ParseError
            }
            return .NthDayOfWeek(DayOfWeek(rawValue: dow.0 % 7)!, num.0)
        default:
            throw InternalError.ParseError
        }
    }

    guard let fifth: Token = ts.count > 4 ? ts[4] : nil else {
        throw InternalError.ParseError
    }

    guard let sixth: Token = ts.count > 5 ? ts[5] : nil else {
        switch (first, second, third, forth, fifth) {
        case let (.Number(begin), .Hyphen, .Number(end), .Slash, .Number(step)):
            return .Step(.Range(begin.0, end.0), step.0)
        default:
            throw InternalError.ParseError
        }
    }

    guard let seventh: Token = ts.count > 6 ? ts[6] : nil else {
        switch (first, second, third, forth, fifth, sixth) {
        case let (.H, .OpenParen, .Number(begin), .Hyphen, .Number(end), .CloseParen):
            return .RangedHash(begin.0, end.0)
        default:
            throw InternalError.ParseError
        }
    }

    guard let eighth: Token = ts.count > 7 ? ts[7] : nil else {
        throw InternalError.ParseError
    }

    guard let _: Token = ts.count > 8 ? ts[8] : nil else {
        switch (first, second, third, forth, fifth, sixth, seventh, eighth) {
        case let (.H, .OpenParen, .Number(begin), .Hyphen, .Number(end), .CloseParen, .Slash, .Number(step)):
            return .Step(.RangedHash(begin.0, end.0), step.0)
        default:
            throw InternalError.ParseError
        }
    }

    throw InternalError.ParseError
}

internal func lex(entry: String) throws -> [Token] {
    func lexNum(es: [Character], n: Int = 0) throws -> [Token] {
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
            return [.Number(n, .Raw)] + (try lexMain(es))
        }
    }

    func lexSym(es: [Character], s: String = "") throws -> [Token] {
        guard let e = es.first else {
            return []
        }
        let tail = Array(es.dropFirst(1))

        switch e {
        case "a"..."z": fallthrough
        case "A"..."Z": return try lexSym(tail, s: s + String(e))
        default: ()
        }

        switch s.uppercaseString {
        case "H": return [.H] + (try lexMain(es))
        case "L": return [.L] + (try lexMain(es))
        case "W": return [.W] + (try lexMain(es))
        case "LW": return [.LW] + (try lexMain(es))
        case "SUN": return [.Number(0, .DoW)] + (try lexMain(es))
        case "MON": return [.Number(1, .DoW)] + (try lexMain(es))
        case "TUE": return [.Number(2, .DoW)] + (try lexMain(es))
        case "WED": return [.Number(3, .DoW)] + (try lexMain(es))
        case "THU": return [.Number(4, .DoW)] + (try lexMain(es))
        case "FRI": return [.Number(5, .DoW)] + (try lexMain(es))
        case "SAT": return [.Number(6, .DoW)] + (try lexMain(es))
        case "JAN": return [.Number(1, .Month)] + (try lexMain(es))
        case "FEB": return [.Number(2, .Month)] + (try lexMain(es))
        case "MAR": return [.Number(3, .Month)] + (try lexMain(es))
        case "APR": return [.Number(4, .Month)] + (try lexMain(es))
        case "MAY": return [.Number(5, .Month)] + (try lexMain(es))
        case "JUN": return [.Number(6, .Month)] + (try lexMain(es))
        case "JUL": return [.Number(7, .Month)] + (try lexMain(es))
        case "AUG": return [.Number(8, .Month)] + (try lexMain(es))
        case "SEP": return [.Number(9, .Month)] + (try lexMain(es))
        case "OCT": return [.Number(10, .Month)] + (try lexMain(es))
        case "NOV": return [.Number(11, .Month)] + (try lexMain(es))
        case "DEC": return [.Number(12, .Month)] + (try lexMain(es))
        default: throw InternalError.UnrecognizedSymbol(entry, s)
        }
    }

    func lexMain(es: [Character]) throws -> [Token] {
        guard let e = es.first else {
            return []
        }
        let tail = Array(es.dropFirst(1))

        switch e {
        case "*": fallthrough
        case "?": return [.Wildcard] + (try lexMain(tail))
        case "-": return [.Hyphen] + (try lexMain(tail))
        case "/": return [.Slash] + (try lexMain(tail))
        case "#": return [.NumberSign] + (try lexMain(tail))
        case "(": return [.OpenParen] + (try lexMain(tail))
        case ")": return [.CloseParen] + (try lexMain(tail))
        case "a"..."z": fallthrough
        case "A"..."Z": return try lexSym(es)
        case "0"..."9": return try lexNum(es)
        case "\0": return [] // success
        default: throw InternalError.UnexpectedSymbol(entry, e)
        }
    }

    let es = (entry + "\0").characters.map { $0 }
    return try lexMain(es)
}

internal enum NumberType {
    case Raw
    case DoW
    case Month
}

internal enum Token {
    case Number(Int, NumberType)
    case Wildcard
    case Slash
    case Hyphen
    case NumberSign
    case OpenParen
    case CloseParen
    case H
    case L
    case W
    case LW
    case End
}
