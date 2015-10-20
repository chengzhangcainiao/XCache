//
//  XCacheObject.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheObject.h"
#import "XCacheConfig.h"
#import "NSMutableDictionary+XCache.h"

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
        _visitOrder = 0;
        _visitCount = 0;
        _data = data;
    }
    return self;
}

- (instancetype)initWithObject:(id)aObject Duration:(NSInteger)duration {
    self = [super init];
    if (self) {
        _visitOrder = 0;
        _visitCount = 0;
        [self x_generateDataWithObject:aObject Duration:duration];
    }
    return self;
}

- (NSData *)x_cacheData {
    return _data;
}

- (NSInteger)x_cacheSize {
    return _data.length;
}

- (id)x_targetObjectInOptions {
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

- (NSInteger)x_expirateTimestampInOptions {
    if (!self.options) {
        self.options = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
    }
    
    if ([[self.options allKeys] containsObject:ExpirateTimestamp])
    {
        return [[self.options objectForKey:ExpirateTimestamp] integerValue];
    }
    
    return 0;
}

- (BOOL)x_isExpirate {
    NSInteger expirateTime = [self x_expirateTimestampInOptions];
    NSInteger nowTime = [XCacheConfig x_nowTimestamp];
    
    if (expirateTime == 0) {//为0表示没有超时设置
        return NO;
    }
    
    if (expirateTime < nowTime) {
        return NO;
    } else {
        return YES;
    }
}

- (void)x_updateCacheObjectLifeDuration:(NSInteger)duration {
    if (!self.options) {
        self.options = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
    }
    
    if ([[self.options allKeys] containsObject:ExpirateTimestamp]) {
        duration = [XCacheConfig x_computeLifeTimeoutWithDuration:duration];
        [self.options safeSetObject:@(duration) forKey:ExpirateTimestamp];
    }
}


#pragma mark - tool

- (void)x_generateDataWithObject:(id)aObject Duration:(NSInteger)duration {
    
    //对象超时时间
    duration = [XCacheConfig x_computeLifeTimeoutWithDuration:duration];
    
    //options字典保存超时时间
    [self.options safeSetObject:@(duration) forKey:ExpirateTimestamp];
    
    //options字典保存原始对象
    [self.options safeSetObject:aObject forKey:TargetObject];
    
    //将options字典归档为NSData
    self.data = [NSKeyedArchiver archivedDataWithRootObject:self.options];
}

@end

