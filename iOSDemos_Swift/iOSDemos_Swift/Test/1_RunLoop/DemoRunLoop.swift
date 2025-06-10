//
//  DemoRunLoop.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/5.
//

import UIKit

class DemoRunLoop : YZBaseTableViewController {
    var datas: [DemoRunLoopCellModel] = []
    var mt = MainThread.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoreleasepool {
            mt.launchWorkerThread()
        }
        
        demo()
        
        datas = [
            DemoRunLoopCellModel.init(title: "配置一个基于端口的输入源", clickBlock: { [weak self] in
                self?.demo1()
            })
        ]
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
    func demo1() {
        mt.sendMessage(toWorker: "这是主线程发消息的第\(count)次")
        count += 1
    }
}
