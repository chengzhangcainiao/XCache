//
//  XCacheSearchStrategyProtocol.h
//  XCache
//
//  Created by xiongzenghui on 15/10/7.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCacheObject;

@protocol XCacheSearchStrategyProtocol <NSObject>

/**
 *  抽象出使用key查询到一个对象的功能接口，子类实现不同的查询算法
 */
- (XCacheObject *)searchWithKey:(NSString *)key;

@end
