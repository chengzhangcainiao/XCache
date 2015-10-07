//
//  XCacheStrategyFactory.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStrategyFactory.h"
#import "XCacheFastTable.h"
#import "XCacheConfig.h"
#import "NSMutableArray+Queue.h"

@implementation XCacheStrategyFactory

+ (id<XCacheExchangeStrategyProtocol>)FIFOExchangeWithTable:(XCacheFastTable *)table {
    static XCacheExchangeFIFOStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheExchangeFIFOStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheExchangeStrategyProtocol>)LFUExchangeWithTable:(XCacheFastTable *)table {
    static XCacheExchangeLFUStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheExchangeLFUStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheExchangeStrategyProtocol>)LRUExchangeWithTable:(XCacheFastTable *)table {
    static XCacheExchangeLRUStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheExchangeLRUStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

@end

@implementation XCacheExchangeStrategyBase

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {}

@end


@interface XCacheExchangeFIFOStrategy ()

@property (nonatomic, strong) NSMutableArray *keyQueue;

@end

@implementation XCacheExchangeFIFOStrategy

- (NSMutableArray *)keyQueue {
    if (!_keyQueue) {
        _keyQueue = [[NSMutableArray alloc] init];
    }
    return _keyQueue;
}

- (void)dealloc {
    self.table = nil;
    _keyQueue = nil;
}

- (XCacheObject *)searchWithKey:(NSString *)key {
    return nil;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end

@implementation XCacheExchangeLFUStrategy

- (XCacheObject *)searchWithKey:(NSString *)key {
    return nil;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end

@implementation XCacheExchangeLRUStrategy

- (XCacheObject *)searchWithKey:(NSString *)key {
    return nil;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end

#pragma mark - 

@implementation XcacheSearchStrategyBase

- (XCacheObject *)searchWithKey:(NSString *)key {return nil;}

@end

@implementation XcacheNoneSearchStrategy

- (XCacheObject *)searchWithKey:(NSString *)key {
    //具体实现
    return nil;
}

@end

@implementation XcacheMulLevelCacheSearchStrategy

- (XCacheObject *)searchWithKey:(NSString *)key {
    //具体实现
    return nil;
}

@end