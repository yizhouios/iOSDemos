//
//  YZWebViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/3/18.
//

import UIKit
@preconcurrency import WebKit
import KVOController

class YZWebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Properties
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var urlString: String?
    
    // 添加一个上下文以便在观察者移除时使用
    private var estimatedProgressContext = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 初始化 WKWebView
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // 添加约束（Auto Layout）
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 初始化 UIProgressView
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        // 添加进度条约束
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
        
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
    }
    
    // MARK: - WKNavigationDelegate
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.progress = 0.1
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
}

// MARK: - Handle NavBack Btn Click
extension YZWebViewController {
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        return true
    }
}
