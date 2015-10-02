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

@interface XCache : NSObject

@property (nonatomic, strong, readonly) XCacheQueue *defaultQueue;
@property (nonatomic, strong, readonly) XCachePool *defaultPool;

@property (nonatomic, copy)void (^onRemoveFromMemory)(id object);

+ (instancetype)sharedInstance;

#pragma mark - normal
- (void)saveObject:(id)object ForKey:(NSString *)key;
- (void)saveObject:(id)object ForKey:(NSString *)key Timeout:(NSInteger)time;

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
