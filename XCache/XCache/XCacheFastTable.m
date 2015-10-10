//
//  XCacheFastTable.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheFastTable.h"
#import "XCacheObject.h"
#import "XCacheStore.h"

@interface XCacheFastTable ()

@property (nonatomic, strong) id<XCacheExchangeStrategyProtocol> exchangeStrategyIns;
@property (nonatomic, strong) id<XCacheSearchStrategyProtocol> searchStrategyIns;

@end

@implementation XCacheFastTable

- (void)setupExchangeStrategy:(XCacheExchangeStrategy)strategy {
    _exchangeStrategyType = strategy;
    
    switch (_exchangeStrategyType) {
        case XCacheExchangeStrategyFIFO: {
            _exchangeStrategyIns = [XCacheStrategyFactory FIFOExchangeWithTable:self];
            break;
        }

        case XCacheExchangeStrategyLFU: {
            _exchangeStrategyIns = [XCacheStrategyFactory LFUExchangeWithTable:self];
            break;
        }

        case XCacheExchangeStrategyLRU: {
            _exchangeStrategyIns = [XCacheStrategyFactory LRUExchangeWithTable:self];
            break;
        }

        default: {
            _exchangeStrategyIns = [XCacheStrategyFactory FIFOExchangeWithTable:self];
            break;
        }
    }
}

- (void)setupSearchStrategy:(XCacheSearchStrategy)strategy {
    _searchStrategyType = strategy;
    
    switch (_searchStrategyType) {
        case XCacheSearchStrategyNone: {
            _searchStrategyIns = [XCacheStrategyFactory normalSearchWithTable:self];
            break;
        }
        case XCacheSearchStrategyMulLevelCache: {
            _searchStrategyIns = [XCacheStrategyFactory mulLevelSearchWithTable:self];
            break;
        }
        default: {
            _searchStrategyIns = [XCacheStrategyFactory normalSearchWithTable:self];
            break;
        }
    }
}

- (instancetype)initWithCacheExcangeStrategy:(XCacheExchangeStrategy)exchangeStrategy
                         CacheSearchStrategy:(XCacheSearchStrategy)searchStrategy
                                  CacheStore:(XCacheStore *)store
{
    self = [super init];
    if (self) {
        [self setupSearchStrategy:searchStrategy];
        [self setupExchangeStrategy:exchangeStrategy];
        _store = store;
    }
    return self;
}

#pragma mark - 

- (XCacheObject *)getCacheObjectWithKey:(NSString *)key {
    return [self.searchStrategyIns searchWithKey:key];
}

- (void)setCacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    [self.exchangeStrategyIns cacheObject:object WithKey:key];
}

- (void)cleaningCacheObjectsInMomery:(BOOL)flag {
    [self.exchangeStrategyIns cleaningCacheObjects:flag];
}

@end
