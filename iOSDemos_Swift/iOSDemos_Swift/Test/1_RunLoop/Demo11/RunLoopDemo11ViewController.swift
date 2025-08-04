//
//  RunLoopDemo11ViewController.swift
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/8/3.
//

import UIKit

// 模拟创建大型临时对象的类
class LargeTemporaryObject {
    // 每个对象占用约 2MB 内存
    var buffer: [UInt8] = Array(repeating: 0, count: 2_000_000)
    var id: Int
    
    init(id: Int) {
        self.id = id
        // 初始化时填充随机数据
        for i in 0..<buffer.count {
            buffer[i] = UInt8.random(in: 0...255)
        }
    }
    
    // 模拟一些计算密集型操作
    func performHeavyCalculation() -> Double {
        var result: Double = 0.0
        for i in stride(from: 0, to: buffer.count, by: 100) {
            result += Double(buffer[i]) * sin(Double(i))
        }
        return result
    }
    
    // 模拟数据处理
    func processData() -> [UInt8] {
        return buffer.map { $0 &+ 1 }
    }
}

class RunLoopDemo11ViewController: UIViewController {
    
    // MARK: - UI Elements
    private var memoryChartView: UIView!
    private var memoryUsageLabel: UILabel!
    private var statusLabel: UILabel!
    private var progressView: UIProgressView!
    private var startButton: UIButton!
    private var stopButton: UIButton!
    private var clearButton: UIButton!
    
    // MARK: - Properties
    private var isTestRunning = false
    private var memoryHistory: [Double] = []
    private var timer: Timer?
    private var testType: TestType = .withoutAutoreleasepool
    private var processedCount = 0
    private var totalObjects = 1000
    
    enum TestType {
        case withAutoreleasepool
        case withoutAutoreleasepool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Autoreleasepool 内存测试"
        view.backgroundColor = .systemBackground
        setupUI()
        startMemoryMonitoring()
    }
    
    deinit {
        stopMemoryMonitoring()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 内存图表视图
        memoryChartView = UIView()
        memoryChartView.backgroundColor = .systemGray6
        memoryChartView.layer.cornerRadius = 8
        memoryChartView.layer.borderWidth = 1
        memoryChartView.layer.borderColor = UIColor.systemGray4.cgColor
        view.addSubview(memoryChartView)
        
        // 内存使用标签
        memoryUsageLabel = UILabel()
        memoryUsageLabel.textAlignment = .center
        memoryUsageLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        memoryUsageLabel.textColor = .systemBlue
        view.addSubview(memoryUsageLabel)
        
        // 状态标签
        statusLabel = UILabel()
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .systemGray
        statusLabel.text = "选择测试类型并点击开始"
        view.addSubview(statusLabel)
        
        // 进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        view.addSubview(progressView)
        
        // 按钮
        startButton = createButton(title: "开始测试 (无 autoreleasepool)", action: #selector(startTest))
        stopButton = createButton(title: "停止测试", action: #selector(stopTest))
        clearButton = createButton(title: "清除图表", action: #selector(clearChart))
        
        view.addSubview(startButton)
        view.addSubview(stopButton)
        view.addSubview(clearButton)
        
        // 设置约束
        setupConstraints()
        
        // 初始状态
        stopButton.isEnabled = false
        updateMemoryUsage()
    }
    
    private func setupConstraints() {
        memoryChartView.translatesAutoresizingMaskIntoConstraints = false
        memoryUsageLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 内存图表
            memoryChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            memoryChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memoryChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            memoryChartView.heightAnchor.constraint(equalToConstant: 200),
            
            // 内存使用标签
            memoryUsageLabel.topAnchor.constraint(equalTo: memoryChartView.bottomAnchor, constant: 10),
            memoryUsageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memoryUsageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 状态标签
            statusLabel.topAnchor.constraint(equalTo: memoryUsageLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 进度条
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 按钮
            startButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 30),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 15),
            stopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stopButton.heightAnchor.constraint(equalToConstant: 50),
            
            clearButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 15),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Memory Monitoring
    private func startMemoryMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func stopMemoryMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMemoryUsage() {
        let currentMemory = getCurrentMemoryUsage()
        memoryHistory.append(currentMemory)
        
        // 保持最近100个数据点
        if memoryHistory.count > 100 {
            memoryHistory.removeFirst()
        }
        
        memoryUsageLabel.text = String(format: "当前内存: %.1f MB | 峰值: %.1f MB | 增长: %.1f MB", 
                                      currentMemory, 
                                      memoryHistory.max() ?? 0,
                                      currentMemory - (memoryHistory.first ?? currentMemory))
        
        drawMemoryChart()
    }
    
    private func getCurrentMemoryUsage() -> Double {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0.0
        }
        
        return Double(taskInfo.phys_footprint) / (1024 * 1024)
    }
    
    private func drawMemoryChart() {
        // 清除之前的绘制
        memoryChartView.layer.sublayers?.removeAll()
        
        guard !memoryHistory.isEmpty else { return }
        
        let chartLayer = CAShapeLayer()
        chartLayer.strokeColor = UIColor.systemBlue.cgColor
        chartLayer.fillColor = UIColor.clear.cgColor
        chartLayer.lineWidth = 2
        
        let path = UIBezierPath()
        let width = memoryChartView.bounds.width
        let height = memoryChartView.bounds.height
        let maxMemory = memoryHistory.max() ?? 1.0
        let minMemory = memoryHistory.min() ?? 0.0
        let memoryRange = maxMemory - minMemory
        
        for (index, memory) in memoryHistory.enumerated() {
            let x = CGFloat(index) / CGFloat(memoryHistory.count - 1) * width
            let normalizedMemory = memoryRange > 0 ? (memory - minMemory) / memoryRange : 0.5
            let y = height - (normalizedMemory * height)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        chartLayer.path = path.cgPath
        memoryChartView.layer.addSublayer(chartLayer)
    }
    
    // MARK: - Test Methods
    @objc private func startTest() {
        guard !isTestRunning else { return }
        
        isTestRunning = true
        processedCount = 0
        memoryHistory.removeAll()
        
        startButton.isEnabled = false
        stopButton.isEnabled = true
        
        // 根据按钮标题判断测试类型
        if startButton.title(for: .normal)?.contains("无 autoreleasepool") == true {
            testType = .withoutAutoreleasepool
            startButton.setTitle("开始测试 (使用 autoreleasepool)", for: .normal)
        } else {
            testType = .withAutoreleasepool
            startButton.setTitle("开始测试 (无 autoreleasepool)", for: .normal)
        }
        
        runMemoryTest()
    }
    
    @objc private func stopTest() {
        isTestRunning = false
        startButton.isEnabled = true
        stopButton.isEnabled = false
        updateStatus("测试已停止")
    }
    
    @objc private func clearChart() {
        memoryHistory.removeAll()
        drawMemoryChart()
        updateStatus("图表已清除")
    }
    
    private func runMemoryTest() {
        let testName = testType == .withAutoreleasepool ? "使用 autoreleasepool" : "未使用 autoreleasepool"
        updateStatus("开始测试: \(testName)")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let startMemory = self.getCurrentMemoryUsage()
            let startTime = Date()
            
            for i in 1...self.totalObjects {
                guard self.isTestRunning else { break }
                
                if self.testType == .withAutoreleasepool {
                    // 使用 autoreleasepool
                    autoreleasepool {
                        self.createAndProcessObject(id: i)
                    }
                } else {
                    // 不使用 autoreleasepool
                    self.createAndProcessObject(id: i)
                }
                
                // 更新进度
                DispatchQueue.main.async {
                    self.processedCount = i
                    self.progressView.progress = Float(i) / Float(self.totalObjects)
                    self.updateStatus("已处理: \(i)/\(self.totalObjects) 个对象")
                }
                
                // 添加一些延迟以观察内存变化
                Thread.sleep(forTimeInterval: 0.01)
            }
            
            DispatchQueue.main.async {
                let endMemory = self.getCurrentMemoryUsage()
                let endTime = Date()
                let duration = endTime.timeIntervalSince(startTime)
                let memoryIncrease = endMemory - startMemory
                
                let resultMessage = String(format: "测试完成!\n峰值内存: %.1f MB\n内存增长: %.1f MB\n耗时: %.2f 秒",
                                         self.memoryHistory.max() ?? 0,
                                         memoryIncrease,
                                         duration)
                
                self.updateStatus(resultMessage)
                self.isTestRunning = false
                self.startButton.isEnabled = true
                self.stopButton.isEnabled = false
            }
        }
    }
    
    private func createAndProcessObject(id: Int) {
        // 创建大型临时对象
        let object = LargeTemporaryObject(id: id)
        
        // 执行计算密集型操作
        let result = object.performHeavyCalculation()
        
        // 处理数据
        let processedData = object.processData()
        
        // 模拟使用处理后的数据
        simulateDataUsage(processedData, result: result)
    }
    
    private func simulateDataUsage(_ data: [UInt8], result: Double) {
        // 模拟数据使用 - 计算校验和
        var checksum: UInt64 = 0
        for byte in data {
            checksum &+= UInt64(byte)
        }
        
        // 防止编译器优化
        if checksum == 0 && result == 0 {
            print("不可能发生")
        }
    }
    
    private func updateStatus(_ message: String) {
        statusLabel.text = message
    }
} 