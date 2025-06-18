//
//  RunLoopDemo2.h
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/6/18.
//

#import <Foundation/Foundation.h>
#import "CustomRunLoopSource.h"

/**
 自定义输入源
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW3
 */

@interface RunLoopDemo2 : NSObject

@property (nonatomic, strong) CustomRunLoopSource *customSource;
@property (nonatomic, strong) NSThread *workerThread;
@property (nonatomic, assign) BOOL isRunning;

- (instancetype)init;
- (void)start;
- (void)stop;
- (void)sendCommand:(NSInteger)command withData:(id)data;

@end
