//
//  MainThread.h
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainThread : NSObject <NSMachPortDelegate>

@property (nonatomic, strong) NSMachPort *mainPort;
@property (nonatomic, strong) NSMachPort *workerPort;

- (void)launchWorkerThread;
- (void)sendMessageToWorker:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
