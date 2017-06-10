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
    let queue: DispatchQueue

    public init(pattern: String, hash: Int64 = 0, job: @escaping () -> Void) throws {
        self.pattern = try parseExpression(pattern, hash: hash)
        self.job = job
        self.queue = DispatchQueue.main

        start()
    }

    public init(pattern: String, queue: DispatchQueue, hash: Int64 = 0, job: @escaping () -> Void) throws {
        self.pattern = try parseExpression(pattern, hash: hash)
        self.job = job
        self.queue = queue

        start()
    }

    public func start() {
        let date = Cron.Date(date: Foundation.Date())

        guard let next = pattern.next(date)?.date else {
            print("No next execution date could be determined")
            return
        }

        let interval = next.timeIntervalSinceNow
        queue.asyncAfter(deadline: .now() + interval) { () -> () in
            self.job()
            self.start()
        }
    }
}
