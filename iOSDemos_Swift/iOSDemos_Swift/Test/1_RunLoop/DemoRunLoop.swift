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
    
    // demo9
    var timerForDemo9: Timer?
    
    deinit {
        timerForDemo9?.invalidate()
        timerForDemo9 = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更多", style: .plain, target: self, action: #selector(more))
        
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
            DemoRunLoopCellModel.init(title: "RunLoop观察者", clickBlock: { [weak self] in
                self?.demo7()
            }),
            DemoRunLoopCellModel.init(title: "线程保活方案", clickBlock: { [weak self] in
                self?.demo8()
            }),
            DemoRunLoopCellModel.init(title: "NSTimer(由于RunLoop较忙，不准的情况)", clickBlock: { [weak self] in
                self?.demo9()
            }),
            DemoRunLoopCellModel.init(title: "NSTimer(由于RunLoop较忙，而丢失回调的情况)", clickBlock: { [weak self] in
                self?.demo10()
            }),
            DemoRunLoopCellModel.init(title: "AutoreleasePool（创建大量临时对象测试）", clickBlock: { [weak self] in
                self?.demo11()
            }),
        ]
        
        prepareDemo1()
        prepareDemo3()
        prepareDemo4()
    }
    
    @objc func more() {
        let items = ["选项1", "选项2", "选项3", "选项4", "选项5", "选项6"]
                
        let popup = ListPopupView(title: "请选择", items: items)
        popup.onItemSelected { index, item in
            print("选中项: \(index) - \(item)")
        }
        popup.show(in: self)
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

// MARK: - Demo7
extension DemoRunLoop {
    func demo7() {
        let demoVc = RunLoopObserverViewController()
        navigationController?.pushViewController(demoVc, animated: true)
    }
}

// MARK: - Demo8
extension DemoRunLoop {
    func demo8() {
        let demoVc = RunLoopDemo8ViewController()
        navigationController?.pushViewController(demoVc, animated: true)
    }
}

// MARK: - Demo9
extension DemoRunLoop {
    // NSTimer(由于RunLoop较忙，不准的情况)
    /*
         NSTimer开始: 0.0000000
         before busy 4.200407028198242
         after busy 5.70176899433136
         NSTimer fire: 5.701907992362976
         NSTimer fire: 10.00194799900055
         NSTimer fire: 15.49971604347229
         NSTimer fire: 20.500756978988647
         NSTimer fire: 25.50046193599701
         NSTimer fire: 30.500391960144043
     */
    func demo9() {
        let refTime = CFAbsoluteTimeGetCurrent()
        print("NSTimer开始: 0.0000000")
        timerForDemo9 = Timer.init(timeInterval: 5, repeats: true) { timer in
            print("NSTimer fire: \(CFAbsoluteTimeGetCurrent() - refTime)")
        }
        timerForDemo9!.tolerance = 0.5
        RunLoop.current.add(timerForDemo9!, forMode: .default)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("before busy \(CFAbsoluteTimeGetCurrent() - refTime)")
            var j = 0
            for i in 0...10000000 {
                j = i * 3
            }
            print("after busy \(CFAbsoluteTimeGetCurrent() - refTime)")
        }
    }
}

// MARK: - Demo10
extension DemoRunLoop {
    // 由于RunLoop较忙，而丢失回调的情况
    /*
         NSTimer开始: 0.0000000
         before busy 4.195487022399902
         after busy 18.856470942497253
         NSTimer fire: 18.856953024864197
         NSTimer fire: 20.496943950653076
         NSTimer fire: 25.49696695804596
         NSTimer fire: 30.498687982559204
         NSTimer fire: 35.4974559545517
     */
    func demo10() {
        let refTime = CFAbsoluteTimeGetCurrent()
        print("NSTimer开始: 0.0000000")
        timerForDemo9 = Timer.init(timeInterval: 5, repeats: true) { timer in
            print("NSTimer fire: \(CFAbsoluteTimeGetCurrent() - refTime)")
        }
        timerForDemo9!.tolerance = 0.5
        RunLoop.current.add(timerForDemo9!, forMode: .default)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("before busy \(CFAbsoluteTimeGetCurrent() - refTime)")
            var j = 0
            for i in 0...100000000 {
                j = i * 3
            }
            print("after busy \(CFAbsoluteTimeGetCurrent() - refTime)")
        }
    }
}

// MARK: - Demo11
extension DemoRunLoop {
    // 测试不使用autoreleasepool的情况
        func demo11_testWithoutAutoreleasePool() {
            print("开始测试：不使用autoreleasepool")
            let startMemory = demo11_getUsedMemory()
            print("初始内存使用: \(startMemory) MB")
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // 循环创建大量临时对象
            for i in 0..<1000000 {
                // 创建字符串和数组等临时对象
                let string = "临时字符串 \(i) 重复内容用来增加内存占用 ".appending(String(repeating: "x", count: 1000))
                let array = [string, String(i), "额外的字符串内容"]
                _ = array.joined(separator: "|")
            }
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let endMemory = demo11_getUsedMemory()
            
            print("完成测试：不使用autoreleasepool")
            print("结束内存使用: \(endMemory) MB")
            print("内存变化: \(endMemory - startMemory) MB")
            print("耗时: \(endTime - startTime) 秒\n")
        }
        
        // 测试使用autoreleasepool的情况
        func demo11_testWithAutoreleasePool() {
            print("开始测试：使用autoreleasepool")
            let startMemory = demo11_getUsedMemory()
            print("初始内存使用: \(startMemory) MB")
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // 循环创建大量临时对象，但在每次循环中使用autoreleasepool
            for i in 0..<1000000 {
                autoreleasepool {
                    // 创建字符串和数组等临时对象
                    let string = "临时字符串 \(i) 重复内容用来增加内存占用 ".appending(String(repeating: "x", count: 1000))
                    let array = [string, String(i), "额外的字符串内容"]
                    _ = array.joined(separator: "|")
                }
            }
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let endMemory = demo11_getUsedMemory()
            
            print("完成测试：使用autoreleasepool")
            print("结束内存使用: \(endMemory) MB")
            print("内存变化: \(endMemory - startMemory) MB")
            print("耗时: \(endTime - startTime) 秒\n")
        }
        
        // 获取当前应用的内存使用情况（MB）
        func demo11_getUsedMemory() -> Double {
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
            
            let kerr = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            
            if kerr == KERN_SUCCESS {
                return Double(info.resident_size) / 1024 / 1024
            } else {
                return -1
            }
        }
        
        // 运行所有测试
        func demo11_runAllTests() {
            // 正式测试
            demo11_testWithoutAutoreleasePool()
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                self.demo11_testWithAutoreleasePool()
            }
        }
    
    func demo11() {
        demo11_runAllTests()
    }
}

