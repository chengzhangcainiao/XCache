//
//  XCacheConfig.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheConfig : NSObject

+ (NSInteger)maxCacheOnMemoryTime;
+ (NSInteger)maxCacheOnDiskTime;

+ (NSInteger)maxCacheOnMemorySize;
+ (NSInteger)maxCacheOnDiskSize;
+ (NSString *)cacheFolderPath;
+ (NSString *)rootPath;

@end
