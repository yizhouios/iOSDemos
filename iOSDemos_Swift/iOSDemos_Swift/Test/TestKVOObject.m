//
//  TestKVOObject.m
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/5/21.
//

#import "TestKVOObject.h"
// ---
#import <objc/runtime.h>

@implementation TestKVOObject

+ (void)testKVOClassName {
    // 被观察对象
    TestKVOObject *obj = [[TestKVOObject alloc] init];

    // 添加 KVO 观察
    [obj addObserver:obj forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];

    // 打印当前类名
    Class currentClass = object_getClass(obj);
    NSLog(@"KVO 生成的中间类: %@", NSStringFromClass(currentClass));
    
    [obj removeObserver:obj forKeyPath:@"name"];
}

@end
