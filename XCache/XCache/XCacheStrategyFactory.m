//
//  XCacheStrategyFactory.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStrategyFactory.h"
#import <Availability.h>

#import "NSMutableArray+Queue.h"
#import "NSFileManager+XCache.h"
#import "NSMutableDictionary+XCache.h"
#import "XCacheFastTable.h"
#import "XCacheConfig.h"
#import "XCacheStore.h"
#import "XCacheObject.h"

static NSInteger LRU_K_COUNT = 2;//淘汰最近被访问次数少于2次的缓存项

@implementation XCacheStrategyFactory

+ (id<XCacheStrategyProtocol>)FIFOExchangeWithTable:(XCacheFastTable *)table {
    static XCacheStrategyFIFOStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheStrategyFIFOStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheStrategyProtocol>)LFUExchangeWithTable:(XCacheFastTable *)table {
    static XCacheStrategyLFUStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheStrategyLFUStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheStrategyProtocol>)LRUExchangeWithTable:(XCacheFastTable *)table {
    static XCacheStrategyLRUStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheStrategyLRUStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

@end

#pragma mark -

@implementation XCacheStrategyBase

- (NSRecursiveLock *)lock {
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (XCacheStore *)store {
    return self.table.store;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {}

- (void)cleaningCacheObjects:(BOOL)isArchive {}

- (XCacheObject *)searchWithKey:(NSString *)key{return nil;}

@end


@interface XCacheStrategyFIFOStrategy ()

@property (nonatomic, strong) NSMutableArray *keyQueue;

@end

@implementation XCacheStrategyFIFOStrategy

- (NSMutableArray *)keyQueue {
    if (!_keyQueue) {
        _keyQueue = [[NSMutableArray alloc] init];
    }
    return _keyQueue;
}

- (void)dealloc {
    self.table = nil;
    _keyQueue = nil;
}


@end



@implementation XCacheStrategyLFUStrategy


@end


@interface XCacheStrategyLRUStrategy()

/**
 *  循环记录当前访问缓存对象的总次数（让当前访问缓存的总次数赋值给缓存对象的保存，方便后续排除最少访问次数的缓存对象）
 */
@property (nonatomic, assign)NSInteger currentVisitCount;

@end

@implementation XCacheStrategyLRUStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentVisitCount = 0;
    }
    return self;
}

- (XCacheObject *)searchWithKey:(NSString *)key {
    
    if ([[self.store.objectMap allKeys] containsObject:key]) {
        
        //内存中查找到XCacheObejct实例
        XCacheObject *finded = [self.store.objectMap objectForKey:key];
        
        //是否超时
        if ([finded isExpirate]) {
            return nil;
        }
        
        [self updateCacheObjectVisitOrderAndVisitCount:finded];
        
        //NSData *data = [finded cacheData];
        //return [[XCacheObject alloc] initWithData:data];
        
        return finded;
        
    } else {
        
        //从本地文件查找
        NSString *filePath = [NSFileManager pathForRootDirectoryWithPath:key];
        
        if ([NSFileManager existsItemAtPath:filePath]) {
            
            //本地文件找到options字典的NSData缓存文件（options字典: 1)原始对象  2)超时时间）
            NSData *dataFinded = [[NSData alloc] initWithContentsOfFile:filePath];
            
            //将NSData保存到一个新的的XcacheObeject实例中
            XCacheObject *objectFinded = [[XCacheObject alloc] initWithData:dataFinded];
            
            //是否超时
            if ([objectFinded isExpirate]) {
                return nil;
            }
            
            //判断是否载入到内存
            if ([self.store isCanLoadCacheObjectToMemory]) {
                
                //这句会引起死锁，也没必要，因为此时的XCacheObject实例，是从本地文件恢复的，肯定是带有超时设置的
                /*
                 [self.store saveObject:objectFinded forKey:key expiredAfter:[XCacheConfig maxCacheOnMemoryTime]];
                 */
                
                //载入到内存
                [[self.store objectMap] setObject:objectFinded forKey:key];
                
                [self updateCacheObjectVisitOrderAndVisitCount:objectFinded];
                
                [NSFileManager removeItemAtPath:filePath];
            }
            
            return objectFinded;
            
        } else {
            
            //本地文件未找到
            return nil;
        }
    }
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
    //按照LRU替换算法，清理内存对象
    [self cleaningCacheObjects:YES];
}

- (void)cleaningCacheObjects:(BOOL)isArchive {
    [self.lock lock];
    
    NSMutableArray *keys = [[[self.store objectMap] allKeys] mutableCopy];
    
    NSInteger maxCount = [XCacheConfig maxCacheOnMemorySize];
    
    NSInteger maxCost = [XCacheConfig maxCacheOnMemoryCost];
    
    //将淘汰的对象写入磁盘文件
    isArchive = YES;
    
    //当超过规定长度 或 规定大小
    while (([keys count] > maxCount) || (self.store.memoryTotalCost > maxCost)) {
        
        //保存找到的最久未使用的缓存项的visitOrder
        NSInteger oldestOrder = INT_MAX;
        
        //保存找到的最久未使用的缓存项
        XCacheObject *oldestObject = nil;
        
        //保存找到的最久未使用的缓存项的Key
        id oldestkey = @"";
        
        //查询最小的
        [self findMinOderAndMinCountCacheObjectForKey:&oldestkey Object:&oldestObject Order_p:&oldestOrder];
        
        //找到了久未使用的缓存项
        if (oldestkey) {
            
            //判断是否写入磁盘文件
            if (isArchive) {
                [self.store dataWriteToRootFolderWithKey:oldestkey Data:[oldestObject cacheData]];
            }
            
            //从内存删除
            [self.store removeMemoryCacheObject:oldestObject WithKey:oldestkey];
            
            //遍历数组移除key
            [keys removeObject:oldestkey];
        }
    }
    
    isArchive = NO;
    
    [self.lock unlock];
}

/**
 *  循环处理_currentVisitCount，防止数字过大
 */
- (void)recycleCurrentVisitOrder {
//    if (_currentVisitCount < 0) {
    //遍历objectMap保存的CacheObject实例，按照visitOrder从小到大排序
    NSArray *resultArray = [[self.store.objectMap allValues] sortedArrayUsingComparator:^NSComparisonResult(XCacheObject *obj1, XCacheObject *obj2) {
        return (NSComparisonResult)MIN(1, MAX(-1, obj1.visitOrder - obj2.visitOrder));
    }];
    
    //重新从0开始赋值CacheObject实例的visitOrder
    NSInteger index = 0;
    for (XCacheObject *object in resultArray) {
        object.visitOrder = index++;
    }
    
    //重新赋值循环处理后的最大的index
    _currentVisitCount = index;
//    }
}

- (void)findMinOderAndMinCountCacheObjectForKey:(id *)key_p
                                         Object:(XCacheObject **)obj_p
                                        Order_p:(NSInteger *)order_p
{
    
    NSMutableArray *keys = [[[self.store objectMap] allKeys] mutableCopy];
    
    //保存找到的最久未使用的缓存项的visitOrder
    NSInteger minOrder = INT_MAX;
    
    //保存找到的最久未使用的缓存项
    XCacheObject *oldestObject = nil;
    
    //保存找到的最久未使用的缓存项的Key
    id oldestkey = nil;
    
    //遍历所有缓存项
    for (id key in keys) {
        
        XCacheObject *cacheObj = [[self.store objectMap] objectForKey:key];
        
        if (cacheObj.visitOrder < minOrder) {
            
            //替换成找到最小的
            oldestObject = cacheObj;
            minOrder = cacheObj.visitOrder;
            oldestkey = key;
        }
    }
    
//    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
//    [returnDict safeSetObject:oldestkey forKey:@"xcache_object_key"];
//    [returnDict safeSetObject:oldestObject forKey:@"xcache_object_object"];
//    [returnDict safeSetObject:@(minOrder) forKey:@"xcache_object_order"];
    
    *key_p = oldestkey;
    *obj_p = oldestObject;
    *order_p = minOrder;
}

- (void)updateCacheObjectVisitOrderAndVisitCount:(XCacheObject *)cacheObject {
    
    //修改找到的对象的顺序值
    cacheObject.visitOrder = _currentVisitCount++;
    [self recycleCurrentVisitOrder];
    
    //增加缓存项被访问的次数
    cacheObject.visitCount++;
}

@end