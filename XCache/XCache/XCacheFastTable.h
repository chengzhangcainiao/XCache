//
//  XCacheFastTable.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheStrategyFactory.h"

@class XCacheObject;
@class XCacheStore;

/**
 *  Cache查找算法
 */
typedef NS_ENUM(NSInteger, XCacheSearchStrategy){
    
    /**
     *  直接取字典按照key一个一个对比查找
     */
    XCacheSearchStrategyNone            = 0x01,
    
    /**
     *  使用二级临时内存缓存，提高命中
     */
    XCacheSearchStrategyMulLevelCache,
    
    /**
     *  用户自定义
     */
    XCacheSearchStrategyCustomer,
};

/**
 *  Cache替换算法
 */
typedef NS_ENUM(NSInteger, XCacheExchangeStrategy){
    
    /**
     *  先进先出类似队列
     */
    XCacheExchangeStrategyFIFO            = 0x01,
    
    /**
     *  替换掉访问总次数最少的
     */
    XCacheExchangeStrategyLFU,
    
    /**
     *  在某一个时间段内，替换换掉访问次数最少的
     */
    XCacheExchangeStrategyLRU,
    
    /**
     *  用户自定义
     */
    XCacheExchangeStrategyCustomer,
};

@interface XCacheFastTable : NSObject

@property (nonatomic, weak, readwrite) XCacheStore *store;

@property (nonatomic, assign, readonly) XCacheExchangeStrategy exchangeStrategyType;
@property (nonatomic, assign, readonly) XCacheSearchStrategy searchStrategyType;

/**
 *  使用自定义替换算法
 */
- (void)registCustomerExchange:(id<XCacheExchangeStrategyProtocol>)exchange;

/**
 *  使用自定义查询算法
 */
- (void)registCustomerSearch:(id<XCacheSearchStrategyProtocol>)search;

/**
 *  传入 查询策略 和 替换策略
 */
- (instancetype)initWithCacheExcangeStrategy:(XCacheExchangeStrategy)exchangeStrategy
                         CacheSearchStrategy:(XCacheSearchStrategy)searchStrategy
                                  CacheStore:(XCacheStore *)store;

- (XCacheObject *)getCacheObjectWithKey:(NSString *)key;
- (void)setCacheObject:(XCacheObject *)object WithKey:(NSString *)key;

@end
