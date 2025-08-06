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
        addNonOffscreenDemoViews()
        addNonOffscreenImages()
    }
    
    private func addOffscreenDemoViews() {
        let container = createDemoContainer(title: "触发离屏渲染的场景")
        stackView.addArrangedSubview(container)
        
        // view1: cornerRadius + masksToBounds
        let view1 = demoView(title: "", color: .systemRed)
        view1.layer.cornerRadius = 40
        view1.layer.masksToBounds = true
        stackView.addArrangedSubview(createViewWithTitle("view1: cornerRadius + masksToBounds", view: view1))
        // view2: shadow
        let view2 = demoView(title: "", color: .systemBlue)
        view2.layer.shadowColor = UIColor.black.cgColor
        view2.layer.shadowOffset = CGSize(width: 0, height: 4)
        view2.layer.shadowOpacity = 0.5
        view2.layer.shadowRadius = 8
        stackView.addArrangedSubview(createViewWithTitle("view2: shadow", view: view2))
        // view3: shouldRasterize
        let view3 = demoView(title: "", color: .systemGreen)
        view3.layer.shouldRasterize = true
        view3.layer.rasterizationScale = UIScreen.main.scale
        view3.layer.cornerRadius = 40
        stackView.addArrangedSubview(createViewWithTitle("view3: shouldRasterize", view: view3))
        // view4: layer.mask
        let view4 = demoView(title: "", color: .systemOrange)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 220, height: 60)).cgPath
        maskLayer.frame = CGRect(x: 0, y: 0, width: 220, height: 60)
        view4.layer.mask = maskLayer
        stackView.addArrangedSubview(createViewWithTitle("view4: layer.mask", view: view4))
        // view5: borderWidth + masksToBounds
        let view5 = demoView(title: "", color: .systemPurple)
        view5.layer.borderWidth = 4
        view5.layer.borderColor = UIColor.black.cgColor
        view5.layer.cornerRadius = 20
        view5.layer.masksToBounds = true
        stackView.addArrangedSubview(createViewWithTitle("view5: borderWidth + masksToBounds", view: view5))
        // view6: UIVisualEffectView
        let view6 = UIView()
        view6.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = CGRect(x: 0, y: 0, width: 240, height: 80)
        blur.layer.cornerRadius = 16
        blur.clipsToBounds = true
        view6.addSubview(blur)
        let label6 = UILabel(frame: CGRect(x: 10, y: 20, width: 220, height: 40))
        label6.text = "UIVisualEffectView"
        label6.textAlignment = .center
        blur.contentView.addSubview(label6)
        stackView.addArrangedSubview(createViewWithTitle("view6: UIVisualEffectView", view: view6))
        // view7: group opacity (父视图alpha < 1)
        let view7 = demoView(title: "", color: .systemTeal)
        view7.layer.cornerRadius = 40
        view7.alpha = 0.5
        stackView.addArrangedSubview(createViewWithTitle("view7: group opacity (alpha < 1)", view: view7))
        // view8: UILabel带阴影
        let view8 = demoView(title: "", color: .systemGray)
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
        stackView.addArrangedSubview(createViewWithTitle("view8: UILabel阴影", view: view8))
    }
    
    private func addNonOffscreenDemoViews() {
        let container = createDemoContainer(title: "非离屏渲染的圆角方法")
        stackView.addArrangedSubview(container)
        
        // view12: 通过UIBezierPath贝塞尔曲线绘制圆角
        let view12 = BezierPathRoundedView(title: "")
        stackView.addArrangedSubview(createViewWithTitle("view12: UIBezierPath贝塞尔曲线", view: view12))
        
        // view13: 通过CoreGraphics绘制圆角
        let view13 = CoreGraphicsRoundedView(title: "")
        stackView.addArrangedSubview(createViewWithTitle("view13: CoreGraphics绘制", view: view13))
        
        // view14: 通过CoreGraphics绘制圆角图片
        let view14 = demoView(title: "", color: .clear)
        let roundedImageView = CoreGraphicsRoundedImageView(frame: CGRect(x: 0, y: 0, width: 240, height: 80))
        roundedImageView.image = createGradientImage()
        view14.addSubview(roundedImageView)
        stackView.addArrangedSubview(createViewWithTitle("view14: CoreGraphics圆角图片", view: view14))
    }
    
    // MARK: - 图片圆角非离屏渲染演示
    private func addNonOffscreenImages() {
        let container = createDemoContainer(title: "图片圆角非离屏渲染方法")
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(container)
        
        // image1: 通过CoreGraphics绘制圆角图片
        let image1 = demoView(title: "", color: .clear)
        let roundedImageView1 = CoreGraphicsRoundedImageView(frame: CGRect(x: 0, y: 0, width: 240, height: 80))
        roundedImageView1.image = createGradientImage()
        image1.addSubview(roundedImageView1)
        stackView.addArrangedSubview(createViewWithTitle("image1: CoreGraphics圆角图片", view: image1))
        
        // image2: 通过自定义UIImageView子类实现圆角
        let image2 = demoView(title: "", color: .clear)
        let customImageView = CustomRoundedImageView(frame: CGRect(x: 0, y: 0, width: 240, height: 80))
        customImageView.image = createGradientImage()
        customImageView.contentMode = .scaleAspectFill
        image2.addSubview(customImageView)
        stackView.addArrangedSubview(createViewWithTitle("image2: 自定义UIImageView圆角", view: image2))
        
        // image3: 通过预处理的圆角图片
        let image3 = demoView(title: "", color: .clear)
        let imageView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 240, height: 80))
        imageView3.image = createRoundedImage()
        imageView3.contentMode = .scaleAspectFill
        image3.addSubview(imageView3)
        stackView.addArrangedSubview(createViewWithTitle("image3: 预处理圆角图片", view: image3))
        
        // image4: 通过UIBezierPath绘制圆角图片
        let image4 = demoView(title: "", color: .clear)
        let roundedImageView4 = BezierPathRoundedImageView(frame: CGRect(x: 0, y: 0, width: 240, height: 80))
        roundedImageView4.image = createGradientImage()
        image4.addSubview(roundedImageView4)
        stackView.addArrangedSubview(createViewWithTitle("image4: UIBezierPath圆角图片", view: image4))
    }
    
    private func createGradientImage() -> UIImage {
        let size = CGSize(width: 240, height: 80)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        let colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: [])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createRoundedImage() -> UIImage {
        let size = CGSize(width: 240, height: 80)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // 创建圆角路径
        let roundedRect = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 40)
        roundedRect.addClip()
        
        // 绘制渐变背景
        let colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: [])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createDemoContainer(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .systemBlue
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return container
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
    
    private func createViewWithTitle(_ title: String, view: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // 创建标题标签
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .systemBlue
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置view的约束
        view.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            view.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return container
    }
}

// MARK: - 通过UIBezierPath贝塞尔曲线绘制圆角的View
class BezierPathRoundedView: UIView {
    private let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 保存当前图形状态
        context.saveGState()
        
        // 用贝塞尔曲线绘制闭合带圆角的矩形
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 40)
        
        // 在上下文中设置只有内部可见
        roundedRect.addClip()
        
        // 绘制背景色
        UIColor.systemBrown.setFill()
        context.fill(rect)
        
        // 恢复图形状态
        context.restoreGState()
        
        // 绘制文字
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        let textSize = title.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width - textSize.width) / 2, y: (rect.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        title.draw(in: textRect, withAttributes: attributes)
    }
}

// MARK: - 通过Core Graphics绘制圆角的View
class CoreGraphicsRoundedView: UIView {
    private let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 保存当前状态
        context.saveGState()
        
        // 使用Core Graphics + CGPath创建圆角路径
        let path = CGMutablePath()
        let radius: CGFloat = 40
        
        // 手动构建圆角矩形路径
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: -CGFloat.pi/2, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: false)
        path.closeSubpath()
        
        context.addPath(path)
        context.setFillColor(UIColor.systemCyan.cgColor)
        context.fillPath()
        
        // 恢复状态
        context.restoreGState()
        
        // 绘制文字
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        let textSize = title.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width - textSize.width) / 2, y: (rect.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        title.draw(in: textRect, withAttributes: attributes)
    }
}

// MARK: - 通过Core Graphics绘制圆角图片的View
class CoreGraphicsRoundedImageView: UIView {
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        guard let image = image else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 保存当前状态
        context.saveGState()
        
        // 使用Core Graphics创建圆角裁剪区域
        let path = CGMutablePath()
        let radius: CGFloat = 40
        
        // 手动构建圆角矩形路径
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: -CGFloat.pi/2, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: false)
        path.closeSubpath()
        
        // 设置裁剪区域
        context.addPath(path)
        context.clip()
        
        // 绘制图片
        image.draw(in: rect)
        
        // 恢复状态
        context.restoreGState()
    }
}

// MARK: - 通过UIBezierPath绘制圆角图片的View
class BezierPathRoundedImageView: UIView {
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        guard let image = image else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 保存当前状态
        context.saveGState()
        
        // 使用UIBezierPath创建圆角裁剪区域
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 40)
        roundedRect.addClip()
        
        // 绘制图片
        image.draw(in: rect)
        
        // 恢复状态
        context.restoreGState()
    }
}

// MARK: - 自定义UIImageView子类实现圆角
class CustomRoundedImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override var image: UIImage? {
        didSet {
            updateRoundedImage()
        }
    }
    
    private func updateRoundedImage() {
        guard let image = image else { return }
        
        // 创建圆角图片
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        _ = UIGraphicsGetCurrentContext()!
        
        // 创建圆角路径
        let roundedRect = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 40)
        roundedRect.addClip()
        
        // 绘制图片
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 设置圆角图片
        super.image = roundedImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateRoundedImage()
    }
}
