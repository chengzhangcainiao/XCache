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


@property (nonatomic, strong) id<XCacheStrategyProtocol> strategyIns;

@end

@implementation XCacheFastTable

- (void)x_setupStrategy:(XCacheStrategyType)type {
    _cacheStrategyType = type;
    
    switch (_cacheStrategyType) {
            
        case XCacheStrategyTypeFIFO: {
            _strategyIns = [XCacheStrategyFactory FIFOExchangeWithTable:self];
            break;
        }

        case XCacheStrategyTypeLFU: {
            _strategyIns = [XCacheStrategyFactory LFUExchangeWithTable:self];
            break;
        }

        case XCacheStrategyTypeLRU: {
            _strategyIns = [XCacheStrategyFactory LRUExchangeWithTable:self];
            break;
        }
            
        case XCacheStrategyTypeLRU_K: {
            _strategyIns = [XCacheStrategyFactory LRU_kExchangeWithTable:self KCount:[self kCount]];
        }
            break;

        default: {
            _strategyIns = [XCacheStrategyFactory FIFOExchangeWithTable:self];
            break;
        }
    }
}

- (instancetype)initWithCacheStrategyType:(XCacheStrategyType)type CacheStore:(XCacheStore *)store
{
    self = [super init];
    if (self) {
        [self x_setupStrategy:type];
        _store = store;
    }
    return self;
}

#pragma mark - 

- (XCacheObject *)x_getCacheObjectWithKey:(NSString *)key {
    return [self.strategyIns x_searchWithKey:key];
}

- (void)x_setCacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    [self.strategyIns x_cacheObject:object WithKey:key];
}

- (void)x_cleaningCacheObjectsInMomery:(BOOL)flag {
    [self.strategyIns x_cleaningCacheObjects:flag];
}

#pragma mark - 

- (void)x_registCustomer:(id<XCacheStrategyProtocol>)exchange {
    
}

- (NSInteger)kCount {
    return 3;
}

@end
