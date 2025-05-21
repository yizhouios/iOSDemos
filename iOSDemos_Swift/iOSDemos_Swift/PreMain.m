//
//  PreMain.m
//  iOSDemos_Swift
//
//  Created by yizhou on 2025/5/21.
//

#import <Foundation/Foundation.h>

__attribute__((constructor)) static void myConstructor(void) {
    NSLog(@"This runs before main()");
}
