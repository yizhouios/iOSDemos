//
//  LongLivedThread4.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/24.
//

import UIKit

class LongLivedThread4 {
    // 创建串行队列（保证任务顺序执行）
    private let queue = DispatchQueue(label: "com.yizhou.longlived.gcd", attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 0)
    private var isRunning = true
    
    var customTask: (() -> ())?
    
    init() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            Thread.current.name = "LongLivedThread4-RunLoop"
            
            print("\n子线程启动（GCD方案），线程：\(Thread.current.name ?? "未知")")
            
            while self.isRunning {
                // 等待信号（无任务时阻塞）
                let result = self.semaphore.wait(timeout: .distantFuture)
                if result == .timedOut { break } // 理论上不会触发
                
                // 执行任务
//                print("GCD线程执行任务")
                
                if (self.customTask != nil) {
                    self.customTask!()
                }
            }
            
            print("GCD子线程已退出")
        }
    }
    
    // 触发任务
    func triggerTask() {
        semaphore.signal() // 发送信号唤醒
    }
    
    // 停止线程
    func stop() {
        isRunning = true
        semaphore.signal() // 唤醒线程退出循环
    }
}
