//
//  DateGenerator.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

public struct DateGenerator {
    let pattern: DatePattern
    let hash: Int64
    let date: Date

    internal init(pattern: DatePattern, hash: Int64, date: Date) {
        self.pattern = pattern
        self.hash = hash
        self.date = date
    }

    public init(pattern: DatePattern, hash: Int64 = 0, date: NSDate = NSDate()) {
        self.init(pattern: pattern, hash: hash, date: Date(date: date))
    }
}

extension DateGenerator: IteratorProtocol {
    public typealias Element = NSDate

    mutating public func next() -> Element? {
        guard let next = pattern.next(date) else {
            return nil
        }

        self = DateGenerator(pattern: self.pattern, hash: self.hash, date: next)
        return next.date
    }
}
