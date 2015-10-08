//
//  XCacheObject.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheObject : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) NSMutableDictionary *options;

/**
 *	从读取缓存原始对象
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *	将原始对象保存到缓存
 */
- (instancetype)initWithObject:(id)aObject Duration:(NSInteger)duration;

- (NSData *)cacheData;
- (NSInteger)cacheSize;

/**
 *	获取XCacheObject实例中options字典保存的原始对象
 */
- (id)targetObjectInOptions;

/**
 *	获取XCacheObject实例中options字典保存的缓存超时时间
 */
- (NSInteger)expirateTimestampInOptions;

/**
 *	更新缓存超时时间
 */
- (void)updateCacheObjectLifeDuration:(NSInteger)duration;

/**
 *	是否已经超时
 */
- (BOOL)isExpirate;

@end
