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
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        didInitWindow()
        
        return true
    }
    
    func didInitWindow() {
        window?.rootViewController = YZMainTabBarController()
        window?.makeKeyAndVisible()
    }
}

