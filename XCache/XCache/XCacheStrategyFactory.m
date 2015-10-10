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

@implementation XCacheStrategyFactory

+ (id<XCacheExchangeStrategyProtocol>)FIFOExchangeWithTable:(XCacheFastTable *)table {
    static XCacheExchangeFIFOStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheExchangeFIFOStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheExchangeStrategyProtocol>)LFUExchangeWithTable:(XCacheFastTable *)table {
    static XCacheExchangeLFUStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheExchangeLFUStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheExchangeStrategyProtocol>)LRUExchangeWithTable:(XCacheFastTable *)table {
    static XCacheExchangeLRUStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XCacheExchangeLRUStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheSearchStrategyProtocol>)normalSearchWithTable:(XCacheFastTable *)table {
    static XcacheNoneSearchStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XcacheNoneSearchStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

+ (id<XCacheSearchStrategyProtocol>)mulLevelSearchWithTable:(XCacheFastTable *)table {
    static XcacheMulLevelCacheSearchStrategy *policy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [[XcacheMulLevelCacheSearchStrategy alloc] init];
        policy.table = table;
    });
    return policy;
}

@end

#pragma mark -

@implementation XCacheExchangeStrategyBase

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

@end


@interface XCacheExchangeFIFOStrategy ()

@property (nonatomic, strong) NSMutableArray *keyQueue;

@end

@implementation XCacheExchangeFIFOStrategy

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

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end



@implementation XCacheExchangeLFUStrategy

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
}

@end

/**
 *  LRU替换缓存对象
 */
@interface XCacheExchangeLRUStrategy ()

/**
 *  循环记录当前访问缓存对象的总次数
 */
@property (nonatomic, assign)NSInteger currentVisitCount;

@end

@implementation XCacheExchangeLRUStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentVisitCount = 0;
    }
    return self;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
    [self.lock lock];
    
    // 让当前访问缓存的总次数赋值给缓存对象的保存，方便后续排除最少访问次数的缓存对象
    object.visitOrder = _currentVisitCount++;
    
    // 循环处理_currentVisitCount，防止数字过大
//    if (_currentVisitCount < 0) {
        [self recycleCurrentVisitCount];
//    }
    
    [self.lock unlock];
    
    //按照LRU替换算法，清理内存对象
    [self cleaningCacheObjects:YES];
}

- (void)cleaningCacheObjects:(BOOL)isArchive {
    [self.lock lock];
    
    //保存当前遍历的缓存项的keys
    NSMutableArray *keys = [[[self.store objectMap] allKeys] mutableCopy];
    
    //规定最大缓存个数 与 当前内存缓存的最大个数
    NSInteger maxCount = [XCacheConfig maxCacheOnMemorySize];
    NSInteger totalCount = [[self.store objectMap] count];
    
    //规定的最大内存花销 与 当前内存的花销
    NSInteger totalCost = self.store.memoryTotalCost;
    NSInteger maxCost = [XCacheConfig maxCacheOnMemoryCost];
    
    isArchive = YES;
    
    //当超过规定长度 或 规定大小
    while ((totalCount > maxCount) || (totalCost > maxCost)) {
        
        //保存找到的最久未使用的缓存项的visitOrder
        NSInteger oldestOrder = INT_MAX;
        
        //保存找到的最久未使用的缓存项
        XCacheObject *oldestObject = nil;
        
        //保存找到的最久未使用的缓存项
        id oldestkey = nil;
        
        //遍历所有缓存项，得到最小order的缓存项
        for (id key in keys) {
            XCacheObject *cacheObj = [[self.store objectMap] objectForKey:key];
            if (cacheObj.visitOrder < oldestOrder) {
                
                //替换成找到最小的
                oldestOrder = cacheObj.visitOrder;
                oldestObject = cacheObj;
                oldestkey = key;
            }
        }
        
        //找到了久未使用的缓存项
        if (oldestkey) {
            
            [keys removeObject:oldestkey];
            
            //判断是否写入磁盘文件
            if (isArchive) {
                [self.store dataWriteToRootFolderWithKey:oldestkey Data:[oldestObject cacheData]];
            }
            
            //从内存删除
            [self.store removeMemoryCacheObject:oldestObject WithKey:oldestkey];
        }
    }
    
    isArchive = NO;
    
    [self.lock unlock];
}

- (void)recycleCurrentVisitCount {
    
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
}

@end

#pragma mark - 

@implementation XcacheSearchStrategyBase

- (XCacheStore *)store {
    return self.table.store;
}

- (XCacheObject *)searchWithKey:(NSString *)key {return nil;}

@end

@implementation XcacheNoneSearchStrategy

- (XCacheObject *)searchWithKey:(NSString *)key {
    
    if ([[self.store.objectMap allKeys] containsObject:key]) {
        
        //内存中查找到XCacheObejct实例
        XCacheObject *finded = [self.store.objectMap objectForKey:key];
        NSData *data = [finded cacheData];
        return [[XCacheObject alloc] initWithData:data];
        
    } else {
        
        //从本地文件查找
        
        NSString *filePath = [NSFileManager pathForRootDirectoryWithPath:key];
        
        if ([NSFileManager existsItemAtPath:filePath]) {
            
            //本地文件找到
            NSData *dataFinded = [[NSData alloc] initWithContentsOfFile:filePath];
            XCacheObject *objectFinded = [[XCacheObject alloc] initWithData:dataFinded];
            
            //判断是否载入到内存
            if ([self.store isCanLoadCacheObjectToMemory]) {
                
                //以默认的内存最大缓存时间，保存到内存字典
                [self.store saveObject:objectFinded forKey:key expiredAfter:[XCacheConfig maxCacheOnMemoryTime]];
                
                //移除本地文件
                [NSFileManager removeItemAtPath:filePath];
            }
            
            return objectFinded;
            
        } else {
            
            //本地文件未找到
            return nil;
        }
    }
}

@end

@implementation XcacheMulLevelCacheSearchStrategy

- (XCacheObject *)searchWithKey:(NSString *)key {
    //具体实现
    return nil;
}

@end