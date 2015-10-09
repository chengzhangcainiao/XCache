//
//  XCacheStrategyFactory.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStrategyFactory.h"
#import "NSMutableArray+Queue.h"
#import "NSFileManager+XCache.h"
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

@implementation XCacheExchangeStrategyBase

- (XCacheStore *)store {
    return self.table.store;
}

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {}

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

@implementation XCacheExchangeLRUStrategy

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key {
    
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
        return [[XCacheObject alloc] initWithData:[self.store.objectMap objectForKey:key]];
        
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