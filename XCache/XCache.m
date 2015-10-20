//
//  XCache.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCache.h"
//#import "XCacheStore.h"

@interface XCache ()

@property (nonatomic, strong, readwrite) XCacheStore *store;

@end

@implementation XCache

- (XCacheStore *)store {
    if (!_store) {
        _store = [XCacheStore x_sharedInstance];
    }
    return _store;
}

+ (instancetype)x_sharedInstance {
    static XCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[XCache alloc] init];
    });
    return cache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)x_saveObject:(id)object ForKey:(NSString *)key Timeout:(NSInteger)time {
    if (!object || [object isEqual:[NSNull null]] || !key || [key isEqualToString:@""]) {
        return;
    }
    
    [self.store x_saveObject:object forKey:key expiredAfter:time];
    
}

- (id)x_getObjectWithKey:(NSString *)key {
    return [self.store x_loadObjectWithKey:key];
}

- (void)x_removeObjectWithKey:(NSString *)key {
    [self.store x_removeCacheObjectWithKey:key];
}

@end
