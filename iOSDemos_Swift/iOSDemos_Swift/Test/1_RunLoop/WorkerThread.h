//
//  WorkerThread.h
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 消息类型
typedef NS_ENUM(NSUInteger, ThreadMessageID) {
    kCheckinMessage = 100,
    kDataMessage = 101
};

// 工作线程类
@interface WorkerThread : NSObject <NSMachPortDelegate>

@property (nonatomic, strong) NSMachPort *localPort;
@property (nonatomic, strong) NSMachPort *remotePort; // 使用 strong 替代 weak

- (instancetype)initWithRemotePort:(NSMachPort *)remotePort;
- (void)sendMessage:(ThreadMessageID)msgid data:(NSData *)data;
- (void)sendCheckin;

@end

NS_ASSUME_NONNULL_END
