//
//  DemoResponderChainVc.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/5/26.
//

import UIKit

// MARK: - Demo 1: 触摸事件传递与拦截
class TouchInterceptView: UIView {
    let name: String
    let intercept: Bool
    init(name: String, intercept: Bool = false) {
        self.name = name
        self.intercept = intercept
        super.init(frame: .zero)
        backgroundColor = intercept ? .systemRed.withAlphaComponent(0.3) : .systemBlue.withAlphaComponent(0.3)
        layer.cornerRadius = 8
    }
    required init?(coder: NSCoder) { fatalError() }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("【Demo1】\(name) 收到touchesBegan")
        if intercept {
            print("【Demo1】\(name) 拦截事件")
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
}

// MARK: - Demo 2: Target-Action 响应链查找
class ChainButton: UIButton {
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        print("【Demo2】ChainButton: 响应链查找target")
        super.sendAction(action, to: target, for: event)
    }
}

// MARK: - Demo 3: First Responder机制
class DemoTextField: UITextField {
    override func becomeFirstResponder() -> Bool {
        print("【Demo3】TextField 成为First Responder")
        return super.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        print("【Demo3】TextField 失去First Responder")
        return super.resignFirstResponder()
    }
}

// MARK: - Demo 5: 自定义事件冒泡
class BubbleView: UIView {
    let level: String
    init(level: String) {
        self.level = level
        super.init(frame: .zero)
        backgroundColor = level == "外层" ? .systemYellow.withAlphaComponent(0.3) : .systemOrange.withAlphaComponent(0.3)
        layer.cornerRadius = 8
    }
    required init?(coder: NSCoder) { fatalError() }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("【Demo5】\(level) 收到事件，继续冒泡")
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - Demo 6: 响应链扩展（全局日志收集）
class LogCollectorView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("【Demo6】LogCollectorView 收到事件，记录日志")
        next?.touchesBegan(touches, with: event)
    }
}

// MARK: - Demo 7: 超出父视图区域响应点击
class OutOfBoundsHitTestView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 让超出父视图的区域也能响应
        for subview in subviews {
            let converted = subview.convert(point, from: self)
            if subview.bounds.contains(converted) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
}

class OutOfBoundsButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("【Demo7】点击了超出父视图区域的按钮！")
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - 主控制器
class DemoResponderChainVc: YZBaseViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iOS响应链Demo"
        view.backgroundColor = .systemBackground
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fill
        
        addDemo1_TouchPassing()
        addDemo2_TargetAction()
        addDemo3_FirstResponder()
        addDemo4_ShakeEvent()
        addDemo5_BubbleEvent()
        addDemo6_LogCollector()
        addDemo7_OutOfBoundsHitTest()
    }
    
    // MARK: - Demo 1: 触摸事件传递与拦截
    private func addDemo1_TouchPassing() {
        let container = createDemoContainer(
            title: "Demo 1: 触摸事件传递与拦截",
            description: "点击重叠区域，观察事件传递和拦截",
            height: 220
        )
        let outerView = TouchInterceptView(name: "外层视图", intercept: false)
        let innerView = TouchInterceptView(name: "内层视图", intercept: true)
        container.addSubview(outerView)
        container.addSubview(innerView)
        outerView.frame = CGRect(x: 20, y: 60, width: 160, height: 120)
        innerView.frame = CGRect(x: 60, y: 100, width: 120, height: 80)
        stackView.addArrangedSubview(container)
    }
    // MARK: - Demo 2: Target-Action 响应链查找
    private func addDemo2_TargetAction() {
        let container = createDemoContainer(
            title: "Demo 2: Target-Action 响应链查找",
            description: "点击按钮，观察响应链查找过程",
            height: 140
        )
        let button = ChainButton(type: .system)
        button.setTitle("🎯 Target-Action链", for: .normal)
        button.frame = CGRect(x: 20, y: 60, width: 200, height: 50)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        container.addSubview(button)
        stackView.addArrangedSubview(container)
    }
    // MARK: - Demo 3: First Responder机制
    private func addDemo3_FirstResponder() {
        let container = createDemoContainer(
            title: "Demo 3: First Responder机制",
            description: "点击输入框，观察First Responder变化",
            height: 120
        )
        let textField = DemoTextField(frame: CGRect(x: 20, y: 60, width: 200, height: 40))
        textField.borderStyle = .roundedRect
        textField.placeholder = "点击输入框"
        container.addSubview(textField)
        stackView.addArrangedSubview(container)
    }
    // MARK: - Demo 4: 系统事件（摇一摇）
    private func addDemo4_ShakeEvent() {
        let container = createDemoContainer(
            title: "Demo 4: 系统事件（摇一摇）",
            description: "摇一摇设备，观察事件传递",
            height: 120
        )
        let label = UILabel(frame: CGRect(x: 20, y: 60, width: 200, height: 40))
        label.text = "📱 摇一摇设备\n观察控制台输出"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        container.addSubview(label)
        stackView.addArrangedSubview(container)
    }
    // MARK: - Demo 5: 自定义事件冒泡
    private func addDemo5_BubbleEvent() {
        let container = createDemoContainer(
            title: "Demo 5: 自定义事件冒泡",
            description: "点击内层区域，观察事件冒泡",
            height: 180
        )
        let outerBubble = BubbleView(level: "外层")
        let innerBubble = BubbleView(level: "内层")
        container.addSubview(outerBubble)
        outerBubble.addSubview(innerBubble)
        outerBubble.frame = CGRect(x: 20, y: 60, width: 160, height: 100)
        innerBubble.frame = CGRect(x: 20, y: 20, width: 120, height: 60)
        stackView.addArrangedSubview(container)
    }
    // MARK: - Demo 6: 响应链扩展（全局日志收集）
    private func addDemo6_LogCollector() {
        let container = createDemoContainer(
            title: "Demo 6: 响应链扩展（全局日志收集）",
            description: "点击区域，观察全局日志收集",
            height: 120
        )
        let logView = LogCollectorView(frame: CGRect(x: 20, y: 60, width: 200, height: 40))
        logView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
        logView.layer.cornerRadius = 8
        container.addSubview(logView)
        stackView.addArrangedSubview(container)
    }
    // MARK: - Demo 7: 超出父视图区域响应点击
    private func addDemo7_OutOfBoundsHitTest() {
        let container = createDemoContainer(
            title: "Demo 7: 超出父视图区域响应点击",
            description: "点击紫色按钮（部分超出灰色区域），观察是否能响应",
            height: 160
        )
        let hitTestView = OutOfBoundsHitTestView()
        hitTestView.backgroundColor = .systemGray5
        hitTestView.layer.cornerRadius = 8
        hitTestView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(hitTestView)
        NSLayoutConstraint.activate([
            hitTestView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            hitTestView.topAnchor.constraint(equalTo: container.topAnchor, constant: 60),
            hitTestView.widthAnchor.constraint(equalToConstant: 120),
            hitTestView.heightAnchor.constraint(equalToConstant: 60)
        ])
        let outButton = OutOfBoundsButton(type: .system)
        outButton.setTitle("超出区域按钮", for: .normal)
        outButton.backgroundColor = .systemPurple.withAlphaComponent(0.3)
        outButton.setTitleColor(.black, for: .normal)
        outButton.layer.cornerRadius = 8
        outButton.translatesAutoresizingMaskIntoConstraints = false
        hitTestView.addSubview(outButton)
        NSLayoutConstraint.activate([
            outButton.centerYAnchor.constraint(equalTo: hitTestView.centerYAnchor),
            outButton.leadingAnchor.constraint(equalTo: hitTestView.trailingAnchor, constant: -30), // 让按钮一部分超出
            outButton.widthAnchor.constraint(equalToConstant: 100),
            outButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        stackView.addArrangedSubview(container)
    }
    // MARK: - Helper
    private func createDemoContainer(title: String, description: String, height: CGFloat) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .systemBlue
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .systemGray
        descLabel.numberOfLines = 0
        container.addSubview(titleLabel)
        container.addSubview(descLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15)
        ])
        // 关键：为容器设置高度约束
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: height)
        ])
        return container
    }
    @objc func buttonAction() {
        print("✅ 按钮事件最终被ViewController处理")
    }
    // MARK: - 摇一摇事件响应
    override var canBecomeFirstResponder: Bool { true }
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        print("📱 摇一摇事件被响应链传递到ViewController")
    }
}

