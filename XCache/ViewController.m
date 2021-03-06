//
//  ViewController.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "ViewController.h"
#import "NSFileManager+XCache.h"
//#import "NSMutableDictionary+XCache.h"
#import "Person.h"
#import "XCache.h"

@interface ViewController ()

@property (nonatomic, strong) XCache *cache;

@property (nonatomic, strong) NSRecursiveLock *lock1;
@property (nonatomic, strong) NSRecursiveLock *lock2;

@end

@implementation ViewController

- (XCache *)cache {
    if (!_cache) {
        _cache = [XCache x_sharedInstance];
    }
    return _cache;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor grayColor]];
    btn.frame = CGRectMake(20, 100, 150, 60);
    [self.view addSubview:btn];
    
//    [btn addTarget:self action:@selector(testLock) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(testArray) forControlEvents:UIControlEventTouchUpInside];
    
//    NSString *path = [NSFileManager pathForRootDirectoryWithPath:@"ccc"];
//    NSString *path = @"/dawd/dawdaw/ccc";//默认在document/dawd/dawdaw/ccc
//    [NSFileManager createFileAtPath:path withContent:@"dawdawd"];
    
    
//    NSString *path = @"/A";
//    NSArray *arrays = [NSFileManager listItemsInDirectoryAtPath:path deep:NO];
//    [NSFileManager moveItemAtPath:@"/A" toPath:@"/XXX" error:nil];
   
    /*
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary] ;

        Person *p = [[Person alloc] init];
        p.name = @"123";
        
        [dict setObject:p forKey:@"person"];
//        [dict setObject:@"234234" forKey:@"person"];
        
        NSString *filePath = [[NSFileManager pathForCachesDirectory] stringByAppendingPathComponent:@"test.plist"];
        
        [NSKeyedArchiver archiveRootObject:dict toFile:filePath];
    }
     */
    
//    {
//        Person *p = [[Person alloc] init];
//        p.name = @"123";
//        
//        [self.cache saveObject:p ForKey:@"person1" Timeout:0];
//    }
    
//    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary] ;
//        
//        for (int i = 0; i < 4; i++) {
//            Person *p = [[Person alloc] init];
//            p.age = 5 - i;
//            
//            [dict setObject:p forKey:[NSString stringWithFormat:@"%d", 5 - i]];
//        }
//        
//        //由字典获得所有value的无序数组
//        NSArray *targets = [dict allValues];
//        
//        //从大到小
//        NSArray *results = [targets sortedArrayUsingComparator:^NSComparisonResult(Person *p1, Person *p2) {
//            return (NSComparisonResult)MIN(1, MAX(-1, p1.age - p2.age));
//        }];
//        
//    }
    
//    {
//        NSMutableDictionary *dict = [@{} mutableCopy];
//        [dict removeObjectForKey:nil];
//    }

}

- (void)testCache {
    
    NSString *rootPath = [NSFileManager x_pathForRootDirectory];
    
//    Person *p = [[Person alloc] init];
//    p.age = 10;
//    
//    NSString *key = [NSString stringWithFormat:@"person%d", 10];
//    [self.cache saveObject:p ForKey:key Timeout:5];
    
    for (int i = 0; i < 10; i++) {
        
        Person *p = [[Person alloc] init];
        p.age = i;
        
        NSString *key = [NSString stringWithFormat:@"person%d", i];
        
        [self.cache x_saveObject:p ForKey:key Timeout:5];
    }
    
}

- (void)testLock {
    
    _lock1 = [[NSRecursiveLock alloc] init];
    _lock2 = [[NSRecursiveLock alloc] init];
    
    [_lock1 lock];
    NSLog(@"lock1 lock\n");
    
    [_lock2 lock];
    NSLog(@"lock2 lock\n");
    NSLog(@"lock2 block\n");
    [_lock2 unlock];
    NSLog(@"lock2 unlock\n");
    
    [_lock1 unlock];
    NSLog(@"lock1 unlock\n");
}

- (void)testArray {
    
    NSMutableArray *list = [@[@"111", @"111",@"111",@"111",@"111",@"111",@"111",@"111"] mutableCopy];
    
    while (list.count > 0) {
        [list removeObjectAtIndex:(list.count - 1)];
    }
    
}

@end
