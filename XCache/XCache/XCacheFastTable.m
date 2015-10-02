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

@property (nonatomic, strong) id<XCacheStrategyProtocol> cacheStrategy;

@end

@implementation XCacheFastTable

- (void)setupStrategy {
    switch (_cachePolicy) {
        case XCachePolicyLFU: {
            _cacheStrategy = [XCacheStrategyFactory LFUWithTable:self];
            break;
        }
        case XCachePolicyLRU: {
            _cacheStrategy = [XCacheStrategyFactory LRUWithTable:self];
            break;
        }
        case XCachePolicyFIFO: {
            _cacheStrategy = [XCacheStrategyFactory FIFOWithTable:self];
            break;
        }
        default: {
            _cacheStrategy = [XCacheStrategyFactory FIFOWithTable:self];
            break;
        }
    }
}

#pragma mark - 

- (XCacheObject *)getCacheObjectWithKey:(NSString *)key {
    return [self.cacheStrategy searchWithKey:key];
}

- (void)setCacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    [self.cacheStrategy cacheObject:object WithKey:key];
}

@end
