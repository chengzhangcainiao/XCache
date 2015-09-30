//
//  XCachePool.h
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
1. 将对象按唯一的标识ID存入缓存池（池内部用hashMap 实现）；

2. 通过唯一标示ID高速读取池中的对象，如果对象已经失效，返回空；

3. 自动计算对象的存取时间，使用频率，使用次数，缓存命中次数和访问次数；

4. 对于使用频率低，使用次数少，空闲时间长的对象，自动从缓存池中删除；

5. 参数可配置，监视器自己实现，不依赖其他包，功能简单；
*/

@interface XCachePool : NSObject



@end
