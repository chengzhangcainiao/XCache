//
//  NSFileManager+XCache.m
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "NSFileManager+XCache.h"
#import "XCacheConfig.h"
#import <sys/xattr.h>

@implementation NSFileManager (XCache)

+ (void)initialize {
    NSString *path = [self pathForRootDirectory];
    [self createDirectoriesForPath:path];
}

+ (NSString *)rootFolder {
    return [XCacheConfig rootFolderName];
}

#pragma mark - Path

+ (NSString *)getRootFolderPath {
    return [self pathForRootDirectoryWithPath:[self rootFolder]];
}

+(NSMutableArray *)absoluteDirectories
{
    static NSMutableArray *directories = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        directories = [NSMutableArray arrayWithObjects:
                       [self pathForApplicationSupportDirectory],
                       [self pathForCachesDirectory],
                       [self pathForDocumentsDirectory],
                       [self pathForLibraryDirectory],
                       [self pathForMainBundleDirectory],
                       [self pathForTemporaryDirectory],
                       nil];
        
        [directories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return (((NSString *)obj1).length > ((NSString *)obj2).length) ? 0 : 1;
            
        }];
    });
    
    return directories;
}


+(NSString *)absoluteDirectoryForPath:(NSString *)path
{//判断个当前传入的全路径path，是否是六种路径中的一种（appSupport、cache、document、lib、mainbundle、temp）
    
    [self assertPath:path];
    
    if([path isEqualToString:@"/"])
    {
        return nil;
    }
    
    NSMutableArray *directories = [self absoluteDirectories];
    
    for(NSString *directory in directories)
    {
        NSRange indexOfDirectoryInPath = [path rangeOfString:directory];
    
        if(indexOfDirectoryInPath.location == 0)
        {
            return directory;
        }
    }
    
    return nil;
}


+(NSString *)absolutePath:(NSString *)path
{
    if (![self assertPath:path]) {
        return nil;
    }
    
    NSString *finalPath = nil;
    NSString *defaultDirectory = [self absoluteDirectoryForPath:path];
    
    if(defaultDirectory != nil){
        finalPath =  path;
    } else { //传入的全路径不符合六种路径，如果传入的路径错误，就将传入的路径改为拼接到document/
        finalPath = [self pathForDocumentsDirectoryWithPath:path];
    }
    
    return finalPath;
}


+(BOOL)assertPath:(NSString *)path
{
    if (!path || [path isEqualToString:@""]) {
        return NO;
    } else {
        return YES;
    }
}

+(NSString *)pathForRootDirectory {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths lastObject];
        NSString *rootFolder = [self rootFolder];
        path = [docPath stringByAppendingPathComponent:rootFolder];
    });
    return path;
}

+(NSString *)pathForApplicationSupportDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)pathForCachesDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)pathForDocumentsDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)pathForLibraryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)pathForTemporaryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        path = NSTemporaryDirectory();
    });
    
    return path;
}

+(NSString *)pathForMainBundleDirectory
{
    return [NSBundle mainBundle].resourcePath;
}


+(NSString *)pathForApplicationSupportDirectoryWithPath:(NSString *)path
{
    return [[self pathForApplicationSupportDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForCachesDirectoryWithPath:(NSString *)path
{
    return [[self pathForCachesDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)pathForDocumentsDirectoryWithPath:(NSString *)path
{
    return [[self pathForDocumentsDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)pathForLibraryDirectoryWithPath:(NSString *)path
{
    return [[self pathForLibraryDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)pathForMainBundleDirectoryWithPath:(NSString *)path
{
    return [[self pathForMainBundleDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForPlistNamed:(NSString *)name
{
    NSString *nameExtension = [name pathExtension];
    NSString *plistExtension = @"plist";
    
    if([nameExtension isEqualToString:@""])
    {
        name = [name stringByAppendingPathExtension:plistExtension];
    }
    
    return [self pathForMainBundleDirectoryWithPath:name];
}

+(NSString *)pathForTemporaryDirectoryWithPath:(NSString *)path
{
    return [[self pathForTemporaryDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)pathForRootDirectoryWithPath:(NSString *)path {
    return [[self pathForRootDirectory] stringByAppendingPathComponent:path];
}

#pragma mark - file size

+ (NSNumber *)fileSizeWithFilepath:(NSString *)filePath
{
    return [self attributeOfItemAtPath:filePath forKey:NSFileSize];
}

#pragma mark - attributes

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key {
    return [self attributeOfItemAtPath:path forKey:key error:nil];
}

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error {
    NSDictionary *attributes = [self attributesOfItemAtPath:path error:error];
    return [attributes objectForKey:key];
}

+(NSDictionary *)attributesOfItemAtPath:(NSString *)path {
    return [self attributesOfItemAtPath:path error:nil];
}

+(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
    return attributes;
}

#pragma mark - Directory

+(BOOL)createDirectoriesForFileAtPath:(NSString *)path
{
    return [self createDirectoriesForFileAtPath:path error:nil];
}


+(BOOL)createDirectoriesForFileAtPath:(NSString *)path error:(NSError **)error
{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];
    
    if([pathLastChar isEqualToString:@"/"])
    {
        [NSException raise:@"Invalid path" format:@"file path can't have a trailing '/'."];
        
        return NO;
    }
    
    //得到文件前面的文件夹路径
    NSString *fileFolder = [[self absolutePath:path] stringByDeletingLastPathComponent];
    
    //创建文件夹
    return [self createDirectoriesForPath:fileFolder error:error];
}


+(BOOL)createDirectoriesForPath:(NSString *)path
{
    return [self createDirectoriesForPath:path error:nil];
}


+(BOOL)createDirectoriesForPath:(NSString *)path error:(NSError **)error
{
    BOOL flag = [[NSFileManager defaultManager] createDirectoryAtPath:[self absolutePath:path] withIntermediateDirectories:YES attributes:nil error:error];
    return flag;
}


#pragma mark - File

+(BOOL)existsItemAtPath:(NSString *)path {
    
    // 如果传入的全路径不符合六种之一，就修正为默认的document/路径
    NSString *absulotePath = [self absolutePath:path];
    
    return [[[self class] defaultManager] fileExistsAtPath:absulotePath];
}

+(BOOL)isFileItemAtPath:(NSString *)path {
    return [self isFileItemAtPath:path error:nil];
}

+(BOOL)isFileItemAtPath:(NSString *)path error:(NSError **)error {
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+(BOOL)isDirectoryItemAtPath:(NSString *)path
{
    return [self isDirectoryItemAtPath:path error:nil];
}


+(BOOL)isDirectoryItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)createFileAtPath:(NSString *)path {
    return [self createFileAtPath:path error:nil];
}

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [self createFileAtPath:path withContent:nil error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content {
    return [self createFileAtPath:path withContent:content error:nil];
}

+ (BOOL)createFileAtPath:(NSString *)path
             withContent:(NSObject *)content
                   error:(NSError *__autoreleasing *)error
{
    if(![self existsItemAtPath:path] && [self createDirectoriesForFileAtPath:path error:error])
    {
        //1. 创建文件
        [[NSFileManager defaultManager] createFileAtPath:[self absolutePath:path] contents:nil attributes:nil];
        
        //2. 将内容写入文件
        if(content != nil)
        {
            [self writeFileAtPath:path content:content error:error];
        }
        
        return (error == nil);
    }
    
    return NO;
}

#pragma mark - List 

#pragma mark List Directories In a Directory

+(NSArray *)listDirectoriesInDirectoryAtPath:(NSString *)path {
    return [self listDirectoriesInDirectoryAtPath:path deep:NO];
}

+(NSArray *)listDirectoriesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *subpaths = [self listItemsInDirectoryAtPath:path deep:deep];
    
    //过滤只剩下文件夹
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return [self isDirectoryItemAtPath:subpath];
    }]];
}

#pragma mark List files in a directory

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path {
    return [self listFilesInDirectoryAtPath:path deep:NO];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *subpaths = [self listItemsInDirectoryAtPath:path deep:deep];
    
    //过滤只剩下文件
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return [self isFileItemAtPath:subpath];
    }]];
}

#pragma mark List files in a directory while file extensions same

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension {
    return [self listFilesInDirectoryAtPath:path withExtension:extension deep:NO];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep {
    NSArray *subpaths = [self listFilesInDirectoryAtPath:path deep:deep];
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        
        //获取path的最后文件的扩展名，转小写
        NSString *subpathExtension = [[subpath pathExtension] lowercaseString];
        
        //获取待校验的扩展名 （@".jpeg"）
        NSString *filterExtension = [[extension lowercaseString] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        return [subpathExtension isEqualToString:filterExtension];
        
    }]];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix {
    return [self listFilesInDirectoryAtPath:path withPrefix:prefix deep:NO];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep {
    NSArray *subpaths = [self listFilesInDirectoryAtPath:path deep:deep];
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return ([subpath hasPrefix:prefix] || [subpath isEqualToString:prefix]);
    }]];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix {
    return [self listFilesInDirectoryAtPath:path withSuffix:suffix deep:NO];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep {
    NSArray *subpaths = [self listFilesInDirectoryAtPath:path deep:deep];
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return ([subpath hasPrefix:suffix] || [subpath isEqualToString:suffix]);
    }]];

}

+(NSArray *)listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSString *absolutePath = [self absolutePath:path];
    
    //遍历得到当前文件夹下的所有子文件夹or子文件的名字
    NSArray *relativeSubpaths = (deep ? [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:absolutePath error:nil] : [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:nil]);
    
    NSMutableArray *absoluteSubpaths = [[NSMutableArray alloc] init];
    
    for(NSString *relativeSubpath in relativeSubpaths)
    {
        //给当前子目录or子文件，添加完整的全路径
        NSString *absoluteSubpath = [absolutePath stringByAppendingPathComponent:relativeSubpath];
        [absoluteSubpaths addObject:absoluteSubpath];
    }
    
    return [NSArray arrayWithArray:absoluteSubpaths];
}

#pragma mark - Write

+(BOOL)writeFileAtPath:(NSString *)path content:(id)content {
    return [self writeFileAtPath:path content:content error:nil];
}

+(BOOL)writeFileAtPath:(NSString *)path content:(id)content error:(NSError **)error {
    if(content == nil || [content isEqual:[NSNull null]])
    {
        [NSException raise:@"Invalid content" format:@"content can't be nil or null."];
    }
    
    [self createFileAtPath:path withContent:nil error:error];
    
    NSString *absolutePath = [self absolutePath:path];
    
    if([content isKindOfClass:[NSMutableArray class]])
    {
        [((NSMutableArray *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSArray class]])
    {
        [((NSArray *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableData class]])
    {
        [((NSMutableData *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSData class]])
    {
        [((NSData *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSDictionary class]])
    {
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSJSONSerialization class]])
    {
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[UIImage class]])
    {
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[UIImageView class]])
    {
        return [self writeFileAtPath:absolutePath content:((UIImageView *)content).image error:error];
    }
    else if([content conformsToProtocol:@protocol(NSCoding)])
    {
        [NSKeyedArchiver archiveRootObject:content toFile:absolutePath];
    }
    else {
        [NSException raise:@"Invalid content type" format:@"content of type %@ is not handled.", NSStringFromClass([content class])];
        
        return NO;
    }
    
    return YES;
}

+(BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [self moveItemAtPath:path toPath:toPath error:nil];
}

+(BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error {
    //1. 建立目标目录
    BOOL isCreate = [self createDirectoriesForFileAtPath:[self absolutePath:toPath] error:error];
    
    //2. 移动目录内容
    BOOL isMove = [[NSFileManager defaultManager] moveItemAtPath:[self absolutePath:path] toPath:[self absolutePath:toPath] error:error];
    return (isCreate && isMove);
}

+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path] error:nil];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path] error:error];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path withExtension:extension] error:nil];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path withExtension:extension] error:error];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path withPrefix:prefix] error:nil];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path withPrefix:prefix] error:error];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path withSuffix:suffix] error:nil];
}


+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path withSuffix:suffix] error:error];
}


+(BOOL)removeItemsInDirectoryAtPath:(NSString *)path
{
    return [self removeItemsInDirectoryAtPath:path error:nil];
}


+(BOOL)removeItemsInDirectoryAtPath:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listItemsInDirectoryAtPath:path deep:NO] error:error];
}


+(BOOL)removeItemAtPath:(NSString *)path
{
    return [self removeItemAtPath:path error:nil];
}


+(BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self absolutePath:path] error:error];
}


+(BOOL)removeItemsAtPaths:(NSArray *)paths
{
    return [self removeItemsAtPaths:paths error:nil];
}


+(BOOL)removeItemsAtPaths:(NSArray *)paths error:(NSError **)error
{
    BOOL success = YES;
    
    for(NSString *path in paths)
    {
        success &= [self removeItemAtPath:[self absolutePath:path] error:error];
    }
    
    return success;
}

+ (NSString *)readFileAsStringWithPath:(NSString *)path {
    return [self readFileAsStringWithPath:path Error:nil];
}

+ (NSString *)readFileAsStringWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error {
    return [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:error];
}

+ (NSArray *)readFileAsArrayWithPath:(NSString *)path {
    return [NSArray arrayWithContentsOfFile:[self absolutePath:path]];
}

+ (NSMutableArray *)readFileAsMutableArrayWithPath:(NSString *)path {
    return [NSMutableArray arrayWithContentsOfFile:[self absolutePath:path]];
}

//+ (NSObject *)readFileAsObjectWithPath:(NSString *)path;
//
//+ (NSData *)readFileAsDataWithPath:(NSString *)path;
//+ (NSData *)readFileAsDataWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;
//+ (NSMutableData *)readFileAsMutableDataWithPath:(NSString *)path;
//+ (NSMutableData *)readFileAsMutableDataWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;
//
//+ (NSDictionary *)readFileAtPathAsDictionary:(NSString *)path;
//+ (NSMutableDictionary *)readFileAtPathAsMutableDictionary:(NSString *)path;
//
//+ (UIImage *)readFileAsImageWithPath:(NSString *)path;
//+ (UIImage *)readFileAsImageWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;;
//
//+ (UIImage *)readFileAsImageViewWithPath:(NSString *)path;
//+ (UIImage *)readFileAsImageViewWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;
//
//+(NSJSONSerialization *)readFileAsJSONWithPath:(NSString *)path;
//+(NSJSONSerialization *)readFileAsJSONWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

@end
