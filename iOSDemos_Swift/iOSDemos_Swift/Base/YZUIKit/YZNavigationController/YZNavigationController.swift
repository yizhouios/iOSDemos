//
//  YZNavigationController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/18.
//

import UIKit

class YZNavigationController: UINavigationController {
    let fd_fullscreenPopGestureRecognizer = {
        let panGest = UIPanGestureRecognizer.init()
        panGest.maximumNumberOfTouches = 1
        return panGest
    }()
    
    let fd_popGestureRecognizerDelegate = {
        let delegate = _FDFullscreenPopGestureRecognizerDelegate.init()
        return delegate
    }()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setupCustomAppearance()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupCustomAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCustomAppearance()
    }

    // MARK: - 自定义初始化逻辑
    private func setupCustomAppearance() {
        self.fd_popGestureRecognizerDelegate.navigationController = self
    }
}

// MARK: FDFullScreenPopGesture
// https://github.com/forkingdog/FDFullscreenPopGesture
extension YZNavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let interactivePopGest = interactivePopGestureRecognizer,
           let view = interactivePopGest.view,
           let gestureRecognizers = view.gestureRecognizers,
           !gestureRecognizers.contains(fd_fullscreenPopGestureRecognizer) {
            
            // 将自定义手势识别器添加到系统边缘轻扫手势的原绑定视图上。
            view.addGestureRecognizer(fd_fullscreenPopGestureRecognizer)
            
            // 将手势事件交由系统原生手势识别器的内部方法处理。
            if let internalTargets = interactivePopGestureRecognizer?.value(forKey: "targets") as? [AnyObject],
               let firstTarget = internalTargets.first,
               let internalTarget = firstTarget.value(forKey: "target") {
                
                let internalAction = Selector(("handleNavigationTransition:"))
                fd_fullscreenPopGestureRecognizer.delegate = fd_popGestureRecognizerDelegate
                fd_fullscreenPopGestureRecognizer.addTarget(internalTarget, action: internalAction)
            }
            
            // 禁用系统原生手势识别器
            interactivePopGest.isEnabled = false
        }
        
        if !self.viewControllers.contains(viewController) {
            super.pushViewController(viewController, animated: animated)
        }
    }
}

class _FDFullscreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var navigationController: UINavigationController?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = navigationController, let panGest = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        // 忽略该手势：当没有视图控制器被推入导航堆栈时
        if navigationController.viewControllers.count <= 1 {
            return false
        }
        
        // 忽略该手势：如果当前正在转场中
        if let isTransitioning = navigationController.value(forKey: "_isTransitioning"),
           isTransitioning as? Bool != nil,
           isTransitioning as! Bool == true {
            return false
        }
        
        // 忽略该手势：当手势从相反方向开始时
        let translation = panGest.translation(in: panGest.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if translation.x * multiplier <= 0 {
            return false
        }
        
        return true
    }
}
