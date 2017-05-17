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

public struct CronJob {
    public let pattern: DatePattern
    let job: () -> Void

    public init(pattern: String, hash: Int64 = 0, job: @escaping () -> Void) throws {
        self.pattern = try parseExpression(pattern, hash: hash)
        self.job = job

        start()
    }

    public func start() {
        let date = Cron.Date(date: Foundation.Date())

        guard let next = pattern.next(date)?.date else {
            print("none")
            return
        }

        let interval = next.timeIntervalSinceNow
        print(next, interval)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { () -> () in
            self.job()
            self.start()
        }
    }
}
