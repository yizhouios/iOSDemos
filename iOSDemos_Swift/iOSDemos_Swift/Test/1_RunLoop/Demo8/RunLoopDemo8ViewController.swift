//
//  RunLoopDemo8ViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//

import Foundation
import UIKit

class RunLoopDemo8ViewController : YZBaseTableViewController {
    var thread1 = LongLivedThread1()
    var thread2 = LongLivedThread2()
    var thread3 = LongLivedThread3()
    
    var items = [
        "启动子线程的 RunLoop \n（通过启动子线程的 RunLoop 并添加自定义事件源，让线程在有任务时工作、无任务时休眠。）",
        "启动子线程的 RunLoop \n（通过启动子线程的 RunLoop 并添加NSMachPort事件源，让线程在有任务时工作、无任务时休眠。）",
//        "条件锁（NSCondition）保活子线程（条件锁是让线程处于闲等状态，当有任务时唤醒线程执行任务）"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "线程保活方案"
    }
}

extension RunLoopDemo8ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "UITableViewCell")

        cell.textLabel?.textColor = UIColor.init(white: 0.0, alpha: 0.6)
        cell.textLabel?.font = UIFont.init(name: "ChalkboardSE-Bold", size: 14.0)
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.numberOfLines = 0
        
        cell.textLabel?.text = "\(indexPath.row + 1)." + items[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if (index == 0) {
            performTaskOnThread1()
        } else if (index == 1) {
            performTaskOnThread2()
        } else if (index == 2) {
            performTaskOnThread3()
        }
    }
}

// MARK: -
extension RunLoopDemo8ViewController {
    @objc func doTask1() {
        print("\(Thread.current) doTask1")
    }
    
    func performTaskOnThread1() {
        perform(#selector(doTask1), on: thread1.thread, with: nil, waitUntilDone: false)
    }
}

// MARK: -
extension RunLoopDemo8ViewController {
    @objc func doTask2() {
        print("\(Thread.current) doTask2")
    }
    
    func performTaskOnThread2() {
        perform(#selector(doTask2), on: thread2.thread, with: nil, waitUntilDone: false)
    }
}

// MARK: -
extension RunLoopDemo8ViewController {
    @objc func doTask3() {
        print("\(Thread.current) doTask3")
    }
    
    func performTaskOnThread3() {
        self.thread3.customTask = { [weak self] in
            self?.doTask3()
        }
        self.thread3.doTask()
    }
}
