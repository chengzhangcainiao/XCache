//
//  XCache.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheQueue.h"
#import "XCachePool.h"
#import "XCacheObject.h"
#import "XCacheStore.h"

@interface XCache : NSObject

@property (nonatomic, strong, readonly) XCacheQueue *defaultQueue;
@property (nonatomic, strong, readonly) XCachePool *defaultPool;
@property (nonatomic, strong, readonly) XCacheStore *store;

@property (nonatomic, copy)void (^onRemoveFromMemory)(id object);

+ (instancetype)x_sharedInstance;

#pragma mark - normal 【如果是自定义类对象，必须实现NSCoding协议】
- (void)x_saveObject:(id)object ForKey:(NSString *)key Timeout:(NSInteger)time;
- (id)x_getObjectWithKey:(NSString *)key;
- (void)x_removeObjectWithKey:(NSString *)key;

#pragma mark - queue
- (XCacheQueue *)x_addQueueWithIdentifier:(NSString *)identify
                           MaxMemoryCount:(NSInteger)count
                      IsAutoArchiveToDisk:(BOOL)isAutoArchive;

- (XCacheQueue *)x_findQueueByIdentifier:(NSString *)identify;
- (void)x_pushObjct:(id)object ToQueueWithIdentifier:(NSString *)identifier;
- (id)x_popObjectFromQueueWithIdentifier:(NSString *)identifier;

#pragma mark - pool
- (XCachePool *)x_addPoolWithIdentifier:(NSString *)identify
                       MaxMemoryCount:(NSInteger)count;

- (XCachePool *)x_findPoolByIdentifier:(NSString *)identify;
- (id)x_getObjectFromPoolWithIdentifier:(NSString *)identify;

- (void)x_removeObjectWithKey:(NSString *)key;
- (void)x_removeAllObjects;

@end
