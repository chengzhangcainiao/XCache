//
//  Person.m
//  XCache
//
//  Created by XiongZenghui on 15/10/8.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}

@end
