//
//  DateGenerator.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation

public struct DateGenerator {
    let pattern: DatePattern
    let hash: Int64
    let date: Cron.Date

    internal init(pattern: DatePattern, hash: Int64, date: Cron.Date) {
        self.pattern = pattern
        self.hash = hash
        self.date = date
    }

    public init(pattern: DatePattern, hash: Int64 = 0, date: Foundation.Date = Foundation.Date()) {
        self.init(pattern: pattern, hash: hash, date: Cron.Date(date: date))
    }
}

extension DateGenerator: IteratorProtocol {
    public typealias Element = Foundation.Date

    mutating public func next() -> Element? {
        guard let next = pattern.next(date) else {
            return nil
        }

        self = DateGenerator(pattern: self.pattern, hash: self.hash, date: next)
        return next.date
    }
}
