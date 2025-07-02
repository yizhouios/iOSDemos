//
//  RunLoopObserverViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/20.
//

import UIKit

// 在UIViewController中使用
class RunLoopObserverViewController: UIViewController {
    private var runLoopMonitor: RunLoopMonitor!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        runLoopMonitor = RunLoopMonitor()
        
        // 设置回调
        runLoopMonitor.startMonitoring(
            stateChangeHandler: { state in
                print("RunLoop状态变化: \(state)")
            },
            eventTriggerHandler: { eventType, message in
                print("事件类型: \(eventType), 消息: \(message)")
            }
        )
        
        // 添加测试按钮
        setupButtons()
    }
    
    private func setupButtons() {
        let buttonTitles = [
            "触发Timer",
            "触发Source0",
            "触发Source1",
            "触发DispatchAsync",
            "触发AsyncTask",
            "触发LayoutIfNeeded",
            "触发SetNeedsDisplay"
        ]
        
        var yOffset: CGFloat = 250
        
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 50, y: yOffset, width: 200, height: 40)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            yOffset += 50
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        switch title {
        case "触发Timer":
            runLoopMonitor.triggerTimer()
        case "触发Source0":
            runLoopMonitor.triggerSource0()
        case "触发Source1":
            runLoopMonitor.triggerSource1()
        case "触发DispatchAsync":
            runLoopMonitor.triggerDispatchAsync()
        case "触发AsyncTask":
            runLoopMonitor.triggerAsyncTask()
        case "触发LayoutIfNeeded":
            runLoopMonitor.triggerLayoutIfNeeded()
        case "触发SetNeedsDisplay":
            runLoopMonitor.triggerSetNeedsDisplay()
        default:
            break
        }
    }
}
