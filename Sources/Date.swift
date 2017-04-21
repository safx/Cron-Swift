//
//  Date.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/21.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation

public struct Date {
    public let year     : Int
    public let month    : Int
    public let day      : Int
    public let hour     : Int
    public let minute   : Int
    public let second   : Int
}

public extension Cron.Date {
    init(date: Foundation.Date) {
        let calendar = Calendar.current
        self.year   = calendar.component(.year, from: date)
        self.month  = calendar.component(.month, from: date)
        self.day    = calendar.component(.day, from: date)
        self.hour   = calendar.component(.hour, from: date)
        self.minute = calendar.component(.minute, from: date)
        self.second = calendar.component(.second, from: date)
    }

    init() {
        self.init(date: Foundation.Date())
    }
}

public extension Cron.Date {
    var date: Foundation.Date? {
        let d = NSDateComponents()
        d.calendar = NSCalendar.current
        d.year   = self.year
        d.month  = self.month
        d.day    = self.day
        d.hour   = self.hour
        d.minute = self.minute
        d.second = self.second
        return d.date
    }
}
