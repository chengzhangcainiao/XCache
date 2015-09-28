//
//  XCacheMemory.m
//  XCache
//
//  Created by xiongzenghui on 15/9/28.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XCacheMemory.h"

#undef	DEFAULT_MAX_COUNT
#define DEFAULT_MAX_COUNT	(50)

@interface XCacheMemory ()

@property (nonatomic, assign) BOOL              isClearWhenMemoryLow;
@property (nonatomic, assign) NSInteger         maxCacheCount;
@property (nonatomic, assign) NSInteger         cachedCount;
@property (nonatomic, strong) NSMutableArray *  cacheKeys;
@property (nonatomic, strong) NSMutableArray *  cacheObjetcs;

@end

@implementation XCacheMemory



@end
