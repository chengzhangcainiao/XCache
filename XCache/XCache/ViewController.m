//
//  ViewController.m
//  XCache
//
//  Created by XiongZenghui on 15/9/25.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "ViewController.h"
#import "NSFileManager+XCache.h"
#import "NSMutableDictionary+XCache.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *path = [NSFileManager pathForRootDirectoryWithPath:@"ccc"];
//    NSString *path = @"/dawd/dawdaw/ccc";//默认在document/dawd/dawdaw/ccc
//    [NSFileManager createFileAtPath:path withContent:@"dawdawd"];
    
    
//    NSString *path = @"/A";
//    NSArray *arrays = [NSFileManager listItemsInDirectoryAtPath:path deep:NO];
//    [NSFileManager moveItemAtPath:@"/A" toPath:@"/XXX" error:nil];
   
//    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary] ;
//
//        Person *p = [[Person alloc] init];
//        p.name = @"123";
//        
//        [dict setObject:p forKey:@"person"];
//        
//        
//        NSString *filePath = [[NSFileManager pathForCachesDirectory] stringByAppendingPathComponent:@"test.plist"];
//        
//        [NSKeyedArchiver archiveRootObject:dict toFile:filePath];
//    }
    
}

@end
