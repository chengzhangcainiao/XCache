//
//  XCacheStrategyProtocol.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XCacheObject;

@protocol XCacheStrategyProtocol <NSObject>

- (XCacheObject *)searchWithKey:(NSString *)key;

- (void)cacheObject:(XCacheObject *)object WithKey:(NSString *)key;

@end
