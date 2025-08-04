//
//  Demo1PromiseKitVC.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/23.
//

import Foundation
import PromiseKit
import UIKit

class Demo1PromiseKitVC : YZBaseViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PromiseKit Demo"
        setupUI()
        setupButtons()
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalToSuperview().offset(-40)
        }
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
    }
    
    private func setupButtons() {
        let buttons = [
            ("基础Promise用法", #selector(basicPromiseDemo)),
            ("链式调用", #selector(chainPromiseDemo)),
            ("错误处理", #selector(errorHandlingDemo)),
            ("并发操作", #selector(concurrentDemo)),
            ("网络请求模拟", #selector(networkRequestDemo)),
            ("图片加载模拟", #selector(imageLoadingDemo)),
            ("复杂业务场景", #selector(complexBusinessDemo))
        ]
        
        for (title, action) in buttons {
            let button = createButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        return button
    }
    
    // MARK: - Demo Methods
    
    @objc private func basicPromiseDemo() {
        print("=== 基础Promise用法 ===")
        
        // 创建一个简单的Promise
        let promise = Promise<String> { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                seal.fulfill("Hello PromiseKit!")
            }
        }
        
        promise.done { result in
            print("✅ 成功: \(result)")
        }.catch { error in
            print("❌ 错误: \(error)")
        }.finally {
            print("🏁 完成")
        }
    }
    
    @objc private func chainPromiseDemo() {
        print("=== 链式调用 ===")
        
        // 模拟用户登录流程
        loginUser(username: "testuser", password: "123456")
            .then { user -> Promise<UserProfile> in
                print("用户登录成功: \(user.name)")
                return self.fetchUserProfile(userId: user.id)
            }
            .then { profile -> Promise<[Post]> in
                print("获取用户资料成功: \(profile.email)")
                return self.fetchUserPosts(userId: profile.userId)
            }
            .done { posts in
                print("获取用户文章成功: \(posts.count) 篇文章")
            }
            .catch { error in
                print("❌ 链式调用出错: \(error)")
            }
    }
    
    @objc private func errorHandlingDemo() {
        print("=== 错误处理 ===")
        
        // 模拟可能失败的操作
        simulateRiskyOperation()
            .then { result -> Promise<String> in
                print("第一步成功: \(result)")
                return self.simulateAnotherRiskyOperation()
            }
            .done { result in
                print("✅ 所有操作成功: \(result)")
            }
            .catch { error in
                if let customError = error as? CustomError {
                    print("❌ 自定义错误: \(customError.message)")
                } else {
                    print("❌ 未知错误: \(error)")
                }
            }
            .finally {
                print("🏁 错误处理演示完成")
            }
    }
    
    @objc private func concurrentDemo() {
        print("=== 并发操作 ===")
        
        let promises = [
            fetchDataFromAPI1(),
            fetchDataFromAPI2(),
            fetchDataFromAPI3()
        ]
        
        // 等待所有Promise完成
        when(fulfilled: promises)
            .done { results in
                print("✅ 所有API调用成功:")
                for (index, result) in results.enumerated() {
                    print("  API\(index + 1): \(result)")
                }
            }
            .catch { error in
                print("❌ 并发操作出错: \(error)")
            }
    }
    
    @objc private func networkRequestDemo() {
        print("=== 网络请求模拟 ===")
        
        // 模拟网络请求
        fetchUsers()
            .then { users -> Promise<User> in
                print("获取用户列表成功: \(users.count) 个用户")
                // 获取第一个用户的详细信息
                return self.fetchUser(userId: users.first!.id)
            }
            .then { user -> Promise<[Post]> in
                print("获取用户详情成功: \(user.name)")
                // 获取用户的文章
                return self.fetchUserPosts(userId: user.id)
            }
            .done { posts in
                print("✅ 网络请求链完成: \(posts.count) 篇文章")
            }
            .catch { error in
                print("❌ 网络请求失败: \(error)")
            }
    }
    
    @objc private func imageLoadingDemo() {
        print("=== 图片加载模拟 ===")
        
        // 模拟图片加载流程
        loadImageFromCache(imageId: "avatar_123")
            .recover { error -> Promise<UIImage> in
                print("缓存未命中，从网络加载: \(error)")
                return self.loadImageFromNetwork(imageId: "avatar_123")
            }
            .then { image -> Promise<UIImage> in
                print("图片加载成功，开始处理")
                return self.processImage(image)
            }
            .then { processedImage -> Promise<Void> in
                print("图片处理完成，保存到缓存")
                return self.saveImageToCache(processedImage, imageId: "avatar_123")
            }
            .done { _ in
                print("✅ 图片加载流程完成")
            }
            .catch { error in
                print("❌ 图片加载失败: \(error)")
            }
    }
    
    @objc private func complexBusinessDemo() {
        print("=== 复杂业务场景 ===")
        
        // 模拟电商下单流程
        let productId = "product_123"
        let quantity = 2
        
        // 1. 检查库存
        checkInventory(productId: productId, quantity: quantity)
            .then { hasStock -> Promise<Product> in
                if hasStock {
                    print("✅ 库存充足")
                    return self.getProductDetails(productId: productId)
                } else {
                    throw CustomError(message: "库存不足")
                }
            }
            .then { product -> Promise<Order> in
                print("✅ 获取商品信息: \(product.name)")
                return self.createOrder(product: product, quantity: quantity)
            }
            .then { order -> Promise<PaymentResult> in
                print("✅ 创建订单成功: \(order.id)")
                return self.processPayment(orderId: order.id, amount: order.totalAmount)
            }
            .then { paymentResult -> Promise<Order> in
                print("✅ 支付成功: \(paymentResult.transactionId)")
                return self.updateOrderStatus(orderId: paymentResult.orderId, status: .paid)
            }
            .then { order -> Promise<ShippingInfo> in
                print("✅ 订单状态更新: \(order.status)")
                return self.arrangeShipping(orderId: order.id)
            }
            .done { shippingInfo in
                print("✅ 下单流程完成!")
                print("  订单号: \(shippingInfo.orderId)")
                print("  预计送达: \(shippingInfo.estimatedDelivery)")
                print("  快递单号: \(shippingInfo.trackingNumber)")
            }
            .catch { error in
                print("❌ 下单失败: \(error)")
            }
    }
    
    // MARK: - Helper Methods
    
    // 用户相关
    private func loginUser(username: String, password: String) -> Promise<User> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if username == "testuser" && password == "123456" {
                    let user = User(id: "user_123", name: "测试用户")
                    seal.fulfill(user)
                } else {
                    seal.reject(CustomError(message: "用户名或密码错误"))
                }
            }
        }
    }
    
    private func fetchUserProfile(userId: String) -> Promise<UserProfile> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let profile = UserProfile(userId: userId, email: "test@example.com", age: 25)
                seal.fulfill(profile)
            }
        }
    }
    

    
    // 错误处理相关
    private func simulateRiskyOperation() -> Promise<String> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if Int.random(in: 1...10) > 5 {
                    seal.fulfill("操作成功")
                } else {
                    seal.reject(CustomError(message: "随机失败"))
                }
            }
        }
    }
    
    private func simulateAnotherRiskyOperation() -> Promise<String> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if Int.random(in: 1...10) > 3 {
                    seal.fulfill("第二次操作成功")
                } else {
                    seal.reject(CustomError(message: "第二次操作失败"))
                }
            }
        }
    }
    
    // 并发操作相关
    private func fetchDataFromAPI1() -> Promise<String> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
                seal.fulfill("API1数据")
            }
        }
    }
    
    private func fetchDataFromAPI2() -> Promise<String> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
                seal.fulfill("API2数据")
            }
        }
    }
    
    private func fetchDataFromAPI3() -> Promise<String> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
                seal.fulfill("API3数据")
            }
        }
    }
    
    // 网络请求相关 - 重写为更类型安全的方法
    private func fetchUsers() -> Promise<[User]> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                if Int.random(in: 1...10) > 2 {
                    let users = [User(id: "user_1", name: "用户1"), User(id: "user_2", name: "用户2")]
                    seal.fulfill(users)
                } else {
                    seal.reject(CustomError(message: "获取用户列表失败"))
                }
            }
        }
    }
    
    private func fetchUser(userId: String) -> Promise<User> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                if Int.random(in: 1...10) > 2 {
                    let user = User(id: userId, name: "张三")
                    seal.fulfill(user)
                } else {
                    seal.reject(CustomError(message: "获取用户详情失败"))
                }
            }
        }
    }
    
    private func fetchUserPosts(userId: String) -> Promise<[Post]> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                if Int.random(in: 1...10) > 2 {
                    let posts = [
                        Post(id: "post_1", title: "第一篇文章", content: "内容1"),
                        Post(id: "post_2", title: "第二篇文章", content: "内容2")
                    ]
                    seal.fulfill(posts)
                } else {
                    seal.reject(CustomError(message: "获取用户文章失败"))
                }
            }
        }
    }
    
    // 图片加载相关
    private func loadImageFromCache(imageId: String) -> Promise<UIImage> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                // 模拟缓存未命中
                seal.reject(CustomError(message: "缓存未命中"))
            }
        }
    }
    
    private func loadImageFromNetwork(imageId: String) -> Promise<UIImage> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                let image = UIImage() // 模拟加载的图片
                seal.fulfill(image)
            }
        }
    }
    
    private func processImage(_ image: UIImage) -> Promise<UIImage> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // 模拟图片处理
                seal.fulfill(image)
            }
        }
    }
    
    private func saveImageToCache(_ image: UIImage, imageId: String) -> Promise<Void> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                seal.fulfill(())
            }
        }
    }
    
    // 电商业务相关
    private func checkInventory(productId: String, quantity: Int) -> Promise<Bool> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                seal.fulfill(true) // 模拟库存充足
            }
        }
    }
    
    private func getProductDetails(productId: String) -> Promise<Product> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                let product = Product(id: productId, name: "iPhone 15", price: 5999.0)
                seal.fulfill(product)
            }
        }
    }
    
    private func createOrder(product: Product, quantity: Int) -> Promise<Order> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                let order = Order(id: "order_\(UUID().uuidString)", totalAmount: product.price * Double(quantity))
                seal.fulfill(order)
            }
        }
    }
    
    private func processPayment(orderId: String, amount: Double) -> Promise<PaymentResult> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                let paymentResult = PaymentResult(orderId: orderId, transactionId: "txn_\(UUID().uuidString)")
                seal.fulfill(paymentResult)
            }
        }
    }
    
    private func updateOrderStatus(orderId: String, status: OrderStatus) -> Promise<Order> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let order = Order(id: orderId, totalAmount: 11998.0)
                seal.fulfill(order)
            }
        }
    }
    
    private func arrangeShipping(orderId: String) -> Promise<ShippingInfo> {
        return Promise { seal in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) {
                let shippingInfo = ShippingInfo(
                    orderId: orderId,
                    trackingNumber: "SF\(UUID().uuidString.prefix(8))",
                    estimatedDelivery: "2024-01-15"
                )
                seal.fulfill(shippingInfo)
            }
        }
    }
}

// MARK: - Data Models

struct User: Codable {
    let id: String
    let name: String
}

struct UserProfile: Codable {
    let userId: String
    let email: String
    let age: Int
}

struct Post: Codable {
    let id: String
    let title: String
    let content: String
}

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
}

struct Order: Codable {
    let id: String
    let totalAmount: Double
    var status: OrderStatus = .pending
}

struct PaymentResult: Codable {
    let orderId: String
    let transactionId: String
}

struct ShippingInfo: Codable {
    let orderId: String
    let trackingNumber: String
    let estimatedDelivery: String
}

enum OrderStatus: String, Codable {
    case pending
    case paid
    case shipped
    case delivered
}

struct CustomError: Error {
    let message: String
}
