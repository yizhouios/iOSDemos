//
//  Demo_3_OffScreenRenderVc.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/8/6.
//

import UIKit

// MARK: - 主控制器
class Demo_3_OffScreenRenderVc: YZBaseViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "离屏渲染"
        view.backgroundColor = .systemBackground
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
        addOffscreenDemoViews()
    }
    
    private func addOffscreenDemoViews() {
        // view1: cornerRadius + masksToBounds
        let view1 = demoView(title: "view1: cornerRadius + masksToBounds", color: .systemRed)
        view1.layer.cornerRadius = 40
        view1.layer.masksToBounds = true
        stackView.addArrangedSubview(view1)
        // view2: shadow
        let view2 = demoView(title: "view2: shadow", color: .systemBlue)
        view2.layer.shadowColor = UIColor.black.cgColor
        view2.layer.shadowOffset = CGSize(width: 0, height: 4)
        view2.layer.shadowOpacity = 0.5
        view2.layer.shadowRadius = 8
        stackView.addArrangedSubview(view2)
        // view3: shouldRasterize
        let view3 = demoView(title: "view3: shouldRasterize", color: .systemGreen)
        view3.layer.shouldRasterize = true
        view3.layer.rasterizationScale = UIScreen.main.scale
        view3.layer.cornerRadius = 40
        stackView.addArrangedSubview(view3)
        // view4: layer.mask
        let view4 = demoView(title: "view4: layer.mask", color: .systemOrange)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 220, height: 60)).cgPath
        maskLayer.frame = CGRect(x: 0, y: 0, width: 220, height: 60)
        view4.layer.mask = maskLayer
        stackView.addArrangedSubview(view4)
        // view5: borderWidth + masksToBounds
        let view5 = demoView(title: "view5: borderWidth + masksToBounds", color: .systemPurple)
        view5.layer.borderWidth = 4
        view5.layer.borderColor = UIColor.black.cgColor
        view5.layer.cornerRadius = 20
        view5.layer.masksToBounds = true
        stackView.addArrangedSubview(view5)
        // view6: UIVisualEffectView
        let view6 = UIView()
        view6.backgroundColor = .clear
        view6.heightAnchor.constraint(equalToConstant: 80).isActive = true
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = CGRect(x: 0, y: 0, width: 240, height: 80)
        blur.layer.cornerRadius = 16
        blur.clipsToBounds = true
        view6.addSubview(blur)
        let label6 = UILabel(frame: CGRect(x: 10, y: 20, width: 220, height: 40))
        label6.text = "view6: UIVisualEffectView"
        label6.textAlignment = .center
        blur.contentView.addSubview(label6)
        stackView.addArrangedSubview(view6)
        // view7: group opacity (父视图alpha < 1)
        let view7 = demoView(title: "view7: group opacity (alpha < 1)", color: .systemTeal)
        view7.layer.cornerRadius = 40
        view7.alpha = 0.5
        stackView.addArrangedSubview(view7)
        // view8: UILabel带阴影
        let view8 = demoView(title: "view8: UILabel阴影", color: .systemGray)
        let label8 = UILabel(frame: CGRect(x: 10, y: 20, width: 220, height: 40))
        label8.text = "阴影文本"
        label8.font = UIFont.boldSystemFont(ofSize: 24)
        label8.textAlignment = .center
        label8.textColor = .black
        label8.layer.shadowColor = UIColor.red.cgColor
        label8.layer.shadowOffset = CGSize(width: 2, height: 2)
        label8.layer.shadowOpacity = 0.8
        label8.layer.shadowRadius = 2
        view8.addSubview(label8)
        stackView.addArrangedSubview(view8)
        // view9: CAShapeLayer
        let view9 = demoView(title: "view9: CAShapeLayer", color: .clear)
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: CGRect(x: 20, y: 20, width: 180, height: 40), cornerRadius: 20).cgPath
        shape.fillColor = UIColor.systemPink.cgColor
        view9.layer.addSublayer(shape)
        stackView.addArrangedSubview(view9)
        // view10: CAGradientLayer
        let view10 = demoView(title: "view10: CAGradientLayer", color: .clear)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        gradient.frame = CGRect(x: 0, y: 0, width: 240, height: 80)
        view10.layer.addSublayer(gradient)
        stackView.addArrangedSubview(view10)
    }
    
    private func demoView(title: String, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color
        v.layer.cornerRadius = 12
        v.heightAnchor.constraint(equalToConstant: 80).isActive = true
        let label = UILabel(frame: CGRect(x: 10, y: 20, width: 220, height: 40))
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        v.addSubview(label)
        return v
    }
}
