//
//  DemoRunLoop.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/5.
//

import UIKit

class DemoRunLoop : YZBaseTableViewController {
    var datas: [DemoRunLoopCellModel] = []
    var mt: Demo1_MainThread!
    // demo3
    var demo3TaskId = 1
    var threadForDemo3 = {
        let thread = Thread.init {
            let port = NSMachPort.init()
            RunLoop.current.add(port, forMode: .default)
            RunLoop.current.run()
        }
        return thread
    }()
    
    // demo4
    var threadForDemo4 = {
        let thread = Thread.init()
        return thread
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        demo()
        
        datas = [
            DemoRunLoopCellModel.init(title: "配置一个基于端口的输入源（Port-Based Sources）", clickBlock: { [weak self] in
                self?.demo1()
            }),
            DemoRunLoopCellModel.init(title: "定义一个自定义输入源（Custom Input Sources）", clickBlock: { [weak self] in
                self?.demo2()
            }),
            DemoRunLoopCellModel.init(title: "Cocoa Perform Selector Sources（子线程开启RunLoop）", clickBlock: { [weak self] in
                self?.demo3()
            }),
            DemoRunLoopCellModel.init(title: "Cocoa Perform Selector Sources（子线程未开启RunLoop）", clickBlock: { [weak self] in
                self?.demo4()
            }),
            DemoRunLoopCellModel.init(title: "配置定时器源（\(RunLoop.Mode.default.rawValue)）", clickBlock: { [weak self] in
                self?.demo5()
            }),
            DemoRunLoopCellModel.init(title: "配置定时器源（\(RunLoop.Mode.common.rawValue)）", clickBlock: { [weak self] in
                self?.demo6()
            }),
        ]
        
        prepareDemo1()
        prepareDemo3()
        prepareDemo4()
    }
}

// MARK: - Demo测试
extension DemoRunLoop {
    func demo() {
//        let mainRunloop: RunLoop = RunLoop.current
//        print(mainRunloop)
    }
}

// MARK: -
extension DemoRunLoop {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YZUITableViewCellOnlyTitle.ReUseID, for: indexPath)
        let model = datas[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1). \(model.title)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        datas[indexPath.row].clickBlock()
    }
}

// MARK: - Model for Cell
struct DemoRunLoopCellModel {
    var title: String
    var clickBlock: (() -> ())
}

// MARK: - Demo1

var count = 1
extension DemoRunLoop {
    func prepareDemo1() {
        mt = Demo1_MainThread.init()
        autoreleasepool {
            mt.launchWorkerThread()
        }
    }
    
    func demo1() {
        mt.sendMessage(toWorker: "这是主线程发消息的第\(count)次")
        count += 1
    }
}

// MARK: - Demo2
extension DemoRunLoop {
    func demo2() {
        let d2 = RunLoopDemo2.init()
        d2?.start()
        
        for i in 1...5 {
            let command = "Task \(i)"
            d2?.sendCommand(1, withData: command)

            Thread.sleep(forTimeInterval: 0.3)
        }

        d2?.stop()
    }
}

// MARK: - Demo3
extension DemoRunLoop {
    func prepareDemo3() {
        threadForDemo3.start()
    }
    
    @objc func logThread(task: String) {
        print("当前在子线程执行任务：\(task). \(Thread.current)")
    }
        
    func demo3() {
        self.perform(#selector(DemoRunLoop.logThread(task:)), on: threadForDemo3, with: "default模式下任务 \(demo3TaskId)", waitUntilDone: false)
        
        self.perform(#selector(DemoRunLoop.logThread(task:)), on: threadForDemo3, with: "tracking模式下的任务 \(demo3TaskId)", waitUntilDone: false, modes: [RunLoop.Mode.tracking.rawValue])
        
        demo3TaskId += 1
        
        // 延迟3秒后将threadForDemo3切换为tracking模式
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.switchToTrackingMode()
        }
    }
    
    // 切换到Tracking模式
    func switchToTrackingMode() {
        guard threadForDemo3.isExecuting else { return }
        
        DispatchQueue.global().async {
            // 确保在工作线程上执行模式切换
            self.perform(#selector(self.setTrackingMode), on: self.threadForDemo3, with: nil, waitUntilDone: false)
        }
    }
    
    @objc func setTrackingMode() {
        // 记录模式切换
        NSLog("切换RunLoop模式: 从 default 切换到 tracking")
        
        // 停止当前RunLoop
        CFRunLoopStop(CFRunLoopGetCurrent())
        
        // 立即在新的模式下重启RunLoop
        /// 正确转换为CFString并赋值给CFRunLoopMode
        let trackingMode: CFRunLoopMode = unsafeBitCast(
            RunLoop.Mode.tracking,
            to: CFRunLoopMode.self
        )
        // 切换到Tracking模式并运行RunLoop
        CFRunLoopRunInMode(trackingMode, 1.0, false)
    }
}

// MARK: - Demo4
extension DemoRunLoop {
    func prepareDemo4() {
        threadForDemo4.start()
    }
    
    @objc func logThread_demo4(task: String) {
        print("当前在子线程执行任务：\(task). \(Thread.current)")
    }
    
    func demo4() {
        self.perform(#selector(DemoRunLoop.logThread_demo4(task:)), on: threadForDemo4, with: "任务1", waitUntilDone: false)
    }
}

// MARK: - Demo5
var timer1: Timer!
var timer1Count = 0
extension DemoRunLoop {
    func demo5() {
        let future = Date.init(timeIntervalSinceNow: 1)
        timer1 = Timer.init(fire: future, interval: 1, repeats: true, block: { timer in
            print("Timer1 定时器执行任务. \(timer1Count)")
            timer1Count += 1
            
            if timer1Count == 10 {
                timer.invalidate()
            }
        })
        RunLoop.current.add(timer1, forMode: .default)
    }
}

// MARK: - Demo6
var timer2: Timer!
var timer2Count = 0
extension DemoRunLoop {
    func demo6() {
        let future = Date.init(timeIntervalSinceNow: 1)
        timer2 = Timer.init(fire: future, interval: 1, repeats: true, block: { timer in
            print("Timer2 定时器执行任务. \(timer2Count)")
            timer2Count += 1
            
            if timer2Count == 10 {
                timer.invalidate()
            }
        })
        RunLoop.current.add(timer2, forMode: .common)
    }
}
