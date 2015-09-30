//
//  XCacheQueue.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheQueue : NSObject

@property (nonatomic, assign) NSInteger maxCacheCount;

@property (nonatomic, assign) BOOL isAutoArchiveToDiskFileWhenOverThanMaxCacheCount;

- (NSArray *)peekAllCachedObjects;
- (id)peekHeadObejct;
- (id)peekTailObejct;

- (NSInteger)currentCachedCount;

- (id)enqueObject:(id)object;
- (id)dequeObject;

@end
