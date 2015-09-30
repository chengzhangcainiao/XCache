//
//  XCacheObject.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheObject.h"
#import "XCacheConfig.h"

NSString *const ExpirateTimestamp     = @"ExpirateTimestamp";
NSString *const CacheData             = @"CacheData";

@interface XCacheObject ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableDictionary *options;

- (void)generateData:(NSData *)data Duration:(NSInteger)duration;

@end

@implementation XCacheObject

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        //内存永久保存，直到程序退出，内存释放
        _data = data;
    }
    return self;
}

- (instancetype)initWithData:(id)aData Duration:(NSInteger)duration {
    self = [super init];
    if (self) {
        [self generateData:aData Duration:duration];
    }
    return self;
}

- (NSData *)cacheData {
    return _data;
}

- (NSInteger)cacheSize {
    return _data.length;
}

- (id)dataInOptions {
    if (!self.options) {
        self.options = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
    }
    
    if ([[self.options allKeys] containsObject:CacheData] && \
        [self.options objectForKey:CacheData])
    {
        return [self.options objectForKey:CacheData];
    }
    
    return nil;
}

- (NSInteger)expirateTimestampInOptions {
    if (!self.options) {
        self.options = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
    }
    
    if ([[self.options allKeys] containsObject:ExpirateTimestamp])
    {
        return [[self.options objectForKey:ExpirateTimestamp] integerValue];
    }
    
    return 0;
}

- (BOOL)isExpirate {
    NSInteger expirateTime = [self expirateTimestampInOptions];
    NSInteger nowTime = [XCacheConfig nowTimestamp];
    
    if (expirateTime == 0) {//为0表示没有超时设置
        return NO;
    }
    
    if (expirateTime < nowTime) {
        return NO;
    } else {
        return YES;
    }
}

- (void)updateCacheObjectLifeDuration:(NSInteger)duration {
    if (!self.options) {
        self.options = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
    }
    
    if ([[self.options allKeys] containsObject:ExpirateTimestamp]) {
        duration = [XCacheConfig computeLifeTimeoutWithDuration:duration];
        [self.options setObject:@(duration) forKey:ExpirateTimestamp];
    }
}


#pragma mark - tool

//包装data
- (void)generateData:(NSData *)data Duration:(NSInteger)duration {
    
    //1. 字典
    self.options = [NSMutableDictionary dictionary];
    
    //2. 对象超时的时刻
    duration = [XCacheConfig computeLifeTimeoutWithDuration:duration];
    [self.options setObject:@(duration) forKey:ExpirateTimestamp];
    
    //3. 保存缓存对象的NSData
    [self.options setObject:data forKey:CacheData];
    
    //4. 将字典归档成NSData
    self.data = [NSKeyedArchiver archivedDataWithRootObject:self.options];
}

@end

