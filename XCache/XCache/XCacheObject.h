//
//  XCacheObject.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheObject : NSObject

/**
 *  options字典Archiver后的NSData
 */
@property (nonatomic, strong, readonly) NSData *data;

/**
 *  包含原始对象和超时时间的字典
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *options;

/**
 *  记录当前CacheObject对象被访问的次序
 */
@property (nonatomic, assign) NSInteger visitOrder;

/**
 *  记录被访问的次数
 */
@property (nonatomic, assign) NSInteger visitCount;

/**
 *	读取缓存
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *	写入缓存
 */
- (instancetype)initWithObject:(id)aObject Duration:(NSInteger)duration;

/**
 *  获取options字典转换成的NSData
 */
- (NSData *)x_cacheData;

/**
 *  获取NSData长度
 */
- (NSInteger)x_cacheSize;

/**
 *	获取XCacheObject实例中options字典保存的原始对象
 */
- (id)x_targetObjectInOptions;

/**
 *	获取XCacheObject实例中options字典保存的缓存超时时间
 */
- (NSInteger)x_expirateTimestampInOptions;

/**
 *	更新缓存超时时间
 */
- (void)x_updateCacheObjectLifeDuration:(NSInteger)duration;

/**
 *  使用新的原始对象和缓存超时，创建新的NSData
 */
- (void)x_generateDataWithObject:(id)aObject Duration:(NSInteger)duration;

/**
 *	是否已经超时
 */
- (BOOL)x_isExpirate;

@end
