//
//  FieldPattern.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/22.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

public typealias CronNumberType = Int

public enum FieldPattern {
    case any                    // *
    case number(CronNumberType) // 4
    case hash                   // H
    case rangedHash(Int, Int)   // H(1-5)
    indirect case step(FieldPattern, Int)               // /
    indirect case range(CronNumberType, CronNumberType) // -

    // Available in day of month field
    case lastDayOfMonth      // L
    case lastWeekdayOfMonth  // LW
    case weekday(Int)        // 15W

    // Available in day of week field
    case lastDayOfWeek(DayOfWeek)     // 5L
    case nthDayOfWeek(DayOfWeek, Int) // 3#2

    indirect case or([FieldPattern]) // ,
}

extension FieldPattern {
    var type: CronFieldType {
        switch self {
        case .any: return .range
        case .range: return .range

        case .step: return .step

        case .or:
            assertionFailure("unreachable")
            return .composited

        default: return .number
        }
    }
}

extension FieldPattern {

    internal func toSecondPattern(_ hash: Int64) throws -> NumberSet {
        return try getRangedPattern(max: 60, hash: hash)
    }

    internal func toMinutePattern(_ hash: Int64) throws -> NumberSet {
        return try getRangedPattern(max: 60, hash: hash)
    }

    internal func toHourPattern(_ hash: Int64) throws -> NumberSet {
        return try getRangedPattern(max: 24, hash: hash)
    }

    internal func toDayOfMonthPattern(month: Int, year: Int, hash: Int64) throws -> NumberSet {
        precondition(1...12 ~= month)
        let nDays = getLastDayOfMonth(month: month, year: year)

        func isWorkday(_ dow: DayOfWeek) -> Bool {
            return [.monday, .tuesday, .wednesday, .thursday, .friday].contains(dow)
        }
        func getWorkDays() -> [Int] {
            return (1...nDays).filter{ isWorkday(getDayOfWeek(day: $0, month: month, year: year)) }
        }

        return try getPattern { e in
            switch e {
            case .any:
                return .range(1, nDays)
            case .lastDayOfMonth:
                return .number(nDays)
            case .lastWeekdayOfMonth:
                if let e = getWorkDays().last {
                    return .number(e)
                }
                preconditionFailure("Unreached")
            case .weekday(let n):
                if let e = getWorkDays().dropFirst(n).first {
                    return .number(e)
                }
                return .none
            default:
                return nil
            }
        }
    }
    
    internal func toMonthPattern() throws -> NumberSet {
        let v = try getPattern { e in
            switch e {
            case .any: return .range(1, 12)
            default:   return nil
            }
        }
        return .and(v, .range(1, 12))
    }

    internal func toDayOfWeekPattern(month: Int, year: Int, hash: Int64) throws -> NumberSet {
        precondition(1...12 ~= month)
        let nDays = getLastDayOfMonth(month: month, year: year)
        func getDoWDays(_ dw: DayOfWeek) -> [Int] {
            return (1...nDays).filter{ getDayOfWeek(day: $0, month: month, year: year) == dw }
        }
        return try getPattern { e in
            switch e {
            case .any:
                return .range(1, nDays)
            case let .lastDayOfWeek(dw):
                if let e = getDoWDays(dw).last {
                    return .number(e)
                }
                preconditionFailure("Unreached")
            case let .nthDayOfWeek(dw, n):
                if let e = getDoWDays(dw).dropFirst(n).first {
                    return .number(e)
                }
                return .none
            case .number(let dw):
                if let e = getDoWDays(DayOfWeek(rawValue: dw)!).first {
                    return .step(e, 7)
                }
                return .none
            case .range(let begin, let end): // MON-FRI
                let ret = (begin...end).reduce(.none) { NumberSet.or($0, .step($1, 7)) }
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
            case .any: return .any
            default:   return  nil
            }
        }
    }
    
    // MARK: inner imprementation

    internal func getRangedPattern(max: Int, hash: Int64) throws -> NumberSet {
        let v = try getPattern { e in
            switch e {
            case .any: return .range(0, max - 1)
            case .hash: return .number(Int(hash % Int64(max)))
            case .rangedHash(let b, let e):
                guard b < e else {
                    return .none
                }
                return .number(Int(Int64(hash) % Int64(e - b) + Int64(b)))
            default:
                return nil
            }
        }
        return .and(v, .range(0, max - 1))
    }


    internal func getPattern(_ closure: @escaping (FieldPattern) -> NumberSet?) throws -> NumberSet {
        if let result = closure(self) {
            return result
        }

        // default behaviors
        switch self {
        case .number(let num):
            return .number(num)
        case .step(let p, let step):
            switch try p.getPattern(closure) {
            case .number(let n): return .step(n, step)
            case .range(let b, let e):
                if b < e {
                    return .and(.range(b, e), .step(b, step))
                } else if b == e {
                    return .and(.number(b), .step(b, step))
                }
                return .none
            default:
                throw InternalError.parseError
            }
        case .range(let begin, let end):
            return .range(begin, end)
        case .or(let ps):
            guard let first = ps.first else { return .none }
            let head = try first.getPattern(closure)
            let tail = Array(ps.dropFirst(1))
            guard tail.count > 0 else {
                return head
            }

            return try tail.map{ try $0.getPattern(closure) }
                .reduce(head) { (a, e) -> NumberSet in
                    return .or(a, e)
            }
        default:
            throw InternalError.parseError
        }
    }

    internal func validate(range: Swift.Range<Int>, validPatternTypes: [FieldPattern], validNumberTypes: Int) -> Bool {
        switch self {
        // TODO: check Feb or May?
        //case Number(let n):
        case .range(let s, let e):
            return range.contains(s) && range.contains(e) && s <= e
        case .step(let p, let step):
            return p.validate(range: range, validPatternTypes: validPatternTypes, validNumberTypes: validNumberTypes) && [.number, .range].contains(p.type) && range.contains(step)
        case .or(let ps):
            return ps.reduce(true) { $0 && $1.validate(range: range, validPatternTypes: validPatternTypes, validNumberTypes: validNumberTypes) }
        default: return true
        }
    }
}
