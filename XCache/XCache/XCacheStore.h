//
//  XCacheStore.h
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheFastTable.h"

/*
参考MKNetworkKit队列缓存、ASimpleCache缓存

1. 从缓存中，命中到这个对象，将这个命中对象作为最后被访问过的.

2. 从缓存中，没有命中这个对象.
2.1 如果内存缓存空间没满，直接放入缓存
2.2 如果内存缓存空间满了，就要使用某一种替换算法，来保存这个新对象

3. 使用’索引表‘加快命中效率.

4. 替换策略.
4.1 LFU，我会计算为每个缓存对象计算他们被使用的频率。我会把最不常用的缓存对象踢走。
4.2 LRU，类似队列结构，最后访问的放入队尾，每次清除队头对象。
.....等等其他算法

5. 定期查看内存缓存，超过规定大小时，按照算法，将部分对象归档到磁盘文件.
*/

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
+ (instancetype)sharedInstance;

/**
 *  更换其他类型的XCacheFastTable
 */
- (void)changeToFastTable:(XCacheFastTable *)aTable;

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
- (void)removeCacheObjectWithKey:(NSString *)key;

/**
 *  强制删除当前内存缓存的所有对象
 */
- (void)removeAllCachedObjects;

/**
 *  清理内存对象，直到当前缓存内存小于默认大小，对象归档到磁盘文件
 */
- (void)cleaningCachedObjects;

/**
 *  判断是否可以将XCacheObject实例载入到内存，判断内存大小是否超过规定大小
 */
- (BOOL)isCanLoadCacheObjectToMemory;

/**
 *  删除单个内存缓存对象
 */
- (void)removeMemoryCacheObject:(XCacheObject *)cacheObj WithKey:(NSString *)key;

/**
 *  将NSData使用key作为文件名，写入磁盘文件
 */
- (void)dataWriteToRootFolderWithKey:(NSString *)key Data:(NSData *)data;

/**
 *  删除某一个key文件
 */
- (void)removeDiskCacheFileWithKey:(NSString *)key;

/**
 *  删除本地所有缓存文件
 */
- (void)removeAllDiskCacheFiles;

/**
 *  遍历所有key和value
 */
- (void)enumerateKeysAndObjetcsUsingBlock:(void (^)(id key, id object, BOOL *isStop))block;

@end
