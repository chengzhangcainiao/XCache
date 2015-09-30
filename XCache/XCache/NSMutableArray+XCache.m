//
//  NSMutableArray+XCache.m
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "NSMutableArray+XCache.h"
#import "NSArray+XCache.h"

@implementation NSMutableArray (XCache)

- (void)moveObjectFromIndex:(NSUInteger)from
                    toIndex:(NSUInteger)to
{
    if(to != from)
    {
        id obj = [self safeObjectAtIndex:from];
        [self removeObjectAtIndex:from];
        
        if(to >= [self count])
            [self addObject:obj];
        else
            [self insertObject:obj atIndex:to];
    }
}

- (NSMutableArray *)reversedArray {
    return (NSMutableArray *)[[self class] reversedArray:self];
}


@end
