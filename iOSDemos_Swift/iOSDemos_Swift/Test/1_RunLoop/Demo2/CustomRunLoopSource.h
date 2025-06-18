//
//  CustomRunLoopSource.h
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/18.
//

#import <Foundation/Foundation.h>

// 定义命令处理回调
typedef void(^CommandHandler)(NSInteger command, id data);

@interface CustomRunLoopSource : NSObject

@property (nonatomic, copy) CommandHandler commandHandler;

- (instancetype)init;
- (void)addToRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode;
- (void)invalidate;
- (void)addCommand:(NSInteger)command withData:(id)data;
- (void)signalSource;

@end
