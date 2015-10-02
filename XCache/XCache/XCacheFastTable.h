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

/**
 *  Cache替换算法
 */
typedef NS_ENUM(NSInteger, XCachePolicy){
    /**
     *  替换掉访问总次数最少的
     */
    XCachePolicyLFU             = 0x1,
    
    /**
     *  在某一个时间段内，替换换掉访问次数最少的
     */
     XCachePolicyLRU,
    
    /**
     *  先进先出类似队列
     */
     XCachePolicyFIFO,
};

@interface XCacheFastTable : NSObject

@property (nonatomic, assign, readonly) XCachePolicy cachePolicy;

- (instancetype)initWithCachePolicy:(XCachePolicy)policy;

- (XCacheObject *)getCacheObjectWithKey:(NSString *)key;

- (void)setCacheObject:(XCacheObject *)object WithKey:(NSString *)key;

@end
