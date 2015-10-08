//
//  XCacheStore.m
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStore.h"
#import <UIKit/UIApplication.h>
#import "XCacheObject.h"
#import "NSFileManager+XCache.h"

@interface XCacheStore () {
    
    BOOL            _isArchivring;
    BOOL            _isUnArchivring;
    
    NSInteger       _sequenceId;
}

@property (nonatomic, copy) NSString                                *rootPath;

@property (nonatomic, strong, readwrite) NSRecursiveLock            *lock;
@property (nonatomic, strong, readwrite) XCacheFastTable            *fastTable;
@property (nonatomic, assign, readwrite) NSUInteger                 memorySize;
@property (nonatomic, assign, readwrite) NSUInteger                 memoryTotalCost;
@property (nonatomic, assign, readwrite) NSUInteger                 diskTotalCost;

- (void)readDiskCurrentTotalCost;
- (void)cleaningCachedObjects;
- (void)archiverToDiskFile;
- (void)startScheduleArchiver;
- (void)startBackgroudTaskToArchiver;

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
    [self archiverToDiskFile];
    self.lock = nil;
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
    
    //1. 创建一个用于包装原始对象的缓存对象
    XCacheObject *cacheObject = [[XCacheObject alloc] initWithObject:object Duration:duration];
    
    if (_isArchivring) {//正在清理内存缓存对象，所以就不把当前新的对象保存到内存，而直接写入本地
        //写入本地文件
        [cacheObject.data writeToFile:[self getAbsoluteFilePathWithName:key] atomically:YES];
    } else {
        //使用内存保存
        [self.objectMap setObject:cacheObject forKey:key];
        self.memorySize += [cacheObject cacheSize];
    }
    
    [self.lock lock];
    [_fastTable setCacheObject:object WithKey:key];
    [self.lock unlock];
}

- (void)loadObjectWithKey:(NSString *)key {
    [_fastTable getCacheObjectWithKey:key];
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
    [self.notificationCenter addObserver:self selector:@selector(cleaningCachedObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)cleaningCachedObjects {
    //...
    
    [self archiverToDiskFile];
}

- (void)archiverToDiskFile {
    
    if (_isArchivring) {
        return;
    }

    
    [self.lock lock];
    
    //开启一个后台任务，归档对象到磁盘文件
    [self startBackgroudTaskToArchiver];
    
    [self.lock unlock];
}

- (void)startScheduleArchiver {
    //1. 新建一个子线程
    //2. open runloop
    //3. NSTimer计时
    //4. 归档对象
}

- (void)startBackgroudTaskToArchiver {

    _isArchivring = YES;
    
    //后台子线程归档对象到磁盘文件
    //...
    
    _isArchivring = NO;
}

- (void)readDiskCurrentTotalCost {//读取磁盘缓存文件大小
    
}

- (NSString *)getAbsoluteFilePathWithName:(NSString *)name {
    return [self.rootPath stringByAppendingPathComponent:name];
}

@end
