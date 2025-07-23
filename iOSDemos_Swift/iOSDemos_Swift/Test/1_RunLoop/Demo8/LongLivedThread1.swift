//
//  LongLivedThread.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//

class LongLivedThread {
    private var thread: Thread!
    
    func start() {
        thread = Thread(target: self, selector: #selector(threadMain), object: nil)
        thread.start()
    }
    
    @objc private func threadMain() {
        // 1. 给 RunLoop 添加事件源（如空的 Source0，否则 RunLoop 会立即退出）
        // 将端口添加到当前线程的RunLoop
        RunLoop.current.add(NSMachPort.init(), forMode: .default)
        
        // 2. 启动 RunLoop（进入循环，处理事件）
        CFRunLoopRun()
        
        // 注意：RunLoop 启动后，此处代码不会执行，除非调用 CFRunLoopStop()
    }
}
