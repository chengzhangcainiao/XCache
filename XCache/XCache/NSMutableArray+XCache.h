//
//  NSMutableArray+XCache.h
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (XCache)

- (void)moveObjectFromIndex:(NSUInteger)from
                    toIndex:(NSUInteger)to;

- (NSMutableArray *)reversedArray;


@end
