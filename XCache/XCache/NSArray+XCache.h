//
//  NSArray+XCache.h
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (XCache)

- (id)safeObjectAtIndex:(NSUInteger)index;

- (NSArray *)reversedArray;
+ (NSArray *)reversedArray:(NSArray *)array;

- (NSString *)arrayToJson;
+ (NSString *)arrayToJson:(NSArray *)array;

- (id)objectAtCircleIndex:(NSInteger)index;

@end
