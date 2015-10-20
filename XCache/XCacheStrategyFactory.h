//
//  XCacheStrategyFactory.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheStrategyProtocol.h"

@class XCacheStore;
@class XCacheFastTable;

@interface XCacheStrategyFactory : NSObject

+ (id<XCacheStrategyProtocol>)FIFOExchangeWithTable:(XCacheFastTable *)table;
+ (id<XCacheStrategyProtocol>)LFUExchangeWithTable:(XCacheFastTable *)table;
+ (id<XCacheStrategyProtocol>)LRUExchangeWithTable:(XCacheFastTable *)table;
+ (id<XCacheStrategyProtocol>)LRU_kExchangeWithTable:(XCacheFastTable *)table KCount:(NSInteger)k;

@end


@interface XCacheStrategyBase : NSObject <XCacheStrategyProtocol>

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, weak) XCacheFastTable *table;
@property (nonatomic, weak) XCacheStore *store;

- (BOOL)x_isConstainKeyInObjectMap:(NSString *)key;

@end

@interface XCacheStrategyFIFOStrategy : XCacheStrategyBase

@end

@interface XCacheStrategyLFUStrategy : XCacheStrategyBase

@end

@interface XCacheStrategyLRUStrategy : XCacheStrategyBase

@end

@interface XCacheStrategyLRU_KStrategy : XCacheStrategyLRUStrategy

- (instancetype)initWithK:(NSInteger)k;

@end