//
//  FieldPattern.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/22.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

typealias CronNumberType = Int

enum FieldPattern {
    case Any                    // *
    case Number(CronNumberType) // 4
    case Hash                   // H
    case RangedHash(Int, Int)   // H(1-5)
    indirect case Step(FieldPattern, Int)               // /
    indirect case Range(CronNumberType, CronNumberType) // -

    // Available in day of month field
    case LastDayOfMonth      // L
    case LastWeekdayOfMonth  // LW
    case Weekday(Int)        // 15W

    // Available in day of week field
    case LastDayOfWeek(DayOfWeek)     // 5L
    case NthDayOfWeek(DayOfWeek, Int) // 3#2

    indirect case Or([FieldPattern]) // ,
}

extension FieldPattern {
    var type: CronFieldType {
        switch self {
        case .Any: return .Range
        case .Range: return .Range

        case .Step: return .Step

        case .Or:
            assertionFailure("unreachable")
            return .Composited

        default: return .Number
        }
    }
}

extension FieldPattern {

    internal func toSecondPattern(hash: Int64) throws -> NumberSet {
        return try getRangedPattern(max: 60, hash: hash)
    }

    internal func toMinutePattern(hash: Int64) throws -> NumberSet {
        return try getRangedPattern(max: 60, hash: hash)
    }

    internal func toHourPattern(hash: Int64) throws -> NumberSet {
        return try getRangedPattern(max: 24, hash: hash)
    }

    internal func toDayOfMonthPattern(month month: Int, year: Int, hash: Int64) throws -> NumberSet {
        precondition(1...12 ~= month)
        let nDays = lastDayOfMonth(month: month, year: year)

        func isWorkday(dow: DayOfWeek) -> Bool {
            return [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday].contains(dow)
        }
        func getWorkDays() -> [Int] {
            return (1...nDays).filter{ isWorkday(getDayOfWeek(day: $0, month: month, year: year)) }
        }

        return try getPattern { e in
            switch e {
            case .Any:
                return .Range(1, nDays)
            case .LastDayOfMonth:
                return .Number(nDays)
            case .LastWeekdayOfMonth:
                if let e = getWorkDays().last {
                    return .Number(e)
                }
                preconditionFailure("Unreached")
            case .Weekday(let n):
                if let e = getWorkDays().dropFirst(n).first {
                    return .Number(e)
                }
                return .None
            default:
                return nil
            }
        }
    }
    
    internal func toMonthPattern() throws -> NumberSet {
        let v = try getPattern { e in
            switch e {
            case .Any: return .Range(1, 12)
            default:   return nil
            }
        }
        return .And(v, .Range(1, 12))
    }

    internal func toDayOfWeekPattern(month month: Int, year: Int, hash: Int64) throws -> NumberSet {
        precondition(1...12 ~= month)
        let nDays = lastDayOfMonth(month: month, year: year)
        func getDoWDays(dw: DayOfWeek) -> [Int] {
            return (1...nDays).filter{ getDayOfWeek(day: $0, month: month, year: year) == dw }
        }
        return try getPattern { e in
            switch e {
            case .Any:
                return .Range(1, nDays)
            case let .LastDayOfWeek(dw):
                if let e = getDoWDays(dw).last {
                    return .Number(e)
                }
                preconditionFailure("Unreached")
            case let .NthDayOfWeek(dw, n):
                if let e = getDoWDays(dw).dropFirst(n).first {
                    return .Number(e)
                }
                return .None
            case .Number(let dw):
                if let e = getDoWDays(DayOfWeek(rawValue: dw)!).first {
                    return .Step(e, 7)
                }
                return .None
            case Range(let begin, let end): // MON-FRI
                let ret = (begin...end).reduce(.None) { NumberSet.Or($0, .Step($1, 7)) }
                print(ret)
                return ret
            default:
                return nil
            }
        }
    }

    internal func toYearPattern() throws -> NumberSet {
        return try getPattern { e in
            switch e {
            case .Any: return .Any
            default:   return  nil
            }
        }
    }
    
    // MARK: inner imprementation

    internal func getRangedPattern(max max: Int, hash: Int64) throws -> NumberSet {
        let v = try getPattern { e in
            switch e {
            case .Any: return .Range(0, max - 1)
            case .Hash: return .Number(Int(hash % Int64(max)))
            case .RangedHash(let b, let e):
                guard b < e else {
                    return .None
                }
                return .Number(Int(hash % Int64(e - b) + b))
            default:
                return nil
            }
        }
        return .And(v, .Range(0, max - 1))
    }


    internal func getPattern(closure: (FieldPattern) -> NumberSet?) throws -> NumberSet {
        if let result = closure(self) {
            return result
        }

        // default behaviors
        switch self {
        case Number(let num):
            return .Number(num)
        case Step(let p, let step):
            switch try p.getPattern(closure) {
            case .Number(let n): return .Step(n, step)
            case .Range(let b, let e):
                if b < e {
                    return .And(.Range(b, e), .Step(b, step))
                } else if b == e {
                    return .And(.Number(b), .Step(b, step))
                }
                return .None
            default:
                throw InternalError.ParseError
            }
        case Range(let begin, let end):
            return .Range(begin, end)
        case Or(let ps):
            guard let first = ps.first else { return .None }
            let head = try first.getPattern(closure)
            let tail = Array(ps.dropFirst(1))
            guard tail.count > 0 else {
                return head
            }

            return try tail.map{ try $0.getPattern(closure) }
                .reduce(head) { (a, e) -> NumberSet in
                    return .Or(a, e)
            }
        default:
            throw InternalError.ParseError
        }
    }

    internal func validate(range range: Swift.Range<Int>, validPatternTypes: [FieldPattern], validNumberTypes: Int) -> Bool {
        switch self {
        // TODO: check Feb or May?
        //case Number(let n):
        case Range(let s, let e):
            return range.contains(s) && range.contains(e) && s <= e
        case Step(let p, let step):
            return p.validate(range: range, validPatternTypes: validPatternTypes, validNumberTypes: validNumberTypes) && [.Number, .Range].contains(p.type) && range.contains(step)
        case Or(let ps):
            return ps.reduce(true) { $0 && $1.validate(range: range, validPatternTypes: validPatternTypes, validNumberTypes: validNumberTypes) }
        default: return true
        }
    }
}

enum CronFieldType {
    case Number
    case Range
    case Step
    case Composited
}
