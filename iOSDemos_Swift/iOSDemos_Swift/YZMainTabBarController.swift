//
//  YZMainTabBarController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/15.
//

import ESTabBarController_swift

class YZMainTabBarController: ESTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

//        let v1 = YZNavigationController(rootViewController: YZInterviewViewController())
        let v1 = UINavigationController(rootVC: YZInterviewViewController())
        let v2 = YZNavigationController(rootViewController: UIViewController())
        let v3 = YZNavigationController(rootViewController: UIViewController())
        let v4 = YZNavigationController(rootViewController: UIViewController())
        let v5 = YZNavigationController(rootViewController: UIViewController())
        
        v1.gk_openSystemNavHandle = false
        
        v1.tabBarItem = ESTabBarItem.init(title: "面试题", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        v2.tabBarItem = ESTabBarItem.init(title: "Find", image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        v3.tabBarItem = ESTabBarItem.init(title: "Photo", image: UIImage(named: "photo"), selectedImage: UIImage(named: "photo_1"))
        v4.tabBarItem = ESTabBarItem.init(title: "Favor", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor_1"))
        v5.tabBarItem = ESTabBarItem.init(title: "Me", image: UIImage(named: "me"), selectedImage: UIImage(named: "me_1"))
        
        viewControllers = [v1, v2, v3, v4, v5]
    }
}
