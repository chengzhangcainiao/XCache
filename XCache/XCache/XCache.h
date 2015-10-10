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

+ (instancetype)sharedInstance;

#pragma mark - normal 【如果是自定义类对象，必须实现NSCoding协议】
- (void)saveObject:(id)object ForKey:(NSString *)key Timeout:(NSInteger)time;
- (id)getObjectWithKey:(NSString *)key;
- (void)removeObjectWithKey:(NSString *)key;

#pragma mark - queue
- (XCacheQueue *)addQueueWithIdentifier:(NSString *)identify
                         MaxMemoryCount:(NSInteger)count
                    IsAutoArchiveToDisk:(BOOL)isAutoArchive;

- (XCacheQueue *)findQueueByIdentifier:(NSString *)identify;
- (void)pushObjct:(id)object ToQueueWithIdentifier:(NSString *)identifier;
- (id)popObjectFromQueueWithIdentifier:(NSString *)identifier;

#pragma mark - pool
- (XCachePool *)addPoolWithIdentifier:(NSString *)identify
                       MaxMemoryCount:(NSInteger)count;

- (XCachePool *)findPoolByIdentifier:(NSString *)identify;
- (id)getObjectFromPoolWithIdentifier:(NSString *)identify;

- (void)removeObjectWithKey:(NSString *)key;
- (void)removeAllObjects;

@end
