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

+ (NSString *)rootFolderName {
    return XCacheFolderName;
}

+ (NSInteger)maxCacheOnMemoryTime {
    return 86400;//一天
}

+ (NSInteger)maxCacheOnDiskTime {
    return 7 * 86400;//一周
}

+ (NSInteger)defaultMaxQueueSize {
//    return 20;
    return 5;
}

+ (NSInteger)defaultMaxPoolSize {
    return 20;
}

+ (NSInteger)maxCacheOnMemorySize {
//    return 100;
    return 5;
}

+ (NSInteger)maxCacheOnMemoryCost {
//    return 50 * 1024 *1024;//50M
    return 5 * 1024;
}

+ (NSInteger)maxCacheOnDiskCost {
    return 200 * 1024 *1024;//200M
}

+ (NSInteger)cycleArchiveTime {
//    return 10;
    return 5;
}

#pragma mark -

+ (NSInteger)computeLifeTimeoutWithDuration:(NSInteger)duration {
    // 过期时间 = 当前时间 + 持续时间
    duration = (duration > 0) ? duration : [self maxCacheOnMemoryTime];
    return [self nowTimestamp] + duration;
}

+ (NSInteger)nowTimestamp {
    return (NSInteger)ceil([[NSDate date] timeIntervalSince1970]); 
}

- (NSString *)encodedString:(NSString *)string
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

- (NSString *)decodedString:(NSString *)string
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
