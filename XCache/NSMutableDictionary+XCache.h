//
//  NSMutableDictionary+XCache.h
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (XCache)

- (BOOL)safeSetObject:(id)anObject
               forKey:(id<NSCopying>)aKey;

@end
