//
//  XCacheStore.h
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheFastTable.h"

//@interface XCacheStore : NSCache <NSFastEnumeration>
@interface XCacheStore : NSObject <NSFastEnumeration>

/**
 *  内存当前保存的XCacheObject实例长度
 */
@property (nonatomic, readonly) NSInteger memorySize;

/**
 *  当前内存花销的总大小
 */
@property (nonatomic, readonly) NSInteger memoryTotalCost;

/**
 *  当前磁盘花销的总大小
 */
@property (nonatomic, readonly) NSInteger diskTotalCost;

/**
 *  对应进行算法逻辑的类
 */
@property (nonatomic, strong, readonly) XCacheFastTable *fastTable;

/**
 *  保存所有缓存的key
 */
@property (nonatomic, strong) NSMutableArray *keyList;

/**
 *  保存所有缓存的key-value
 */
@property (nonatomic, strong) NSMutableDictionary *objectMap;

/**
 *  获取单例
 */
+ (instancetype)x_sharedInstance;

/**
 *  更换其他类型的XCacheFastTable
 */
- (void)x_changeToFastTable:(XCacheFastTable *)aTable;

/**
 *  使用key保存一个原始对象，并传入超时时间
 */
- (void)saveObject:(id)object forKey:(NSString *)key expiredAfter:(NSInteger)duration;

/**
 *  使用一个key，查找到一个XCacheObject实例，继而找到原始对象
 */
- (XCacheObject *)loadObjectWithKey:(NSString *)key;

/**
 *  使用key移除内存缓存项
 */
- (void)x_removeCacheObjectWithKey:(NSString *)key;

/**
 *  强制删除当前内存缓存的所有对象
 */
- (void)x_removeAllCachedObjects;

/**
 *  清理内存对象，直到当前缓存内存小于默认大小，对象归档到磁盘文件
 */
- (void)x_cleaningCachedObjects;

/**
 *  判断是否可以将XCacheObject实例载入到内存
 */
- (BOOL)x_isCanLoadCacheObjectToMemory;

/**
 *  删除单个内存缓存对象
 */
- (void)x_removeMemoryCacheObject:(XCacheObject *)cacheObj WithKey:(NSString *)key;

/**
 *  将NSData使用key作为文件名，写入磁盘文件
 */
- (void)x_dataWriteToRootFolderWithKey:(NSString *)key Data:(NSData *)data;

/**
 *  删除某一个key文件
 */
- (void)x_removeDiskCacheFileWithKey:(NSString *)key;

/**
 *  删除本地所有缓存文件
 */
- (void)x_removeAllDiskCacheFiles;

/**
 *  遍历所有key和value
 */
- (void)x_enumerateKeysAndObjetcsUsingBlock:(void (^)(id key, id object, BOOL *isStop))block;

@end
