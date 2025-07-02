//
//  RunLoopObserverDemo.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/20.
//  提示词：通过一个工具类检测主线程 RunLoop 的状态变化，并主动触发一些事件来观察这些变化。

import UIKit
import CoreFoundation

class RunLoopMonitor {
    // MARK: - 内部类型定义
    enum RunLoopState: String, CustomStringConvertible {
        case entry = "进入RunLoop"
        case beforeTimers = "即将处理Timer"
        case beforeSources = "即将处理Sources"
        case beforeWaiting = "即将进入休眠"
        case afterWaiting = "从休眠中唤醒"
        case exit = "退出RunLoop"
        
        var description: String { rawValue }
    }
    
    enum EventType {
        case timer
        case source0
        case source1
        case dispatchAsync
        case asyncTask
        case layoutIfNeeded
        case setNeedsDisplay
    }
    
    // MARK: - 回调类型
    typealias StateChangeHandler = (RunLoopState) -> Void
    typealias EventTriggerHandler = (EventType, String) -> Void
    
    // MARK: - 属性
    private var observer: CFRunLoopObserver?
    private var stateChangeHandler: StateChangeHandler?
    private var eventTriggerHandler: EventTriggerHandler?
    private weak var testView: UIView?
    private var source0: CFRunLoopSource?
    private var isDeallocating = false  // 标记对象是否正在被释放
    
    // MARK: - 初始化与销毁
    init() {
        setupRunLoopObserver()
        setupTestView()
    }
    
    deinit {
        isDeallocating = true  // 设置标记
        
        stopMonitoring()
        
        // 确保source0被正确释放
        if let source0 = source0 {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source0, .commonModes)
            CFRunLoopSourceInvalidate(source0)
            self.source0 = nil
        }
    }
    
    // MARK: - RunLoop观察设置
    func startMonitoring(stateChangeHandler: @escaping StateChangeHandler,
                        eventTriggerHandler: @escaping EventTriggerHandler) {
        self.stateChangeHandler = stateChangeHandler
        self.eventTriggerHandler = eventTriggerHandler
        
        if let observer = observer {
            CFRunLoopAddObserver(CFRunLoopGetMain(), observer, .commonModes)
        }
    }
    
    func stopMonitoring() {
        if let observer = observer {
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, .commonModes)
        }
    }
    
    // 静态回调函数，不捕获上下文
    private static let runLoopObserverCallback: CFRunLoopObserverCallBack = { (observer, activity, info) in
        guard let info = info else { return }
        
        // 从info中恢复对RunLoopMonitor的引用
        let monitor = Unmanaged<RunLoopMonitor>.fromOpaque(info).takeUnretainedValue()
        
        let state: RunLoopState
        switch activity {
        case .entry: state = .entry
        case .beforeTimers: state = .beforeTimers
        case .beforeSources: state = .beforeSources
        case .beforeWaiting: state = .beforeWaiting
        case .afterWaiting: state = .afterWaiting
        case .exit: state = .exit
        default: return
        }
        
        monitor.stateChangeHandler?(state)
    }
    
    private func setupRunLoopObserver() {
        var context = CFRunLoopObserverContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: { info -> UnsafeRawPointer? in
                guard let info = info else { return nil }
                return UnsafeRawPointer(info)
            },
            release: { info in
                guard let info = info else { return }
                let monitor = Unmanaged<RunLoopMonitor>.fromOpaque(info).takeUnretainedValue()
                
                // 只在对象真正被释放时才调用release
                if monitor.isDeallocating {
                    Unmanaged<RunLoopMonitor>.fromOpaque(info).release()
                }
            },
            copyDescription: nil
        )
        
        let activities: CFRunLoopActivity = [
            .entry,
            .beforeTimers,
            .beforeSources,
            .beforeWaiting,
            .afterWaiting,
            .exit
        ]
        
        observer = CFRunLoopObserverCreate(
            kCFAllocatorDefault,
            activities.rawValue,
            true,
            0,
            RunLoopMonitor.runLoopObserverCallback,
            &context
        )
    }
    
    // MARK: - 主动触发事件的方法
    
    // 1. 触发Timer事件
    func triggerTimer(delay: TimeInterval = 1.0) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.eventTriggerHandler?(.timer, "Timer触发")
        }
        
        eventTriggerHandler?(.timer, "已安排Timer（\(delay)s后触发）")
    }
    
    // 2. 触发Source0事件
    func triggerSource0() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 只在第一次调用时创建source0
            if self.source0 == nil {
                self.source0 = self.createSource0()
                
                // 将source0添加到RunLoop
                if let source0 = self.source0 {
                    CFRunLoopAddSource(CFRunLoopGetMain(), source0, .commonModes)
                }
            }
            
            // 触发source0事件
            if let source0 = self.source0, !self.isDeallocating {
                CFRunLoopSourceSignal(source0)
                CFRunLoopWakeUp(CFRunLoopGetMain())
                self.eventTriggerHandler?(.source0, "手动触发Source0事件")
            }
        }
    }
    
    // 静态Source0回调函数，不捕获上下文
    private static let source0PerformCallback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { info in
        guard let info = info else { return }
        let monitor = Unmanaged<RunLoopMonitor>.fromOpaque(info).takeUnretainedValue()
        
        // 确保对象未被释放
        if !monitor.isDeallocating {
            monitor.eventTriggerHandler?(.source0, "Source0事件被处理")
        }
    }
    
    private func createSource0() -> CFRunLoopSource? {
        var context = CFRunLoopSourceContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: { info -> UnsafeRawPointer? in
                guard let info = info else { return nil }
                return UnsafeRawPointer(info)
            },
            release: { info in
                guard let info = info else { return }
                let monitor = Unmanaged<RunLoopMonitor>.fromOpaque(info).takeUnretainedValue()

                // 只在对象真正被释放时才调用release
                if monitor.isDeallocating {
                    Unmanaged<RunLoopMonitor>.fromOpaque(info).release()
                }
            },
            copyDescription: nil,
            equal: nil,
            hash: nil,
            schedule: nil,
            cancel: nil,
            perform: unsafeBitCast(RunLoopMonitor.source0PerformCallback, to: (@convention(c) (UnsafeMutableRawPointer?) -> Void).self)
        )
        
        return CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context)
    }
    
    // 3. 触发Source1事件（通过触摸模拟）
    func triggerSource1() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let testView = testView else {
            eventTriggerHandler?(.source1, "无法触发Source1：UIWindow不可用")
            return
        }
        
        let location = CGPoint(x: testView.bounds.midX, y: testView.bounds.midY)
        simulateTouch(at: location, in: window)
        
        eventTriggerHandler?(.source1, "手动触发Source1事件（模拟触摸）")
    }
    
    private func simulateTouch(at location: CGPoint, in view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            view.removeGestureRecognizer(tapGesture)
        }
        
        tapGesture.location(in: view)
        tapGesture.state = .recognized
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        eventTriggerHandler?(.source1, "接收到触摸事件（Source1）")
    }
    
    // 4. 触发DispatchQueue异步任务
    func triggerDispatchAsync() {
        DispatchQueue.main.async { [weak self] in
            self?.eventTriggerHandler?(.dispatchAsync, "DispatchQueue异步任务执行")
        }
        
        eventTriggerHandler?(.dispatchAsync, "已提交DispatchQueue异步任务")
    }
    
    // 5. 触发异步执行
    func triggerAsyncTask() {
        DispatchQueue.main.async { [weak self] in
            self?.eventTriggerHandler?(.asyncTask, "异步任务执行")
        }
        
        eventTriggerHandler?(.asyncTask, "已提交异步任务")
    }
    
    // 6. 触发强制布局
    func triggerLayoutIfNeeded() {
        testView?.layoutIfNeeded()
        eventTriggerHandler?(.layoutIfNeeded, "强制触发布局计算")
    }
    
    // 7. 触发重绘
    func triggerSetNeedsDisplay() {
        testView?.setNeedsDisplay()
        eventTriggerHandler?(.setNeedsDisplay, "触发视图重绘")
    }
    
    // MARK: - 辅助方法
    private func setupTestView() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let view = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
        view.backgroundColor = .red
        window.addSubview(view)
        self.testView = view
    }
}
