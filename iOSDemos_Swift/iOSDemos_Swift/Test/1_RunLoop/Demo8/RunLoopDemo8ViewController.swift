//
//  RunLoopDemo8ViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//

import Foundation
import UIKit

class RunLoopDemo8ViewController : YZBaseTableViewController {
    var items = [
        "线程保活方案1（RunLoop添加source）"
    ]
    
    override func viewDidLoad() {
        
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
        cell.textLabel?.numberOfLines = 2
        
        cell.textLabel?.text = items[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if (index == 0) {
            
        }
    }
}
