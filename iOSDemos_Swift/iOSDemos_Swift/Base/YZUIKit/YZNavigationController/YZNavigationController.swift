//
//  YZNavigationController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/18.
//

import UIKit

class YZNavigationController: UINavigationController {
    var openSystemNavHandle: Bool = false
    var hideNavigationBar: Bool = false
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.openSystemNavHandle {
            self.isNavigationBarHidden = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
}
