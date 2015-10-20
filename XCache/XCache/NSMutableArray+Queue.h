//
//  NSMutableArray+Queue.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

+ (instancetype)x_instanceWithLength:(NSInteger)length;

- (id)x_enqueObject:(id)object;
- (id)x_dequeObject;

-(id)x_peek:(int)index;
-(id)x_peekHead;
-(id)x_peekTail;

- (BOOL)x_isEmpty;

@end
