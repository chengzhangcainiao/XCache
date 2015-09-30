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

- (void)saveObject:(id)object ForKey:(NSString *)key;
- (void)saveObject:(id)object ForKey:(NSString *)key Timeout:(NSInteger)time;

- (XCacheQueue *)addQueueWithIdentifier:(NSString *)identify
                         MaxMemoryCount:(NSInteger)count
                    IsAutoArchiveToDisk:(BOOL)isAutoArchive;

- (XCacheQueue *)findQueueByIdentifier:(NSString *)identify;

- (XCachePool *)addPoolWithIdentifier:(NSString *)identify
                       MaxMemoryCount:(NSInteger)count;

- (XCachePool *)findPoolByIdentifier:(NSString *)identify;


- (XCacheObject *)findObjectWithKey:(NSString *)key;

- (void)removeObjectWithKey:(NSString *)key;
- (void)removeAllObjects;

@end
