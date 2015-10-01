//
//  XCacheStore.m
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheStore.h"
#import <UIKit/UIApplication.h>

@interface XCacheStore ()

@property (nonatomic, strong) NSRecursiveLock *lock;

@end


@implementation XCacheStore

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
    }
    return self;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

- (void)addObserveNotifications {
    [self.notificationCenter addObserver:self selector:@selector(cleaningCachedObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)cleaningCachedObjects {
    
}

@end
