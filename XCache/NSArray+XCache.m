//
//  NSArray+XCache.m
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "NSArray+XCache.h"

@implementation NSArray (XCache)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if ((self.count > 0) && (self.count > index)) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
}

- (id)objectAtCircleIndex:(NSInteger)index {
    return [self safeObjectAtIndex:[self superCircle:index maxSize:self.count]];
}

- (NSInteger)superCircle:(NSInteger)index maxSize:(NSInteger)maxSize
{
    if(index < 0)
    {
        index = index % maxSize;
        index += maxSize;
    }
    if(index >= maxSize)
    {
        index = index % maxSize;
    }
    
    return index;
}

- (NSArray *)reversedArray {
    return [[self class] reversedArray:self];
}

+ (NSArray *)reversedArray:(NSArray *)array {
    NSMutableArray *arrayTemp = [NSMutableArray arrayWithCapacity:[array count]];
    NSEnumerator *enumerator = [array reverseObjectEnumerator];
    
    for(id element in enumerator) {
        [arrayTemp addObject:element];
    }
    
    return arrayTemp;
}

- (NSString *)arrayToJson {
    return [[self class] arrayToJson:self];
}

+ (NSString *)arrayToJson:(NSArray *)array {
    NSString *json = nil;
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    
    if(!error)
    {
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return json;
    } else {
        return error.localizedDescription;
    }
}


@end
