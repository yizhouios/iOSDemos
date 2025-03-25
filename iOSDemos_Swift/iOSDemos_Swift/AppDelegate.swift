//
//  AppDelegate.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupNav()
        didInitWindow()
        
        return true
    }
    
    func setupNav() {
        GKConfigure.setupDefault()
        GKConfigure.gk_hidesBottomBarWhenPushed = true
        GKConfigure.awake()
    }
    
    func didInitWindow() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = YZMainTabBarController()
        window?.makeKeyAndVisible()
    }
}

