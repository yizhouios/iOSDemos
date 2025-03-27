//
//  YZInterviewViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/15.
//

import SnapKit
import SwiftyJSON

class YZInterviewViewController: YZBaseViewController {
    let datas: JSON = [
        [
//            "title": "iOS面试题",
            "items": [
                [
                    "title": "《招聘一个靠谱的 iOS》—参考答案（上）",
                    "url": "https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8A%EF%BC%89.md"
                ],
                [
                    "title": "《招聘一个靠谱的 iOS》—参考答案（下）",
                    "url": "https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8B%EF%BC%89.md"
                ],
                [
                    "title": "Over 150 iOS interview questions",
                    "subTitle": "https://www.hackingwithswift.com/interview-questions",
                    "url": "https://www.hackingwithswift.com/interview-questions"
                ],
                [
                    "title": "Navigating the iOS Interview",
                    "subTitle": "https://github.com/kodecocodes/ios-interview",
                    "url": "https://github.com/kodecocodes/ios-interview"
                ],
                [
                    "title": "40+ iOS Interview Questions and Answers for Developers",
                    "subTitle": "https://hackr.io/blog/ios-interview-questions-and-answers",
                    "url": "https://hackr.io/blog/ios-interview-questions-and-answers"
                ]
            ]
        ],
        [
            "items": [
                [
                    "title": "Grand Central Dispatch (GCD) and Dispatch Queues in Swift",
                    "subTitle": "https://www.appcoda.com/grand-central-dispatch/",
                    "url": "https://www.appcoda.com/grand-central-dispatch/"
                ]
            ]
        ]
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "面试题"
        
        setupUI()
    }
    
    func setupUI() {
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
extension YZInterviewViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let url = datas[indexPath.section]["items"].arrayValue[indexPath.row]["url"].string ?? ""
        showWebPage(url: url)
    }
}
