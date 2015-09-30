//
//  XCacheStore.m
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStore.h"

@interface XCacheStore ()

@end


@implementation XCacheStore

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
        
    }
    return self;
}

@end
