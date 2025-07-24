//
//  LongLivedThread3.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//
// 条件锁（NSCondition）保活子线程
// 条件锁是让线程处于闲等状态，当有任务时唤醒线程执行任务

import UIKit

class LongLivedThread3 {
    private var thread: Thread!
    private var isRunning = true
    // 用于线程等待/唤醒的条件锁
    private let condition = NSCondition()
    
    var customTask: (() -> ())?
    
    init() {
        thread = Thread { [weak self] in
            guard let self = self else { return }
            print("子线程启动（条件等待方案），线程：\(Thread.current.name ?? "未知")")
            
            while self.isRunning {
                // 加锁并等待信号
                self.condition.lock()
                // 无任务时等待（会释放CPU）
                self.condition.wait()
                self.condition.unlock()
                
                // 被唤醒后执行任务
//                print("执行任务（线程存活中）")
                if (self.customTask != nil) {
                    self.customTask!()
                }
            }
            
            print("子线程已退出")
        }
        thread.name = "LongLivedThread3-RunLoop"
        thread.start()
    }
    
    // 唤醒线程执行任务
    func triggerTask() {
        condition.lock()
        condition.signal() // 发送信号唤醒线程
        condition.unlock()
    }
    
    // 停止线程
    func stop() {
        isRunning = false
        triggerTask() // 唤醒线程使其退出循环
    }
}
