//
//  NSMutableArray+Queue.m
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "NSMutableArray+Queue.h"
#import "NSArray+XCache.h"

@interface NSMutableArray ()
@property (nonatomic, assign) NSInteger x_length;
@end

@implementation NSMutableArray (Queue)

+ (instancetype)x_instanceWithLength:(NSInteger)length {
    NSMutableArray *queue = [[NSMutableArray alloc] init];
    queue.x_length = length;
    return queue;
}

- (id)x_enqueObject:(id)object {
    if (self.count >= self.x_length) {
        [self addObject:object];
        return [self firstObject];
    } else {
        [self addObject:object];
        return nil;
    }
}

- (id)x_dequeObject {
    if ([self count] == 0) {
        return nil;
    }
    
    id obj = [self firstObject];
    if (obj != nil) {
        [self removeObject:obj];
    }
    
    return obj;
}

- (id)x_peek:(int)index {
    return [self safeObjectAtIndex:index];
}

- (id)x_peekHead {
    return [self firstObject];
}

- (id)x_peekTail {
    return [self lastObject];
}

- (BOOL)x_isEmpty {
    return ([self lastObject] == nil);
}

@end
