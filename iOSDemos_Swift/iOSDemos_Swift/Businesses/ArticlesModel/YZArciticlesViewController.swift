//
//  YZArciticlesViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/01.
//

import SnapKit
import SwiftyJSON

class YZArciticlesViewController: YZBaseTableViewController {
    var datas: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datas = [
            [
                "title": "RunLoop",
                "items": RunLoop()
            ],
            [
                "title": "iOS 响应链",
                "items": ResponderChain()
            ]
        ]
        
        title = "文章"
    }
    
    override func setupUI() {
        super.setupUI()
        
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

// MARK: -
extension YZArciticlesViewController {
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

        let url = datas[indexPath.section]["items"].arrayValue[indexPath.row]["url"].string ?? ""
        showWebPage(url: url)
    }
}

// MARK: - Article RunLoop
extension YZArciticlesViewController {
    func RunLoop() -> [JSON] {
        return [
            [
                "title": "官方文档 Document Archive Run Loops",
                "url": "https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html"
            ],
            [
                "title": "深入理解RunLoop (ibireme)",
                "url": "https://blog.ibireme.com/2015/05/18/runloop/"
            ],
            [
                "title": "iOS RunLoop详解",
                "url": "https://juejin.cn/post/6844903588712415239"
            ],
            [
                "title": "CFRunLoop (ming1016)",
                "url": "https://github.com/ming1016/study/wiki/CFRunLoop"
            ]
        ]
    }
}

extension YZArciticlesViewController {
    func ResponderChain() -> [JSON] {
        return [
            [
                "title": "[官方文档] Touches, presses, and gestures",
                "url": "https://developer.apple.com/documentation/uikit/touches-presses-and-gestures"
            ],
            [
                "title": "[官方文档] Using responders and the responder chain to handle events",
                "url": "https://developer.apple.com/documentation/uikit/using-responders-and-the-responder-chain-to-handle-events"
            ],
            [
                "title": "[官方文档] Handling UIKit gestures",
                "url": "https://developer.apple.com/documentation/uikit/handling-uikit-gestures"
            ],
            [
                "title": "[掘金] iOS | 事件传递及响应链",
                "url": "https://juejin.cn/post/6894518925514997767#heading"
            ],
            [
                "title": "[掘金] iOS | 响应链及手势识别",
                "url": "https://juejin.cn/post/6905914367171100680"
            ],
            [
                "title": "[segmentfault] iOS响应者链彻底掌握",
                "url": "https://segmentfault.com/a/1190000015060603"
            ]
        ]
    }
}

// MARK: - Responder Chain

