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

+ (id<XCacheStrategyProtocol>)LRU_kExchangeWithTable:(XCacheFastTable *)table KCount:(NSInteger)k {
    static XCacheStrategyLRU_KStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheStrategyLRU_KStrategy alloc] initWithK:k];
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

- (BOOL)x_isConstainKeyInObjectMap:(NSString *)key {
    NSArray *keys = [[self.store objectMap] allKeys];
    return [keys containsObject:key];
}

- (void)x_cacheObject:(XCacheObject *)object WithKey:(NSString *)key {}

- (void)x_cleaningCacheObjects {}

- (XCacheObject *)x_searchWithKey:(NSString *)key{return nil;}

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

- (XCacheObject *)x_searchWithKey:(NSString *)key {
    
    BOOL isExistInMemory = [self x_isConstainKeyInObjectMap:key];
    
    if (isExistInMemory) {
        
        //内存中查找到XCacheObejct实例
        XCacheObject *finded = [self.store.objectMap objectForKey:key];
        
        //是否超时
        if ([finded x_isExpirate]) {
            return nil;
        }
        
        [self x_updateCacheObjectVisitOrder:finded];
        
        //NSData *data = [finded cacheData];
        //return [[XCacheObject alloc] initWithData:data];
        
        return finded;
        
    } else {
        
        //从本地文件查找
        NSString *filePath = [NSFileManager x_pathForRootDirectoryWithPath:key];
        
        if ([NSFileManager x_existsItemAtPath:filePath]) {
            
            //本地文件找到options字典的NSData缓存文件
            //（options字典: 1)原始对象  2)超时时间）
            NSData *dataFinded = [[NSData alloc] initWithContentsOfFile:filePath];
            
            //将NSData保存到一个新的的XcacheObeject实例中
            XCacheObject *objectFinded = [[XCacheObject alloc] initWithData:dataFinded];
            
            //判断是否载入到内存
            if ([self.store x_isCanLoadCacheObjectToMemory] && ![objectFinded x_isExpirate]) {
                /*
                 这句会引起死锁，也没必要。因为此时的XCacheObject实例，
                 是从本地文件恢复的，肯定是带有超时设置的。
                 
                 [self.store saveObject:objectFinded forKey:key expiredAfter:[XCacheConfig maxCacheOnMemoryTime]];
                 */
                
                //载入到内存
                [[self.store objectMap] setObject:objectFinded forKey:key];
                
                [self x_updateCacheObjectVisitOrder:objectFinded];
                
                [NSFileManager x_removeItemAtPath:filePath];
            }
            
            return objectFinded;
            
        } else {
            
            //本地文件未找到
            return nil;
        }
    }
}

- (void)x_cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    if (![self x_isConstainKeyInObjectMap:key]) {
        [self x_updateCacheObjectVisitOrder:object];
    }
    [self x_cleaningCacheObjects];
}

- (void)x_cleaningCacheObjects {
    [self.lock lock];
    
    NSMutableArray *keys = [[self.store keyList] mutableCopy];
    NSInteger maxKeyCount = [XCacheConfig x_maxCacheOnMemorySize];
    NSInteger maxCacheCost = [XCacheConfig x_maxCacheOnMemoryCost];
    BOOL isArchiveWhenLose = [XCacheConfig x_isArchiverWhenLose];
    
    //当前是否可以进行写入操作
    BOOL isArchiving = YES;
    
    //清理内存缓存条件
    //1. 当前内存缓存的个数 > 规定的长度
    //2. 当前内存缓存的总开销 > 规定的大小
    while (([keys count] > maxKeyCount) || (self.store.memoryTotalCost > maxCacheCost)) {
        
        //保存找到的最久未使用的缓存项
        XCacheObject *oldestObject = nil;
        NSInteger oldestOrder = INT_MAX;
        id oldestkey = @"";
        
        //查询最小的
        [self x_findMinOderAndMinCountCacheObjectForKey:&oldestkey
                                                 Object:&oldestObject
                                                Order_p:&oldestOrder];
        
        //找到了久未使用的缓存项，将其归档到本地
        if (oldestkey) {
            
            //判断是否写入磁盘文件
            if (isArchiving && isArchiveWhenLose) {
                [self.store x_dataWriteToRootFolderWithKey:oldestkey
                                                      Data:[oldestObject x_cacheData]];
            }
            
            //从内存删除
            [self.store x_removeMemoryCacheObject:oldestObject WithKey:oldestkey];
            
            //遍历数组移除key
            [keys removeObject:oldestkey];
        }
    }
    
    isArchiving = NO;
    
    [self.lock unlock];
}

/**
 *  循环处理_currentVisitCount，防止数字过大
 */
- (void)x_recycleCurrentVisitOrder {
    
    //遍历objectMap保存的CacheObject实例，按照visitOrder从小到大排序
    NSArray *resultArray = [[self.store valueList] sortedArrayUsingComparator:^NSComparisonResult(XCacheObject *obj1, XCacheObject *obj2) {
        return (NSComparisonResult)MIN(1, MAX(-1, obj1.visitOrder - obj2.visitOrder));
    }];
    
    //重新从0开始赋值CacheObject实例的visitOrder
    NSInteger index = 0;
    for (XCacheObject *object in resultArray) {
        object.visitOrder = index++;
    }
    
    //重新赋值循环处理后的最大的index
    _currentVisitCount = index;
}

/**
 *  使用LRU淘汰算法，查找到最小visitOrder的缓存项
 */
- (void)x_findMinOderAndMinCountCacheObjectForKey:(id *)key_p
                                         Object:(XCacheObject **)obj_p
                                        Order_p:(NSInteger *)order_p
{
    
    NSMutableArray *keys = [[self.store keyList] mutableCopy];
    
    NSInteger minOrder = INT_MAX;
    XCacheObject *oldestObject = nil;
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

/**
 *  visitOrder++
 *  循环处理visitOrder
 */
- (void)x_updateCacheObjectVisitOrder:(XCacheObject *)cacheObject {
    
    //修改找到的对象的顺序值
    cacheObject.visitOrder = _currentVisitCount++;
    
    //循环处理
    [self x_recycleCurrentVisitOrder];
}

@end

@interface XCacheStrategyLRU_KStrategy ()

@property (nonatomic, assign) NSInteger k;
@property (nonatomic, strong) NSMutableArray *historyQueue;
@property (nonatomic, strong) NSMutableArray *cacheQueue;

@property (nonatomic, strong) NSTimer *histotyTimer;

- (NSString *)x_startScheduleHistoryQueue;

@end

@implementation XCacheStrategyLRU_KStrategy

- (NSMutableArray *)historyQueue {
    if (!_historyQueue) {
        _historyQueue = [[NSMutableArray alloc] init];
    }
    return _historyQueue;
}

- (NSMutableArray *)cacheQueue {
    if (!_cacheQueue) {
        _cacheQueue = [[NSMutableArray alloc] init];
    }
    return _cacheQueue;
}

- (void)dealloc {
    [_histotyTimer invalidate];
    _histotyTimer = nil;
}

- (instancetype)initWithK:(NSInteger)k {
    self = [super init];
    if (self) {
        _k = (k >= LRU_K_COUNT) ? k : LRU_K_COUNT;
    }
    return self;
}

- (XCacheObject *)x_searchWithKey:(NSString *)key {
    XCacheObject *finded = [super x_searchWithKey:key];
    if (finded) {
        [self x_updateCacheObjectVisitOrderAndVisitCount:finded];
        
        //暂时不淘汰访问历史项，因为长度不好确定
        [self.historyQueue x_enqueObject:key];
        [self x_startScheduleHistoryQueue];
    }
    return finded;
}

- (void)x_cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
    if (![self x_isConstainKeyInObjectMap:key]) {
        [self x_updateCacheObjectVisitOrderAndVisitCount:object];
        
        //将当前被访问的Key放入到historyQueue
        [self.historyQueue x_enqueObject:key];
        
        //调整historyQueue里面的key，是否能够调入到cacheQueue
        [self x_startScheduleHistoryQueue];
    }
    
    //开始清理内存
    [self x_cleaningCacheObjects];
}

- (void)x_cleaningCacheObjects {//lru-k替换策略
    [self.lock lock];
    BOOL isArchiving = NO;
    
    NSMutableArray *keys = [[self.store keyList] mutableCopy];
    NSInteger maxCacheCount = [XCacheConfig x_maxMemoryQueueSize];
    NSInteger maxCacheCost = [XCacheConfig x_maxCacheOnMemoryCost];
    BOOL isArchiveWhenLose = [XCacheConfig x_isArchiverWhenLose];
    
    while (([keys count] > maxCacheCount) || ([self.store memoryTotalCost] > maxCacheCost)) {
        
        //从cacheQueue找到最久未被使用的缓存项
        NSString *oldestKey = [self findOldestNotVisitCacheKeyInCacheQueue];
        
        //将淘汰的缓存项其归档到本地
        if (oldestKey) {
            
            //取出key对应的缓存项
            XCacheObject *cacheObject = [[self.store objectMap] objectForKey:oldestKey];
            
            //当前没有进行其他的归档操作
            if (isArchiving && isArchiveWhenLose) {
                NSData *cacheData = [cacheObject x_cacheData];
                [self.store x_dataWriteToRootFolderWithKey:oldestKey Data:cacheData];
            }
            
            //从内存中删除
            [self.store x_removeMemoryCacheObject:cacheObject WithKey:oldestKey];
            
            //遍历数组移除key
            [keys removeObject:oldestKey];
        }
    }
    
    isArchiving = YES;
    [self.lock unlock];
}

/**
 *  visitOrder++
 *  visitCount++
 */
- (void)x_updateCacheObjectVisitOrderAndVisitCount:(XCacheObject *)cacheObject {
    [self x_updateCacheObjectVisitOrder:cacheObject];
    cacheObject.visitCount++;
}

/**
 *  将historyQueue中的缓存项，访问次数超过k次的调入cacheQueue
 */
- (NSString *)x_startScheduleHistoryQueue {
    
    __block NSString *popKey = nil;
    
    NSArray *historyCopy = [self.historyQueue copy];
    
    __weak __typeof(self)weakSelf = self;
    [historyCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSString *key = obj;
            XCacheObject *object = [[strongSelf.store objectMap] objectForKey:key];
            
            if (![[strongSelf.store keyList] containsObject:@"key"]) {
                if ([object visitCount] > _k) {
                    [strongSelf.cacheQueue x_enqueObject:key];
                    
                    //如果超过historyQueue长度
                    if ([strongSelf.cacheQueue count] > [XCacheConfig x_maxHistoryQueueSize]) {
                        
                        //取出队头的key
                        NSString *oldestKey = [strongSelf.cacheQueue x_dequeObject];
                        popKey = [oldestKey copy];
                    }
                }
            }
        }
    }];
    
    return popKey;
}

/**
 *  在cacheQueue中查找最久未被使用的缓存项的key
 */
- (NSString *)findOldestNotVisitCacheKeyInCacheQueue {
    
    __block NSString *minKey = nil;
    __block NSInteger minVisistOrder = INT_MAX;
    
    NSArray *cacheCopy = [self.cacheQueue copy];
    
    __weak __typeof(self)weakSelf = self;
    [cacheCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSString *key = obj;
            XCacheObject *object = [[strongSelf.store objectMap] objectForKey:key];
            
            if (object.visitOrder < minVisistOrder) {
                minVisistOrder = object.visitOrder;
                minKey = key;
            }

        }
    }];
    
    return minKey;
}

@end
