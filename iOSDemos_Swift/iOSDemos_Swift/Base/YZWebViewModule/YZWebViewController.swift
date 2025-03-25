//
//  YZWebViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/18.
//

import UIKit
@preconcurrency import WebKit
import KVOController
import SnapKit

class YZWebViewController: YZBaseViewController, WKNavigationDelegate {
    
    // MARK: - Properties
    var webView: WKWebView!
    var progressView: UIProgressView!
    var urlString: String?
    lazy var moreButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(showSheet))
        return barButton
    }()
    
    // 添加一个上下文以便在观察者移除时使用
    private var estimatedProgressContext = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化 WKWebView
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        // 初始化 UIProgressView
        progressView = UIProgressView(progressViewStyle: .default)
        view.addSubview(progressView)
        
        webView.snp.makeConstraints {
//            $0.top.equalTo(self.gk_navigationBar.snp.bottom)
            $0.top.left.right.bottom.equalToSuperview()
        }
        progressView.snp.makeConstraints {
            $0.top.equalTo(self.gk_navigationBar.snp.bottom).offset(4)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(4)
        }
                
        // 添加观察者
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [.new], context: &estimatedProgressContext)
        
        kvoController.observe(webView, keyPath: #keyPath(WKWebView.estimatedProgress), options: [.new]) { kvoController, webView, change in
            
            let newProgressValue: Float = Float(truncating: change[NSKeyValueChangeKey.newKey] as? NSNumber ?? 0)
            self.progressView.setProgress(newProgressValue, animated: false)
            
            print("【WebView】加载进度：", newProgressValue)
        }
        // 加载指定的 URL
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        webView.backgroundColor = .red
    }
    
    // MARK: - WKNavigationDelegate
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.progress = 0.1
        
//        if webView.canGoBack {
//            // 先让返回按钮能与 leftBarButtonItems 共存
//            navigationItem.leftItemsSupplementBackButton = true
//            navigationItem.leftBarButtonItems = [
////                UIBarButtonItem.qmui_close(withTarget: self, action: #selector(closePage))
//            ]
//        } else {
//            navigationItem.leftBarButtonItems = nil
//            navigationItem.leftItemsSupplementBackButton = false
//        }
    }
    
    // 页面加载进度更新时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 可以根据需要调整进度
        progressView.progress = 0.5
    }
    
    // 页面加载完成时调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 动画隐藏进度条
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            self.progressView.alpha = 0
        }, completion: { _ in
            self.progressView.setProgress(0, animated: false)
        })
        
        // 导航栏添加3个点按钮
        navigationItem.rightBarButtonItem = moreButton
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 处理加载失败，可以显示提示信息
        print("网页加载失败: \(error.localizedDescription)")
    }
    
    // 监听加载进度
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    // 可选：监听加载进度更新
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 使用 KVO 监听 estimatedProgress（更精确的进度更新）
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            
            // 当加载完成时，隐藏进度条
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                })
            } else {
                // 显示进度条
                if progressView.alpha == 0 {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                        self.progressView.alpha = 1
                    }, completion: nil)
                }
            }
        }
    }
    
    @objc func closePage() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Handle NavBack Btn Click
//extension YZWebViewController {
//    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
//        if webView.canGoBack {
//            webView.goBack()
//            return false
//        }
//        return true
//    }
//}
//
//// MARK: - Actions
extension YZWebViewController {
    @objc func showSheet() {
//        let moreVc = QMUIMoreOperationController()
//        moreVc.contentBackgroundColor = .white
//        moreVc.cancelButtonBackgroundColor = .white
//        // 图标来自iconFont：https://www.iconfont.cn/collections/detail?spm=a313x.search_index.0.da5a778a4.6fc13a816jekRu&cid=748
//        moreVc.items = [
//            [
//                QMUIMoreOperationItemView.init(image: .init(named: "yzwebview_copy")?.qmui_imageResized(inLimitedSize: CGSizeMake(30, 30)), title: "复制", handler: { [weak self] moreVc, itemView in
//                    self?.copyUrl()
//                    moreVc.hideToBottom()
//                }),
//                QMUIMoreOperationItemView.init(image: .init(named: "yzwebview_browser")?.qmui_imageResized(inLimitedSize: CGSizeMake(30, 30)), title: "在浏览器中打开", handler: { [weak self] moreVc, itemView in
//                    self?.openInBrowser()
//                    moreVc.hideToBottom()
//                })
//            ]
//        ]
//        moreVc.showFromBottom()
    }
//    
//    // 在浏览器打开
//    func openInBrowser() {
//        if let urlString = urlString, let url = URL.init(string: urlString), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }
//    
//    // 复制网页链接
//    func copyUrl() {
//        let contentToCopy = webView.url?.absoluteString ?? ""
//        UIPasteboard.general.string = contentToCopy
//        QMUITips.showSucceed("已复制")
//    }
}
