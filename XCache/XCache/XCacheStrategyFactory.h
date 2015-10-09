//
//  XCacheStrategyFactory.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheExchangeStrategyProtocol.h"
#import "XCacheSearchStrategyProtocol.h"

@class XCacheStore;
@class XCacheFastTable;

@interface XCacheStrategyFactory : NSObject

+ (id<XCacheExchangeStrategyProtocol>)FIFOExchangeWithTable:(XCacheFastTable *)table;
+ (id<XCacheExchangeStrategyProtocol>)LFUExchangeWithTable:(XCacheFastTable *)table;
+ (id<XCacheExchangeStrategyProtocol>)LRUExchangeWithTable:(XCacheFastTable *)table;

+ (id<XCacheSearchStrategyProtocol>)normalSearchWithTable:(XCacheFastTable *)table;
+ (id<XCacheSearchStrategyProtocol>)mulLevelSearchWithTable:(XCacheFastTable *)table;

@end


@interface XCacheExchangeStrategyBase : NSObject <XCacheExchangeStrategyProtocol>

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, weak) XCacheFastTable *table;
@property (nonatomic, weak) XCacheStore *store;

@end

@interface XCacheExchangeFIFOStrategy : XCacheExchangeStrategyBase

@end

@interface XCacheExchangeLFUStrategy : XCacheExchangeStrategyBase

@end

@interface XCacheExchangeLRUStrategy : XCacheExchangeStrategyBase

@end

@interface XcacheSearchStrategyBase : NSObject <XCacheSearchStrategyProtocol>

@property (nonatomic, weak) XCacheFastTable *table;
@property (nonatomic, weak) XCacheStore *store;

@end

@interface XcacheNoneSearchStrategy : XcacheSearchStrategyBase

@end

@interface XcacheMulLevelCacheSearchStrategy : XcacheSearchStrategyBase

@end
