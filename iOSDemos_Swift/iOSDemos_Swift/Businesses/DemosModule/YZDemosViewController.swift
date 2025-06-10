//
//  YZDemosViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/5.
//

import SnapKit
import SwiftyJSON

class YZDemosViewController: YZBaseTableViewController {
    var datas: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Demos"
    }
    
    override func setupUI() {
        super.setupUI()
        
        makeData()
    }
}

// MARK: - 制造数据
extension YZDemosViewController {
    func makeData() {
        self.datas = [
            [
                "title": "测试 RunLoop",
                "className": NSStringFromClass(DemoRunLoop.self)
            ],
            [
                "title": "iOS响应链",
                "className": NSStringFromClass(Demo2UIResponderVc.self)
            ]
        ]
    }
}

// MARK: -
extension YZDemosViewController {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "UITableViewCell")

        let dict: [String: Any] = datas[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.init(white: 0.0, alpha: 0.6)
        cell.textLabel?.font = UIFont.init(name: "ChalkboardSE-Bold", size: 14.0)
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.numberOfLines = 2
        
        cell.textLabel?.text = dict["title"] as? String
//        cell.detailTextLabel?.text = dict["subTitle"] as? String

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let dict: [String: Any] = datas[indexPath.row]
        
        let className: String? = (dict["className"] as? String) ?? ""
        guard let clsName = className, let classType = NSClassFromString(clsName) as? NSObject.Type else {
            return
        }
        
        self.navigationController?.pushViewController(classType.init() as! UIViewController, animated: true)
    }
}
