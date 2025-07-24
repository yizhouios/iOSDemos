//
//  LongLivedThread.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//

import Foundation

class LongLivedThread1 {
    var thread: Thread!
    
    init() {
        thread = Thread(target: self, selector: #selector(threadMain), object: nil)
        thread.name = "LongLivedThread1-RunLoop"
        thread.start()
    }
    
    @objc private func threadMain() {
        // 1. 添加常驻事件源（否则RunLoop会立即退出）
        var sourceContext = CFRunLoopSourceContext()
        let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        
        RunLoop.current.run()
    }
}
