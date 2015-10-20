//
//  XCacheConfig.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheConfig.h"

static NSString *XCacheFolderName = @"XCacheObjects";

@implementation XCacheConfig

+ (NSString *)x_rootFolderName {
    return XCacheFolderName;
}

+ (NSInteger)x_maxCacheOnMemoryTime {
    return 86400;//一天
}

+ (NSInteger)x_maxCacheOnDiskTime {
    return 7 * 86400;//一周
}

+ (NSInteger)x_defaultMaxQueueSize {
//    return 20;
    return 5;
}

+ (NSInteger)x_defaultMaxPoolSize {
    return 20;
}

+ (NSInteger)x_maxCacheOnMemorySize {
//    return 100;
    return 5;
}

+ (NSInteger)x_maxCacheOnMemoryCost {
//    return 50 * 1024 *1024;//50M
    return 5 * 1024;
}

+ (NSInteger)x_maxCacheOnDiskCost {
    return 200 * 1024 *1024;//200M
}

+ (NSInteger)x_cycleArchiveTime {
//    return 10;
    return 5;
}

+ (BOOL)x_isArchiverWhenLose {
    return YES;
}

#pragma mark -

+ (NSInteger)x_computeLifeTimeoutWithDuration:(NSInteger)duration {
    // 过期时间 = 当前时间 + 持续时间
    duration = (duration > 0) ? duration : [self x_maxCacheOnMemoryTime];
    return [self x_nowTimestamp] + duration;
}

+ (NSInteger)x_nowTimestamp {
    return (NSInteger)ceil([[NSDate date] timeIntervalSince1970]); 
}

- (NSString *)x_encodedString:(NSString *)string
{
    if (![string length])
        return @"";
    
    CFStringRef static const charsToEscape = CFSTR(".:/");
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)string,
                                                                        NULL,
                                                                        charsToEscape,
                                                                        kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)escapedString;
}

- (NSString *)x_decodedString:(NSString *)string
{
    if (![string length])
        return @"";
    
    CFStringRef unescapedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef)string,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)unescapedString;
}

@end
