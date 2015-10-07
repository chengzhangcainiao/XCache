//
//  XCacheExchangeStrategyProtocol
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCacheObject;

@protocol XCacheExchangeStrategyProtocol <NSObject>

/**
 *  抽象出使用key缓存一个对象的功能接口，子类实现自己的缓存替换算法
 */
- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key;

@end
