//
//  DemoRunLoop.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/5.
//

import UIKit

class DemoRunLoop : YZBaseTableViewController {
    var datas: [DemoRunLoopCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        demo()
        
        datas = [
            DemoRunLoopCellModel.init(title: "1", clickBlock: {
                
            }),
            DemoRunLoopCellModel.init(title: "2", clickBlock: {
                
            })
        ]
    }
}

// MARK: - Demo测试
extension DemoRunLoop {
    func demo() {
        let mainRunloop: RunLoop = RunLoop.current
        print(mainRunloop)
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
        cell.textLabel?.text = model.title
        return cell
    }
}

// MARK: - Model for Cell
struct DemoRunLoopCellModel {
    var title: String
    var clickBlock: (() -> ())
}
