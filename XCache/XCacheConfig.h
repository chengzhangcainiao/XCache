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
+ (NSString *)x_rootFolderName;

/**
 *  一个对象在内存中最大缓存的时间
 */
+ (NSTimeInterval)x_maxCacheOnMemoryTime;

/**
 *  缓存文件在磁盘上最大缓存的时间
 */
+ (NSTimeInterval)x_maxCacheOnDiskTime;

/**
 *  轮询内存的时间间隔
 */
+ (NSTimeInterval)x_cycleArchiveTime;

/**
 *  是否将淘汰的对象写入磁盘文件
 */
+ (BOOL)x_isArchiverWhenLose;

/**
 *  内存队列最大缓存对象的长度
 */
+ (NSInteger)x_maxMemoryQueueSize;

/**
 *  使用LRU-K替换策略时，history queue的最大长度
 */
+ (NSInteger)x_maxHistoryQueueSize;

/**
 *  内存池最大缓存对象的长度
 */
+ (NSInteger)x_defaultMaxPoolSize;

/**
 *  内存缓存对象的最大长度（个数）
 */
+ (NSInteger)x_maxCacheOnMemorySize;

/**
 *  内存缓存对象的最大空间
 */
+ (NSInteger)x_maxCacheOnMemoryCost;

/**
 *  磁盘缓存最大的空间
 */
+ (NSInteger)x_maxCacheOnDiskCost;


+ (NSInteger)x_nowTimestamp;
+ (NSInteger)x_computeLifeTimeoutWithDuration:(NSInteger)duration;

- (NSString *)x_encodedString:(NSString *)string;
- (NSString *)x_decodedString:(NSString *)string;

@end
