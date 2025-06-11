//
//  Demo1_MainThread.m
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/10.
//

#import "Demo1_MainThread.h"
#import "Demo1_WorkerThread.h"

@interface Demo1_MainThread ()

@property (nonatomic, strong) NSThread *workerThread;

@end

@implementation Demo1_MainThread

- (void)launchWorkerThread {
    // 创建主线程端口
    _mainPort = [[NSMachPort alloc] init];
    _mainPort.delegate = self;
    [[NSRunLoop mainRunLoop] addPort:_mainPort forMode:NSDefaultRunLoopMode];
    
    NSLog(@"MainThread: Starting worker thread...");
    
    // 创建并启动工作线程
    [NSThread detachNewThreadWithBlock:^{
        @autoreleasepool {
            // 创建工作线程实例
            Demo1_WorkerThread *worker = [[Demo1_WorkerThread alloc] initWithRemotePort:self.mainPort];
            
            // 发送初始消息
            [worker sendCheckin];
            
            // 运行RunLoop保持线程活跃
            [[NSRunLoop currentRunLoop] run];

            NSLog(@"WorkerThread: RunLoop started");
        }
    }];
}

- (void)sendMessageToWorker:(NSString *)message {
    if (!self.workerPort) {
        NSLog(@"MainThread: Worker port not available yet");
        return;
    }
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.workerPort sendBeforeDate:[NSDate date]
                           msgid:kDataMessage
                      components:@[data].mutableCopy
                            from:self.mainPort
                        reserved:0];
    
    NSLog(@"MainThread: Sent message to worker: %@", message);
}

// NSMachPortDelegate 方法 - 处理接收到的消息
- (void)handleMachMessage:(void *)msg {
    // 将原始消息转换为 mach_msg 结构
    mach_msg_header_t *header = (mach_msg_header_t *)msg;
    
    // 解析消息ID
    ThreadMessageID msgid = (ThreadMessageID)header->msgh_id;
    NSData *receivedData = nil;
    
    // 检查是否有消息体
    if (header->msgh_size > sizeof(mach_msg_header_t)) {
        // 获取消息体
        mach_msg_body_t *body = (mach_msg_body_t *)(header + 1);
        if (body->msgh_descriptor_count > 0) {
            mach_msg_descriptor_t *descriptor = (mach_msg_descriptor_t *)(body + 1);
            if (descriptor->type.type == MACH_MSG_OOL_DESCRIPTOR) {
                // 处理 OOL（out-of-line）数据
                mach_msg_ool_descriptor_t *ool = &descriptor->out_of_line;
                receivedData = [NSData dataWithBytes:ool->address length:ool->size];
            }
        }
    }
    
    switch (msgid) {
        case kCheckinMessage:
            // 保存工作线程的端口 - 使用正确的端口创建方法
            mach_port_t remotePort = header->msgh_remote_port;
            self.workerPort = [[NSMachPort alloc] initWithMachPort:remotePort];
            
            NSLog(@"MainThread: Received worker check-in");
            
            // 发送欢迎消息
            [self sendMessageToWorker:@"Hello from MainThread!"];
            break;
            
        case kDataMessage: {
            if (receivedData) {
                NSString *text = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                NSLog(@"MainThread: Received response: %@", text);
            }
            break;
        }
            
        default:
            NSLog(@"MainThread: Received unknown message: %lu", (unsigned long)msgid);
            break;
    }
}


@end
