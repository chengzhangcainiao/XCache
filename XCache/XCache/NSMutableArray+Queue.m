//
//  NSMutableArray+Queue.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "NSMutableArray+Queue.h"
#import "NSArray+XCache.h"

@implementation NSMutableArray (Queue)

- (void)enqueObject:(id)object {
    [self addObject:object];
}

- (id)dequeObject {
    if ([self count] == 0) {
        return nil;
    }
    
    id obj = [self firstObject];
    if (obj != nil) {
        [self removeObject:obj];
    }
    
    return obj;
}

- (id)peek:(int)index {
    return [self safeObjectAtIndex:index];
}

- (id)peekHead {
    return [self firstObject];
}

- (id)peekTail {
    return [self lastObject];
}

- (BOOL)isEmpty {
    return ([self lastObject] == nil);
}

@end
