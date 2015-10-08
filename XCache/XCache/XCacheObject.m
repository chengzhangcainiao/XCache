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
NSString *const TargetObject          = @"TargetObject";

@interface XCacheObject ()

@property (nonatomic, strong, readwrite) NSData *data;
@property (nonatomic, strong, readwrite) NSMutableDictionary *options;

@end

@implementation XCacheObject

- (NSMutableDictionary *)options {
    if (!_options) {
        _options = [[NSMutableDictionary alloc] init];
    }
    return _options;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithObject:(id)aObject Duration:(NSInteger)duration {
    self = [super init];
    if (self) {
        [self generateDataWithObject:aObject Duration:duration];
    }
    return self;
}

- (NSData *)cacheData {
    return _data;
}

- (NSInteger)cacheSize {
    return _data.length;
}

- (id)targetObjectInOptions {
    if (!_options) {
        _options = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
    }
    
    if ([[self.options allKeys] containsObject:TargetObject] && \
        [self.options objectForKey:TargetObject])
    {
        return [self.options objectForKey:TargetObject];
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

- (void)generateDataWithObject:(id)aObject Duration:(NSInteger)duration {
    
    //对象超时时间
    duration = [XCacheConfig computeLifeTimeoutWithDuration:duration];
    
    //options字典保存超时时间
    [self.options setObject:@(duration) forKey:ExpirateTimestamp];
    
    //options字典保存原始对象
    [self.options setObject:aObject forKey:TargetObject];
    
    //将options字典归档为NSData
    self.data = [NSKeyedArchiver archivedDataWithRootObject:self.options];
}

@end

