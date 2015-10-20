//
//  XCacheStrategyProtocol.h
//  XCache
//
//  Created by XiongZenghui on 15/10/12.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCacheObject;

/**
 *  缓存项的保存、读取、淘汰抽象接口
 */
@protocol XCacheStrategyProtocol <NSObject>

/**
 *  缓存一个新的并淘汰一个旧的
 */
- (void)x_cacheObject:(XCacheObject *)object WithKey:(NSString *)key;

/**
 *  使用key查询到一个对象的功能接口
 */
- (XCacheObject *)x_searchWithKey:(NSString *)key;

/**
 * 清理内存在的缓存对象
 */
- (void)x_cleaningCacheObjects;

@end
