//
//  CustomRunLoopSource.m
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/18.
//

#import "CustomRunLoopSource.h"

// 全局回调函数声明（文档要求的三个核心回调）
void RunLoopSource_ScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSource_PerformRoutine(void *info);
void RunLoopSource_CancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);

@interface CustomRunLoopSource ()
@property (nonatomic, strong) NSMutableArray *commandQueue;
@property (nonatomic, assign) CFRunLoopSourceRef sourceRef;
@property (nonatomic, assign) BOOL isValid;
@end

@implementation CustomRunLoopSource

- (instancetype)init {
    self = [super init];
    if (self) {
        _commandQueue = [NSMutableArray array];
        _isValid = YES;
        
        // 创建自定义输入源
        CFRunLoopSourceContext sourceContext = {
            .version = 0,
            .info = (__bridge void *)self,
            .retain = NULL,
            .release = NULL,
            .copyDescription = NULL,
            .equal = NULL,
            .hash = NULL,
            .schedule = RunLoopSource_ScheduleRoutine,
            .cancel = RunLoopSource_CancelRoutine,
            .perform = RunLoopSource_PerformRoutine
        };
        
        // 文档要求：使用CFRunLoopSourceCreate创建输入源
        _sourceRef = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

- (void)addToRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode {
    if (!_sourceRef || !runLoop || !mode || !_isValid) return;
    
    // 文档要求：使用CFRunLoopAddSource将输入源添加到RunLoop
    CFRunLoopAddSource(runLoop, _sourceRef, mode);
    NSLog(@"Custom input source added to RunLoop");
}

- (void)invalidate {
    if (!_isValid) return;
    
    _isValid = NO;
    if (_sourceRef) {
        CFRunLoopSourceInvalidate(_sourceRef);
        CFRelease(_sourceRef);
        _sourceRef = NULL;
    }
    [_commandQueue removeAllObjects];
    NSLog(@"Custom input source invalidated");
}

- (void)addCommand:(NSInteger)command withData:(id)data {
    @synchronized(self) {
        [_commandQueue addObject:@{@"command": @(command), @"data": data}];
    }
    NSLog(@"Added command: %ld", (long)command);
}

- (void)signalSource {
    if (!_sourceRef || !_isValid) return;
    
    // 文档要求：使用CFRunLoopSourceSignal触发输入源
    CFRunLoopSourceSignal(_sourceRef);
    NSLog(@"Input source signaled");
}

- (void)processCommands {
    if (!self.commandHandler || _commandQueue.count == 0) return;
    
    NSArray *commandsCopy;
    @synchronized(self) {
        commandsCopy = [_commandQueue copy];
        [_commandQueue removeAllObjects];
    }
    
    NSLog(@"Processing %lu commands", (unsigned long)commandsCopy.count);
    for (NSDictionary *cmd in commandsCopy) {
        NSInteger command = [cmd[@"command"] integerValue];
        id data = cmd[@"data"];
        self.commandHandler(command, data);
    }
}

@end

// MARK: - 文档要求的三个核心C回调函数实现
void RunLoopSource_ScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode) {
    CustomRunLoopSource *source = (__bridge CustomRunLoopSource *)(info);
    NSLog(@"【RunLoopSourceRoutine】Schedule callback: Source added to RunLoop mode %@", (__bridge NSString *)mode);
}

void RunLoopSource_PerformRoutine(void *info) {
    CustomRunLoopSource *source = (__bridge CustomRunLoopSource *)(info);
    NSLog(@"【RunLoopSourceRoutine】Perform callback: Source triggered, processing commands");
    [source processCommands];
}

void RunLoopSource_CancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode) {
    CustomRunLoopSource *source = (__bridge CustomRunLoopSource *)(info);
    NSLog(@"【RunLoopSourceRoutine】Cancel callback: Source removed from RunLoop mode %@", (__bridge NSString *)mode);
}
