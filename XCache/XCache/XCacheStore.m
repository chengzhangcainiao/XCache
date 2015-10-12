//
//  XCacheStore.m
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStore.h"
#import <UIKit/UIApplication.h>

#import "NSFileManager+XCache.h"
#import "NSMutableDictionary+XCache.h"

#import "XCacheObject.h"
#import "XCacheConfig.h"


@interface XCacheStore () {
    
    BOOL            _isArchivring;
    BOOL            _isUnArchivring;
    
    NSInteger       _sequenceId;
}

@property (nonatomic, copy) NSString                                *rootPath;

@property (nonatomic, strong, readwrite) NSRecursiveLock            *lock;

@property (nonatomic, strong, readwrite) XCacheFastTable            *fastTable;

@property (nonatomic, assign, readwrite) NSInteger                 memorySize;
@property (nonatomic, assign, readwrite) NSInteger                 memoryTotalCost;
@property (nonatomic, assign, readwrite) NSInteger                 diskTotalCost;


@end


@implementation XCacheStore

- (NSString *)rootPath {
    if (!_rootPath) {
        _rootPath = [NSFileManager pathForRootDirectory];
    }
    return _rootPath;
}

- (NSMutableArray *)keyList {
    if (!_keyList) {
        _keyList = [[NSMutableArray alloc] init];
    }
    return _keyList;
}

- (NSMutableDictionary *)objectMap {
    if (!_objectMap) {
        _objectMap = [[NSMutableDictionary alloc] init];
    }
    return _objectMap;
}

- (NSRecursiveLock *)lock {
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (NSNotificationCenter *)notificationCenter {
    return [NSNotificationCenter defaultCenter];
}

+ (instancetype)sharedInstance {
    static XCacheStore *storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[XCacheStore alloc] init];
    });
    return storage;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserveNotifications];
        [self setupDatas];
    }
    return self;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

- (void)resetMemoryRecord {
    self.memorySize = 0;
    self.memoryTotalCost = 0;
    [self.objectMap removeAllObjects];
}

- (void)setupDatas {
    
    _isArchivring = NO;
    _isUnArchivring = NO;
    
    _sequenceId = 0;
    _memorySize = 0;
    _memoryTotalCost = 0;
    
    [self readDiskCurrentTotalCost];
    
    _fastTable = [[XCacheFastTable alloc] initWithCacheExcangeStrategy:XCacheExchangeStrategyLRU
                                                   CacheSearchStrategy:XCacheSearchStrategyNone
                                                            CacheStore:self];
}

- (void)changeToFastTable:(XCacheFastTable *)aTable {
    if (_fastTable != aTable) {
        self.fastTable = aTable;
    }
}

#pragma mark - 

- (void)saveObject:(id)object forKey:(NSString *)key expiredAfter:(NSInteger)duration {
    
    [self.lock lock];
    
    NSInteger olderSize;
    NSInteger newerSize;
    BOOL isNewer = NO;
    
    //先看这个key对应的XcacheObject实例有没有
    XCacheObject *cacheObject = [self loadObjectWithKey:key];
    
    if (!cacheObject) {
        
        //内存中不存在，创建一个新的XCacheObject实例，包装原始对象
        
        isNewer = YES;
        cacheObject = [[XCacheObject alloc] initWithObject:object Duration:duration];
        newerSize = [cacheObject cacheSize];
        olderSize = 0;
    } else {
        
        //内存中存在缓存key，则替换传入的新的原始对象
        
        isNewer = NO;
        olderSize = [cacheObject cacheSize];
        
        //替换找到的XcacheObject实例的data
        [cacheObject generateDataWithObject:object Duration:duration];
        
        //再记录最新的缓存大小
        newerSize = [cacheObject cacheSize];
    }
    
    [self.lock unlock];
    
    //判断当前是否，正在进行清理内存缓存对象 （如果是，就不把当前新的对象保存到内存，而直接写入本地，怕影响内存对象清理）
    if (_isArchivring) {
        //写入本地文件
        [self dataWriteToRootFolderWithKey:key Data:cacheObject.data];
    } else {
        //使用内存保存
        [self.objectMap safeSetObject:cacheObject forKey:key];
        
        if (isNewer) {
            self.memorySize++;
            self.memoryTotalCost += newerSize;
        } else {
            self.memoryTotalCost -= olderSize;
            self.memoryTotalCost += newerSize;
        }
        
        [_fastTable setCacheObject:cacheObject WithKey:key];
    }
}

- (XCacheObject *)loadObjectWithKey:(NSString *)key {
    return [_fastTable getCacheObjectWithKey:key];
}

- (void)removeCacheObjectWithKey:(NSString *)key {
    [self removeMemoryCacheObject:nil WithKey:key];
}

#pragma mark - 

- (void)dataWriteToRootFolderWithKey:(NSString *)key Data:(NSData *)data {
    
    // 先删除存在的文件
    [self removeDiskCacheFileWithKey:key];
    
    // 再将内容写入到新的文件
    [data writeToFile:[NSFileManager pathForRootDirectoryWithPath:key] atomically:YES];
}

- (void)removeMemoryCacheObject:(XCacheObject *)cacheObj WithKey:(NSString *)key {
    [self.lock lock];
    
    if (!(self.memorySize == 0)) {
        self.memorySize--;
    }
    
    if (!cacheObj) {
        cacheObj = [self.objectMap objectForKey:key];
    }
    
    if (!(self.memoryTotalCost == 0)) {
        self.memoryTotalCost -= [cacheObj cacheSize];
    }
    
    [self.objectMap removeObjectForKey:key];
    [self.lock unlock];
}

- (void)removeDiskCacheFileWithKey:(NSString *)key {
    NSString *filePath = [NSFileManager pathForRootDirectoryWithPath:key];
    
    BOOL isExist = [NSFileManager isFileItemAtPath:filePath];
    
    if (isExist) {
        [NSFileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)removeAllDiskCacheFiles {
    NSString *rootFolder = [NSFileManager pathForRootDirectory];
    [NSFileManager removeFilesInDirectoryAtPath:rootFolder];
}

#pragma mark - 

- (void)enumerateKeysAndObjetcsUsingBlock:(void (^)(id, id, BOOL *))block {
    [self.lock lock];
    [self.objectMap enumerateKeysAndObjectsUsingBlock:block];
    [self.lock unlock];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len
{
    [self.lock lock];
    NSUInteger count = [self.objectMap countByEnumeratingWithState:state objects:buffer count:len];
    [self.lock unlock];
    
    return count;
}

#pragma mark - 

- (void)addObserveNotifications {
    [self.notificationCenter addObserver:self selector:@selector(cleaningCachedObjects)
                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                  object:nil];
}

- (void)cleaningCachedObjects {
    
    //接收到内存警告时，清理内存对象，包归档到磁盘文件
    [_fastTable cleaningCacheObjectsInMomery:YES];
}

- (void)removeAllCachedObjects {
    
    if (_isArchivring) {
        return;
    }
    
    _isArchivring = YES;
    
    NSArray *keys = [self.objectMap allKeys];
    
    for (id key in keys) {
        XCacheObject *obj = [self.objectMap objectForKey:key];
        
        //写入磁盘文件
        [self dataWriteToRootFolderWithKey:key Data:[obj cacheData]];
        
        //内存删除
        [self removeMemoryCacheObject:obj WithKey:key];
    }
    
    [self resetMemoryRecord];
    
    _isArchivring = NO;
}

- (void)readDiskCurrentTotalCost {//读取磁盘缓存文件大小
    
}

- (BOOL)isCanLoadCacheObjectToMemory {
    
    //如果当前进行内存清理，则不能对内存进行读写
    BOOL flag1 = !_isArchivring;
    
    //设置了内存最大花销 与  当前内存花销 < 设置的最大内存花销
    BOOL flag2 = [XCacheConfig maxCacheOnMemoryCost] > 0;
    BOOL flag3 = self.memoryTotalCost < [XCacheConfig maxCacheOnMemoryCost];
    
    //设置了内存长度 与  当前内存长度 < 设置的最大内存长度
    BOOL flag4 = [XCacheConfig maxCacheOnMemorySize] > 0;
    BOOL flag5 = self.memorySize < [XCacheConfig maxCacheOnMemorySize];
    
    return flag1 && flag2 && flag3 && flag4 && flag5;
}

@end
