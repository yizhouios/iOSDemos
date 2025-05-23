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
        print("didFinishLaunchingWithOptions")
        
        didInitWindow()
        
        test()
        
        return true
    }
    
    func didInitWindow() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = YZMainTabBarController()
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate {
    func test() {
        TestKVOObject.testKVOClassName()
    }
}
