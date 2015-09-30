//
//  XCacheStore.h
//  XCache
//
//  Created by xiongzenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
参考MKNetworkKit队列缓存、ASimpleCache缓存

1. 从缓存中，命中到这个对象，将这个命中对象作为最后被访问过的.

2. 从缓存中，没有命中这个对象.
2.1 如果内存缓存空间没满，直接放入缓存
2.2 如果内存缓存空间满了，就要使用某一种替换算法，来保存这个新对象

3. 使用’索引表‘加快命中效率.

4. 替换策略.
4.1 LFU，我会计算为每个缓存对象计算他们被使用的频率。我会把最不常用的缓存对象踢走。
4.2 LRU，类似队列结构，最后访问的放入队尾，每次清除队头对象。
.....等等其他算法

5. 定期查看内存缓存，超过规定大小时，按照算法，将部分对象归档到磁盘文件.
*/

@interface XCacheStore : NSObject



@end
