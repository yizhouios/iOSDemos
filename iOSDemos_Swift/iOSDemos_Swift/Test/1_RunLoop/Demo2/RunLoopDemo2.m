//
//  RunLoopManager.m
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/18.
//

#import "RunLoopDemo2.h"

@interface RunLoopDemo2 () <NSMachPortDelegate>
@property (nonatomic, strong) NSPort *keepAlivePort;
@end

@implementation RunLoopDemo2

- (instancetype)init {
    self = [super init];
    if (self) {
        _customSource = [[CustomRunLoopSource alloc] init];
        _isRunning = NO;
        
        // 设置命令处理回调
        _customSource.commandHandler = ^(NSInteger command, id data) {
            NSLog(@"[WORKER THREAD] Process command: %ld, data: %@, thread: %@", (long)command, data, NSThread.currentThread);
        };
    }
    return self;
}

- (void)start {
    if (_isRunning) return;
    
    _workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(workerThreadMain) object:nil];
    [_workerThread start];
    _isRunning = YES;
    NSLog(@"RunLoop manager started");
}

- (void)stop {
    if (!_isRunning) return;
    
    _isRunning = NO;
    [_customSource invalidate];
    
    if (_workerThread && _workerThread.isExecuting) {
        // 停止RunLoop
        CFRunLoopStop(CFRunLoopGetCurrent());
        [_workerThread cancel];
        [NSThread sleepForTimeInterval:0.2];
    }
    
    _workerThread = nil;
    _keepAlivePort = nil;
    NSLog(@"RunLoop manager stopped");
}

- (void)sendCommand:(NSInteger)command withData:(id)data {
    if (!_isRunning || !_workerThread) return;
    
    [_customSource addCommand:command withData:data];
    [_customSource signalSource];
    
    // 唤醒工作线程的RunLoop
    CFRunLoopRef workerRunLoop = CFRunLoopGetCurrent();
    CFRunLoopWakeUp(workerRunLoop);
    NSLog(@"Command signaled to worker thread");
}

- (void)workerThreadMain {
    @autoreleasepool {
        NSLog(@"Worker thread started %@", NSThread.currentThread);
        
        // 创建NSPort保持RunLoop运行
        _keepAlivePort = [NSMachPort port];
        [_keepAlivePort setDelegate:self];
        [[NSRunLoop currentRunLoop] addPort:_keepAlivePort forMode:NSDefaultRunLoopMode];
        
        // 将自定义输入源添加到工作线程的RunLoop
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        [_customSource addToRunLoop:runLoop forMode:kCFRunLoopDefaultMode];
        
        NSLog(@"Worker thread RunLoop initialized");
        
        // 运行RunLoop（文档推荐方式）
        while (_isRunning) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);
        }
        
        NSLog(@"Worker thread RunLoop stopped");
    }
}

#pragma mark - NSPortDelegate
- (void)handlePortMessage:(NSPortMessage *)message {
    NSLog(@"Keep-alive port message received");
}

@end
