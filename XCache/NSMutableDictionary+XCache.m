//
//  NSMutableDictionary+XCache.m
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "NSMutableDictionary+XCache.h"

@implementation NSMutableDictionary (XCache)

- (BOOL)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if(anObject == nil || [anObject isEqual:[NSNull null]])
    {
        return NO;
    }
    
    [self setObject:anObject forKey:aKey];
    
    return YES;
}
@end
