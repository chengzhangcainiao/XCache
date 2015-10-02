//
//  XCacheConfig.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheConfig : NSObject

/**
 *  地盘缓存目录名
 */
+ (NSString *)rootFolderName;

/**
 *  一个对象在内存中最大缓存的时间
 */
+ (NSInteger)maxCacheOnMemoryTime;

/**
 *  缓存文件在磁盘上最大缓存的时间
 */
+ (NSInteger)maxCacheOnDiskTime;

/**
 *  内存队列最大缓存对象的长度
 */
+ (NSInteger)defaultMaxQueueSize;

/**
 *  内存池最大缓存对象的长度
 */
+ (NSInteger)defaultMaxPoolSize;

/**
 *  内存缓存对象的最大长度（个数）
 */
+ (NSInteger)maxCacheOnMemorySize;

/**
 *  内存缓存对象的最大空间
 */
+ (NSInteger)maxCacheOnMemoryCost;

/**
 *  磁盘缓存最大的空间
 */
+ (NSInteger)maxCacheOnDiskCost;

/**
 *  轮询内存的时间间隔
 */
+ (NSInteger)cycleArchiveTime;


+ (NSInteger)nowTimestamp;
+ (NSInteger)computeLifeTimeoutWithDuration:(NSInteger)duration;

- (NSString *)encodedString:(NSString *)string;
- (NSString *)decodedString:(NSString *)string;

@end
