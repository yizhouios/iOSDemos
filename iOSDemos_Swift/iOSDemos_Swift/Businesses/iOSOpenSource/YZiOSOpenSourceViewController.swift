//
//  YZiOSOpenSourceViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/27.
//

import SnapKit
import SwiftyJSON

class YZiOSOpenSourceViewController: YZBaseTableViewController {
    
    let datas: JSON = [
        [
            "items": [
                [
                    "title": "PromiseKit",
//                    "subTitle": "https://github.com/diwu/LeetCode-Solutions-in-Swift",
                    "url": "https://github.com/mxcl/PromiseKit",
                ]
            ]
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "开源库"
    }
    
    override func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "roadmap", style: .plain, target: self, action: #selector(goRoadmap))
    }
    
    @objc func goRoadmap() {
        showWebPage(url: "https://roadmap.sh/ios")
    }
    
    func showWebPage(url: String) {
        let webVc = YZWebViewController()
        webVc.urlString = url
        webVc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVc, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension YZiOSOpenSourceViewController {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section]["items"].count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datas[section]["title"].string
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "UITableViewCell")

        let dict: [String: Any] = datas[indexPath.section]["items"].arrayValue[indexPath.row].rawValue as! [String : Any]
        cell.textLabel?.textColor = UIColor.init(white: 0.0, alpha: 0.6)
        cell.textLabel?.font = UIFont.init(name: "ChalkboardSE-Bold", size: 14.0)
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.numberOfLines = 2
        
        cell.textLabel?.text = dict["title"] as? String
        cell.detailTextLabel?.text = dict["subTitle"] as? String

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let index = indexPath.row
        
        if index == 0 {
            navigationController?.pushViewController(Demo1PromiseKitVC.init(), animated: true)
        }
    }
}
