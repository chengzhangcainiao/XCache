//
//  XCacheHolderProtocol.h
//  XCache
//
//  Created by XiongZenghui on 15/9/28.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCacheObject;

@protocol XCacheHolderProtocol <NSObject>

- (NSInteger)memorySize;
- (NSInteger)diskSize;

- (NSMutableDictionary *)objects;
- (NSMutableArray *)keys;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (void)saveObject:(id)obj forKey:(NSString *)key;
- (void)saveObject:(id)obj forKey:(NSString *)key duration:(NSInteger)time;

- (XCacheObject *)getObjectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (NSDictionary *)serializeToDict;
- (void)unSerilizeFromDict:(NSDictionary *)dict;

@end
