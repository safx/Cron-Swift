//
//  NumberSet.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/20.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

internal enum NumberSet: Equatable {
    case none
    case any              // *
    case number(Int)      // 15
    case range(Int, Int)  // 3-9
    case step(Int, Int)   // 3/5
    indirect case or(NumberSet, NumberSet)  // ,
    indirect case and(NumberSet, NumberSet)
}

extension NumberSet {
    internal func contains(_ n: Int) -> Bool {
        switch self {
        case .none                     : return false
        case .any                      : return true
        case .number(let v)            : return v == n
        case .range(let begin, let end)  : return begin <= n && n <= end
        case .step(let offset, let step) : return 0 == (n - offset) % step
        case .or(let a, let b)           : return a.contains(n) || b.contains(n)
        case .and(let a, let b)          : return a.contains(n) && b.contains(n)
        }
    }
}

extension NumberSet {
    internal func next(_ n: Int) -> Int? {
        func _next_and(_ na: NumberSet, _ nb: NumberSet, _ a: Int?, _ b: Int?) -> Int? {
            guard let a = a, let b = b else { return nil }

            if a == b {
                return a
            } else if a < b {
                return _next_and(na, nb, na.next(a), b)
            } else {
                return _next_and(na, nb, a, nb.next(b))
            }
        }

        switch self {
        case .none:
            return nil
        case .any:
            return n + 1
        case .number(let v):
            return n < v ? v : nil
        case .range(let begin, _):
            if contains(n + 1) {
                return n + 1
            }
            return n < begin ? begin : nil
        case .step(let offset, let step):
            let d = Int(ceil(Double(n + 1 - offset) / Double(step)))
            return d * step + offset
        case .or(let a, let b):
            switch (a.next(n), b.next(n)) {
            case (let x?, let y?): return min(x, y)
            case (let x?, nil   ): return x
            case (nil   , let y?): return y
            case (nil   , nil   ): return nil
            }
        case .and(let a, let b):
            return _next_and(a, b, a.next(n), b.next(n))
        }
    }
}
