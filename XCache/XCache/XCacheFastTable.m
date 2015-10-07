//
//  XCacheFastTable.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheFastTable.h"
#import "XCacheObject.h"

@interface XCacheFastTable ()

@property (nonatomic, strong) id<XCacheExchangeStrategyProtocol> exchangeStrategyIns;
@property (nonatomic, strong) id<XCacheSearchStrategyProtocol> searchStrategyIns;

@end

@implementation XCacheFastTable

- (void)setupExchangeStrategy {
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

- (void)setupSearchStrategy {
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

#pragma mark - 

- (XCacheObject *)getCacheObjectWithKey:(NSString *)key {
    return [self.searchStrategyIns searchWithKey:key];
}

- (void)setCacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    [self.exchangeStrategyIns cacheObject:object WithKey:key];
}

@end
