//
//  XCacheObjectPersistentProtocol.h
//  XCache
//
//  Created by xiongzenghui on 15/9/28.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCacheObject;

@protocol XCacheObjectPersistentProtocol <NSObject>

- (BOOL)isHasObjectForKey:(NSString *)key;

- (void)saveObejct:(id)object forKey:(NSString *)key;
- (XCacheObject *)findObjectForKey:(NSString *)key;

- (void)removeObjectForkey:(NSString *)key;
- (void)removeAllObjects;

- (NSDictionary *)serializedToDict;
- (void)unSerializedFromDict:(NSDictionary *)dict;

@end
