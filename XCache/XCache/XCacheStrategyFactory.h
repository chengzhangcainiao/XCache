//
//  XCacheStrategyFactory.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCacheStrategyProtocol.h"

@class XCacheFastTable;
@class XCacheFIFOPloicy;
@class XCacheLRUPloicy;
@class XCacheLFUPloicy;

@interface XCacheStrategyFactory : NSObject

+ (XCacheFIFOPloicy *)FIFOWithTable:(XCacheFastTable *)table;
+ (XCacheLRUPloicy *)LRUWithTable:(XCacheFastTable *)table;
+ (XCacheLFUPloicy *)LFUWithTable:(XCacheFastTable *)table;

@end

@interface XCachePolicyBase : NSObject <XCacheStrategyProtocol>

@property (nonatomic, strong) XCacheFastTable *table;

@property (nonatomic, strong) NSMutableArray *keyArray;
@property (nonatomic, strong) NSMutableDictionary *cacheObjectDictionary;

@end

@interface XCacheFIFOPloicy : XCachePolicyBase

@end

@interface XCacheLRUPloicy : XCachePolicyBase

@end

@interface XCacheLFUPloicy : XCachePolicyBase

@end


