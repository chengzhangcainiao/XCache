//
//  ViewController.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "ViewController.h"
//#import "NSFileManager+XCache.h"
//#import "NSMutableDictionary+XCache.h"
#import "Person.h"
#import "XCache.h"

@interface ViewController ()

@property (nonatomic, strong) XCache *cache;

@end

@implementation ViewController

- (XCache *)cache {
    if (!_cache) {
        _cache = [XCache sharedInstance];
    }
    return _cache;
}

- (void)viewDidLoad {
    [super viewDidLoad];

        
    
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
    
}

@end
