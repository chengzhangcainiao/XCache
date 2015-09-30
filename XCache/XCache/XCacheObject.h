//
//  XCacheObject.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCacheObject : NSObject

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithData:(id)aData Duration:(NSInteger)duration;

- (NSData *)cacheData;
- (NSInteger)cacheSize;
- (id)dataInOptions;
- (NSInteger)expirateTimestampInOptions; 

- (void)updateCacheObjectLifeDuration:(NSInteger)duration;

- (BOOL)isExpirate;

@end
