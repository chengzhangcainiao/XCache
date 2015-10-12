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
 *  Cache缓存算法
 */
typedef NS_ENUM(NSInteger, XCacheStrategyType){
    
    /**
     *  先进先出类似队列
     */
    XCacheStrategyTypeFIFO            = 0x01,
    
    /**
     *  替换掉访问总次数最少的
     */
    XCacheStrategyTypeLFU,
    
    /**
     *  在某一个时间段内，替换换掉访问次数最少的
     */
    XCacheStrategyTypeLRU,
    
    /**
     *  用户自定义
     */
    XCacheStrategyTypeCustomer,
};

@interface XCacheFastTable : NSObject

@property (nonatomic, weak, readwrite) XCacheStore *store;

@property (nonatomic, assign, readonly) XCacheStrategyType cacheStrategyType;

/**
 *  使用自定义缓存算法
 */
- (void)registCustomer:(id<XCacheStrategyProtocol>)exchange;

/**
 *  传入 查询策略 和 替换策略
 */
- (instancetype)initWithCacheStrategyType:(XCacheStrategyType)type
                               CacheStore:(XCacheStore *)store;


- (XCacheObject *)getCacheObjectWithKey:(NSString *)key;
- (void)setCacheObject:(XCacheObject *)object WithKey:(NSString *)key;
- (void)cleaningCacheObjectsInMomery:(BOOL)flag;

@end
