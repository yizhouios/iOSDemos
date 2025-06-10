//
//  YZUITableViewCellOnlyTitle.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/10.
//

import UIKit

class YZUITableViewCellOnlyTitle : UITableViewCell {
    static let ReUseID = "YZUITableViewCellOnlyTitle"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textColor = UIColor.init(white: 0.0, alpha: 0.6)
        textLabel?.font = UIFont.init(name: "ChalkboardSE-Bold", size: 14.0)
        textLabel?.lineBreakMode = .byCharWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
