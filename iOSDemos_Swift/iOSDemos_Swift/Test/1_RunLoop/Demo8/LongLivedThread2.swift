//
//  LongLivedThread2.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//

import Foundation

class LongLivedThread2 {
    var thread: Thread!
    
    init() {
        thread = Thread(target: self, selector: #selector(threadMain), object: nil)
        thread.name = "LongLivedThread2-RunLoop"
        thread.start()
    }
    
    @objc private func threadMain() {
        autoreleasepool {
            RunLoop.current.add(NSMachPort(), forMode: .common)
            
            RunLoop.current.run()
        }
    }
}
