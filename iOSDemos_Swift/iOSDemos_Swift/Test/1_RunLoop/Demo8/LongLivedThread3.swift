//
//  LongLivedThread.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//
// 条件锁（NSCondition）保活子线程
// 条件锁是让线程处于闲等状态，当有任务时唤醒线程执行任务

import Foundation

class LongLivedThread3 {
    var thread: Thread!
    var condition: NSCondition!
    var customTask: (() -> (Void))?
    var isExitThred = false
    
    init() {
        condition = NSCondition.init()
        thread = Thread(target: self, selector: #selector(threadMain), object: nil)
        thread.name = "LongLivedThread3-RunLoop"
        thread.start()
    }
    
    @objc private func threadMain() {
        // 让子线程进入闲等状态
        autoreleasepool {
            repeat {
                condition.lock()
                if (self.customTask != nil) {
                    self.customTask!()
                    self.customTask = nil
                }
                condition.wait()
                condition.unlock()
            } while (!isExitThred)
        }
    }
    
    func doTask() {
        thread.perform(#selector(signal), on: thread, with: nil, waitUntilDone: false)
    }
    
    @objc private func signal() {
        condition.signal()
    }
}
