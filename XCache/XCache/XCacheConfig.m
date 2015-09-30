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

+ (NSInteger)maxCacheOnMemoryTime {
    return 86400;//一天
}

+ (NSInteger)maxCacheOnDiskTime {
    return 7 * 86400;//一周
}

+ (NSInteger)maxCacheOnMemorySize {
    return 50 * 1024 *1024;//50M
}

+ (NSInteger)maxCacheOnDiskSize {
    return 200 * 1024 *1024;//200M
}

+ (NSInteger)defaultMaxQueueSize {
    return 10;
}

+ (NSInteger)defaultMaxPoolSize {
    return 20;
}

+ (NSString *)cacheFolderPath {
    return [self rootPath];//换成自定义的path
}

+ (NSString *)rootPath {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    cachePath = [cachePath stringByAppendingPathComponent:XCacheFolderName];
    return cachePath;
}

+ (NSInteger)computeLifeTimeoutWithDuration:(NSInteger)duration {//当前时间+持续时间=过期时间
    duration = (duration > 0) ? duration : [self maxCacheOnMemoryTime];
    return [self nowTimestamp] + duration;
}

+ (NSInteger)nowTimestamp {
    return (NSInteger)ceil([[NSDate date] timeIntervalSince1970]); 
}

@end
