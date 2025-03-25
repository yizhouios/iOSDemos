//
//  YZBaseViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/20.
//

import UIKit

class YZBaseViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
