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

@implementation XCacheStrategyFactory

+ (XCacheFIFOPloicy *)FIFOWithTable:(XCacheFastTable *)table {
    static XCacheFIFOPloicy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheFIFOPloicy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (XCacheLRUPloicy *)LRUWithTable:(XCacheFastTable *)table {
    static XCacheLRUPloicy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheLRUPloicy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (XCacheLFUPloicy *)LFUWithTable:(XCacheFastTable *)table {
    static XCacheLFUPloicy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheLFUPloicy alloc] init];
        policy.table = table;
    });
    return policy;
}

@end

@implementation XCachePolicyBase

- (NSMutableArray *)keyArray {
    if (!_keyArray) {
        _keyArray = [[NSMutableArray alloc] init];
    }
    return _keyArray;
}

- (NSMutableDictionary *)cacheObjectDictionary {
    if (!_cacheObjectDictionary) {
        _cacheObjectDictionary = [[NSMutableDictionary alloc] init];
    }
    return _cacheObjectDictionary;
}

- (XCacheObject *)searchWithKey:(NSString *)key {return nil;}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {}

@end

@implementation XCacheFIFOPloicy

- (void)dealloc {
    self.table = nil;
}

- (XCacheObject *)searchWithKey:(NSString *)key {
    return nil;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end

@implementation XCacheLRUPloicy

- (XCacheObject *)searchWithKey:(NSString *)key {
    return nil;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end

@implementation XCacheLFUPloicy

- (XCacheObject *)searchWithKey:(NSString *)key {
    return nil;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end