//
//  Demo1_WorkerThread.m
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/10.
//

#import "Demo1_WorkerThread.h"

@implementation Demo1_WorkerThread

- (instancetype)initWithRemotePort:(NSMachPort *)remotePort {
    self = [super init];
    if (self) {
        // 保存远程端口（主线程端口）使用 strong
        _remotePort = remotePort;
        
        // 创建本地端口
        _localPort = [[NSMachPort alloc] init];
        _localPort.delegate = self;
        
        // 将端口添加到当前线程的RunLoop
        [[NSRunLoop currentRunLoop] addPort:_localPort forMode:NSDefaultRunLoopMode];
        
        NSLog(@"WorkerThread: Port setup completed. %@", NSThread.currentThread);
    }
    return self;
}

- (void)sendCheckin {
    [self sendMessage:kCheckinMessage data:nil];
    NSLog(@"WorkerThread: Check-in message sent");
}

- (void)sendMessage:(ThreadMessageID)msgid data:(NSData *)data {
    // 准备消息组件
    NSMutableArray *components = [NSMutableArray array];
    if (data) {
        [components addObject:data];
    }
    
    // 发送消息
    [self.remotePort sendBeforeDate:[NSDate date]
                            msgid:msgid
                       components:components
                             from:self.localPort
                         reserved:0];
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
    
    // 根据消息类型处理
    switch (msgid) {
        case kCheckinMessage:{
            NSLog(@"WorkerThread: Received check-in confirmation.  %@", NSThread.currentThread);
        }
            break;
            
        case kDataMessage: {
            
            NSString *text = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"WorkerThread: Received data message: %@ --- %@", text, NSThread.currentThread);
            
            // 发送回复
            NSData *response = [@"WorkerThread Response" dataUsingEncoding:NSUTF8StringEncoding];
            [self sendMessage:kDataMessage data:response];
            break;
        }

        default:
            NSLog(@"WorkerThread: Received unknown message: %lu", (unsigned long)msgid);
            break;
    }
}


@end
