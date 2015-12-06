//: Playground - noun: a place where people can play

import Cocoa
import Cronexpr
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let job = try? CronJob(pattern: "*/10 * * * * *") { () -> Void in
    print("job executes every 10 seconds")
}
