//
//  Date.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/11/21.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

internal struct Date {
    let year     : Int
    let month    : Int
    let day      : Int
    let hour     : Int
    let minute   : Int
    let second   : Int
}

extension Date {
    init(date: NSDate) {
        let unit: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let d = NSCalendar.currentCalendar().components(unit, fromDate: date)
        self.year   = d.year
        self.month  = d.month
        self.day    = d.day
        self.hour   = d.hour
        self.minute = d.minute
        self.second = d.second
    }
}

extension Date {
    var date: NSDate? {
        let d = NSDateComponents()
        d.year   = self.year
        d.month  = self.month
        d.day    = self.day
        d.hour   = self.hour
        d.minute = self.minute
        d.second = self.second
        return NSCalendar.currentCalendar().dateFromComponents(d)
    }
}
