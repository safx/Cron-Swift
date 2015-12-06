//
//  NumberSet.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/20.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

internal enum NumberSet {
    case None
    case Any              // *
    case Number(Int)      // 15
    case Range(Int, Int)  // 3-9
    case Step(Int, Int)   // 3/5
    indirect case Or(NumberSet, NumberSet)  // ,
    indirect case And(NumberSet, NumberSet)
}

extension NumberSet {
    internal func contains(n: Int) -> Bool {
        switch self {
        case .None                     : return false
        case .Any                      : return true
        case .Number(let v)            : return v == n
        case .Range(let (begin, end))  : return begin <= n && n <= end
        case .Step(let (offset, step)) : return 0 == (n - offset) % step
        case .Or(let (a, b))           : return a.contains(n) || b.contains(n)
        case .And(let (a, b))          : return a.contains(n) && b.contains(n)
        }
    }
}

extension NumberSet {
    internal func next(n: Int) -> Int? {
        func _next_and(na: NumberSet, _ nb: NumberSet, _ a: Int?, _ b: Int?) -> Int? {
            guard let a = a, b = b else { return nil }

            if a == b {
                return a
            } else if a < b {
                return _next_and(na, nb, na.next(a), b)
            } else {
                return _next_and(na, nb, a, nb.next(b))
            }
        }

        switch self {
        case .None:
            return nil
        case .Any:
            return n + 1
        case .Number(let v):
            return n < v ? v : nil
        case .Range(let begin, _):
            if contains(n + 1) {
                return n + 1
            }
            return n < begin ? begin : nil
        case .Step(let offset, let step):
            let d = Int(ceil(Double(n + 1 - offset) / Double(step)))
            return d * step + offset
        case .Or(let (a, b)):
            switch (a.next(n), b.next(n)) {
            case (let x?, let y?): return min(x, y)
            case (let x?, nil   ): return x
            case (nil   , let y?): return y
            case (nil   , nil   ): return nil
            }
        case .And(let (a, b)):
            return _next_and(a, b, a.next(n), b.next(n))
        }
    }
}
