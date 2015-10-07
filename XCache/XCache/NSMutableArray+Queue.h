//
//  NSMutableArray+Queue.h
//  XCache
//
//  Created by xiongzenghui on 15/10/2.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void)enqueObject:(id)object;
- (id)dequeObject;

-(id) peek:(int)index;
-(id) peekHead;
-(id) peekTail;

- (BOOL)isEmpty;

@end
