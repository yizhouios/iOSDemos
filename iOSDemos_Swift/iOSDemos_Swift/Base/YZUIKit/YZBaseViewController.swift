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

        setupGKNavigationBarSwift()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        gk_navBackgroundColor = .clear
        gk_navShadowColor = .clear
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.gk_statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.gk_statusBarStyle
    }
    
    func setupGKNavigationBarSwift() {
        gk_navigationItem.title = title
        gk_statusBarStyle = .lightContent
        gk_navTitleFont = UIFont.systemFont(ofSize: 18)
    }
}
