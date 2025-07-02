//
//  YZListPopupView.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/7/1.
//

import UIKit
import SnapKit

class ListPopupView: UIView {
    // MARK: - 类型定义
    typealias ItemSelectionHandler = (Int, String) -> Void
    
    // MARK: - 属性
    private let title: String
    private let items: [String]
    private var itemSelectionHandler: ItemSelectionHandler?
    
    // UI 组件
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain) // 明确指定样式
    private let closeButton = UIButton(type: .system)
    
    // MARK: - 初始化
    init(title: String, items: [String]) {
        self.title = title
        self.items = items
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        // 设置背景
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // 设置容器视图
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        // 设置标题标签
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        // 设置关闭按钮
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .gray
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        // 设置表格视图
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)) // 移除顶部空白
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)) // 移除底部空白
        containerView.addSubview(tableView)
        
        // 设置约束
        setupConstraints()
        
        // 初始隐藏并设置动画
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
    }
    
    // MARK: - 约束设置
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            make.width.lessThanOrEqualTo(300)
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.7)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(closeButton.snp.leading).offset(-8)
            make.bottom.lessThanOrEqualTo(tableView.snp.top).offset(-12)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.size.equalTo(24)
            make.centerY.equalTo(titleLabel)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 显示/隐藏方法
    func show(in viewController: UIViewController) {
        viewController.view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 强制布局计算
        layoutIfNeeded()
        
        // 动画显示
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - 事件处理
    @objc private func closeButtonTapped() {
        dismiss()
    }
    
    func onItemSelected(_ handler: @escaping ItemSelectionHandler) {
        self.itemSelectionHandler = handler
    }
}

// MARK: - UITableViewDataSource
extension ListPopupView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListPopupView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = items[indexPath.row]
        itemSelectionHandler?(indexPath.row, selectedItem)
        dismiss()
    }
}
