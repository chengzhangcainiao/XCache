//
//  XCacheConfig.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheConfig : NSObject

+ (NSInteger)maxCacheOnMemoryTime;
+ (NSInteger)maxCacheOnDiskTime;

+ (NSInteger)defaultMaxQueueSize;
+ (NSInteger)defaultMaxPoolSize;

+ (NSInteger)maxCacheOnMemorySize;
+ (NSInteger)maxCacheOnDiskSize;
+ (NSString *)cacheFolderPath;
+ (NSString *)rootPath;

+ (NSInteger)nowTimestamp;
+ (NSInteger)computeLifeTimeoutWithDuration:(NSInteger)duration;

@end
