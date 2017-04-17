//
//  CronJob.swift
//  Cronexpr
//
//  Created by Safx Developer on 2015/12/06.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

#if os(Linux)
import Dispatch
#endif

import Foundation

public typealias NSDate = Foundation.Date

public struct CronJob {
    let pattern: DatePattern
    let job: () -> Void

    public init(pattern: String, hash: Int64 = 0, job: @escaping () -> Void) throws {
        self.pattern = try parseExpression(pattern, hash: hash)
        self.job = job

        start()
    }

    public func start() {
        let date = Date(date: NSDate())

        guard let next = pattern.next(date)?.date else {
            print("none")
            return
        }

        let interval = next.timeIntervalSinceNow
        print(next, interval)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { () -> () in
        // dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(USEC_PER_SEC * UInt64(1000.0 * interval))), dispatch_get_main_queue()) { () -> Void in
            self.job()
            self.start()
        }
    }
}
