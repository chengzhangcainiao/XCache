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
    NSString *path = [self x_pathForRootDirectory];
    [self createDirectoriesForPath:path];
}

+ (NSString *)x_rootFolder {
    return [XCacheConfig x_rootFolderName];
}

#pragma mark - Path

+ (NSString *)x_getRootFolderPath {
    return [self x_pathForRootDirectoryWithPath:[self x_rootFolder]];
}

+(NSMutableArray *)x_absoluteDirectories
{
    static NSMutableArray *directories = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        directories = [NSMutableArray arrayWithObjects:
                       [self x_pathForApplicationSupportDirectory],
                       [self x_pathForCachesDirectory],
                       [self x_pathForDocumentsDirectory],
                       [self x_pathForLibraryDirectory],
                       [self x_pathForMainBundleDirectory],
                       [self x_pathForTemporaryDirectory],
                       nil];
        
        [directories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return (((NSString *)obj1).length > ((NSString *)obj2).length) ? 0 : 1;
            
        }];
    });
    
    return directories;
}


+(NSString *)x_absoluteDirectoryForPath:(NSString *)path
{//判断个当前传入的全路径path，是否是六种路径中的一种（appSupport、cache、document、lib、mainbundle、temp）
    
    [self x_assertPath:path];
    
    if([path isEqualToString:@"/"])
    {
        return nil;
    }
    
    NSMutableArray *directories = [self x_absoluteDirectories];
    
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


+(NSString *)x_absolutePath:(NSString *)path
{
    if (![self x_assertPath:path]) {
        return nil;
    }
    
    NSString *finalPath = nil;
    NSString *defaultDirectory = [self x_absoluteDirectoryForPath:path];
    
    if(defaultDirectory != nil){
        finalPath =  path;
    } else { //传入的全路径不符合六种路径，如果传入的路径错误，就将传入的路径改为拼接到document/
        finalPath = [self x_pathForDocumentsDirectoryWithPath:path];
    }
    
    return finalPath;
}


+(BOOL)x_assertPath:(NSString *)path
{
    if (!path || [path isEqualToString:@""]) {
        return NO;
    } else {
        return YES;
    }
}

+(NSString *)x_pathForRootDirectory {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths lastObject];
        NSString *rootFolder = [self x_rootFolder];
        path = [docPath stringByAppendingPathComponent:rootFolder];
    });
    return path;
}

+(NSString *)x_pathForApplicationSupportDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)x_pathForCachesDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)x_pathForDocumentsDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)x_pathForLibraryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        path = [paths lastObject];
    });
    
    return path;
}

+(NSString *)x_pathForTemporaryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        path = NSTemporaryDirectory();
    });
    
    return path;
}

+(NSString *)x_pathForMainBundleDirectory
{
    return [NSBundle mainBundle].resourcePath;
}


+(NSString *)x_pathForApplicationSupportDirectoryWithPath:(NSString *)path
{
    return [[self x_pathForApplicationSupportDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)x_pathForCachesDirectoryWithPath:(NSString *)path
{
    return [[self x_pathForCachesDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)x_pathForDocumentsDirectoryWithPath:(NSString *)path
{
    return [[self x_pathForDocumentsDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)x_pathForLibraryDirectoryWithPath:(NSString *)path
{
    return [[self x_pathForLibraryDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)x_pathForMainBundleDirectoryWithPath:(NSString *)path
{
    return [[self x_pathForMainBundleDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)x_pathForPlistNamed:(NSString *)name
{
    NSString *nameExtension = [name pathExtension];
    NSString *plistExtension = @"plist";
    
    if([nameExtension isEqualToString:@""])
    {
        name = [name stringByAppendingPathExtension:plistExtension];
    }
    
    return [self x_pathForMainBundleDirectoryWithPath:name];
}

+(NSString *)x_pathForTemporaryDirectoryWithPath:(NSString *)path
{
    return [[self x_pathForTemporaryDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)x_pathForRootDirectoryWithPath:(NSString *)path {
    return [[self x_pathForRootDirectory] stringByAppendingPathComponent:path];
}

#pragma mark - file size

+ (NSNumber *)x_fileSizeWithFilepath:(NSString *)filePath
{
    return [self x_attributeOfItemAtPath:filePath forKey:NSFileSize];
}

#pragma mark - attributes

+(id)x_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key {
    return [self x_attributeOfItemAtPath:path forKey:key error:nil];
}

+(id)x_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error {
    NSDictionary *attributes = [self x_attributesOfItemAtPath:path error:error];
    return [attributes objectForKey:key];
}

+(NSDictionary *)x_attributesOfItemAtPath:(NSString *)path {
    return [self x_attributesOfItemAtPath:path error:nil];
}

+(NSDictionary *)x_attributesOfItemAtPath:(NSString *)path error:(NSError **)error {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
    return attributes;
}

#pragma mark - Directory

+(BOOL)x_createDirectoriesForFileAtPath:(NSString *)path
{
    return [self x_createDirectoriesForFileAtPath:path error:nil];
}


+(BOOL)x_createDirectoriesForFileAtPath:(NSString *)path error:(NSError **)error
{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];
    
    if([pathLastChar isEqualToString:@"/"])
    {
        [NSException raise:@"Invalid path" format:@"file path can't have a trailing '/'."];
        
        return NO;
    }
    
    //得到文件前面的文件夹路径
    NSString *fileFolder = [[self x_absolutePath:path] stringByDeletingLastPathComponent];
    
    //创建文件夹
    return [self x_createDirectoriesForPath:fileFolder error:error];
}


+(BOOL)createDirectoriesForPath:(NSString *)path
{
    return [self x_createDirectoriesForPath:path error:nil];
}


+(BOOL)x_createDirectoriesForPath:(NSString *)path error:(NSError **)error
{
    BOOL flag = [[NSFileManager defaultManager] createDirectoryAtPath:[self x_absolutePath:path] withIntermediateDirectories:YES attributes:nil error:error];
    return flag;
}


#pragma mark - File

+(BOOL)x_existsItemAtPath:(NSString *)path {
    
    // 如果传入的全路径不符合六种之一，就修正为默认的document/路径
    NSString *absulotePath = [self x_absolutePath:path];
    
    return [[[self class] defaultManager] fileExistsAtPath:absulotePath];
}

+(BOOL)x_isFileItemAtPath:(NSString *)path {
    return [self x_isFileItemAtPath:path error:nil];
}

+(BOOL)x_isFileItemAtPath:(NSString *)path error:(NSError **)error {
    return ([self x_attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+(BOOL)x_isDirectoryItemAtPath:(NSString *)path
{
    return [self x_isDirectoryItemAtPath:path error:nil];
}


+(BOOL)x_isDirectoryItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self x_attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)x_createFileAtPath:(NSString *)path {
    return [self x_createFileAtPath:path error:nil];
}

+ (BOOL)x_createFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [self x_createFileAtPath:path withContent:nil error:error];
}

+ (BOOL)x_createFileAtPath:(NSString *)path withContent:(NSObject *)content {
    return [self x_createFileAtPath:path withContent:content error:nil];
}

+ (BOOL)x_createFileAtPath:(NSString *)path
               withContent:(NSObject *)content
                     error:(NSError *__autoreleasing *)error
{
    if(![self x_existsItemAtPath:path] && [self x_createDirectoriesForFileAtPath:path error:error])
    {
        //1. 创建文件
        [[NSFileManager defaultManager] createFileAtPath:[self x_absolutePath:path] contents:nil attributes:nil];
        
        //2. 将内容写入文件
        if(content != nil)
        {
            [self x_writeFileAtPath:path content:content error:error];
        }
        
        return (error == nil);
    }
    
    return NO;
}

#pragma mark - List 

#pragma mark List Directories In a Directory

+(NSArray *)x_listDirectoriesInDirectoryAtPath:(NSString *)path {
    return [self x_listDirectoriesInDirectoryAtPath:path deep:NO];
}

+(NSArray *)listDirectoriesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *subpaths = [self x_listItemsInDirectoryAtPath:path deep:deep];
    
    //过滤只剩下文件夹
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return [self x_isDirectoryItemAtPath:subpath];
    }]];
}

#pragma mark List files in a directory

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path {
    return [self x_listFilesInDirectoryAtPath:path deep:NO];
}

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *subpaths = [self x_listItemsInDirectoryAtPath:path deep:deep];
    
    //过滤只剩下文件
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return [self x_isFileItemAtPath:subpath];
    }]];
}

#pragma mark List files in a directory while file extensions same

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension {
    return [self x_listFilesInDirectoryAtPath:path withExtension:extension deep:NO];
}

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep {
    NSArray *subpaths = [self x_listFilesInDirectoryAtPath:path deep:deep];
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        
        //获取path的最后文件的扩展名，转小写
        NSString *subpathExtension = [[subpath pathExtension] lowercaseString];
        
        //获取待校验的扩展名 （@".jpeg"）
        NSString *filterExtension = [[extension lowercaseString] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        return [subpathExtension isEqualToString:filterExtension];
        
    }]];
}

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix {
    return [self x_listFilesInDirectoryAtPath:path withPrefix:prefix deep:NO];
}

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep {
    NSArray *subpaths = [self x_listFilesInDirectoryAtPath:path deep:deep];
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return ([subpath hasPrefix:prefix] || [subpath isEqualToString:prefix]);
    }]];
}

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix {
    return [self x_listFilesInDirectoryAtPath:path withSuffix:suffix deep:NO];
}

+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep {
    NSArray *subpaths = [self x_listFilesInDirectoryAtPath:path deep:deep];
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        return ([subpath hasPrefix:suffix] || [subpath isEqualToString:suffix]);
    }]];

}

+(NSArray *)x_listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSString *absolutePath = [self x_absolutePath:path];
    
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

+(BOOL)x_writeFileAtPath:(NSString *)path content:(id)content {
    return [self x_writeFileAtPath:path content:content error:nil];
}

+(BOOL)x_writeFileAtPath:(NSString *)path content:(id)content error:(NSError **)error {
    if(content == nil || [content isEqual:[NSNull null]])
    {
        [NSException raise:@"Invalid content" format:@"content can't be nil or null."];
    }
    
    [self x_createFileAtPath:path withContent:nil error:error];
    
    NSString *absolutePath = [self x_absolutePath:path];
    
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
        return [self x_writeFileAtPath:absolutePath content:((UIImageView *)content).image error:error];
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

+(BOOL)x_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [self x_moveItemAtPath:path toPath:toPath error:nil];
}

+(BOOL)x_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error {
    //1. 建立目标目录
    BOOL isCreate = [self x_createDirectoriesForFileAtPath:[self x_absolutePath:toPath] error:error];
    
    //2. 移动目录内容
    BOOL isMove = [[NSFileManager defaultManager] moveItemAtPath:[self x_absolutePath:path] toPath:[self x_absolutePath:toPath] error:error];
    return (isCreate && isMove);
}

+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path] error:nil];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path error:(NSError **)error
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path] error:error];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path withExtension:extension] error:nil];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path withExtension:extension] error:error];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path withPrefix:prefix] error:nil];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path withPrefix:prefix] error:error];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path withSuffix:suffix] error:nil];
}


+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error
{
    return [self x_removeItemsAtPaths:[self x_listFilesInDirectoryAtPath:path withSuffix:suffix] error:error];
}


+(BOOL)x_removeItemsInDirectoryAtPath:(NSString *)path
{
    return [self x_removeItemsInDirectoryAtPath:path error:nil];
}


+(BOOL)x_removeItemsInDirectoryAtPath:(NSString *)path error:(NSError **)error
{
    return [self x_removeItemsAtPaths:[self x_listItemsInDirectoryAtPath:path deep:NO] error:error];
}


+(BOOL)x_removeItemAtPath:(NSString *)path
{
    return [self x_removeItemAtPath:path error:nil];
}


+(BOOL)x_removeItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self x_absolutePath:path] error:error];
}


+(BOOL)x_removeItemsAtPaths:(NSArray *)paths
{
    return [self x_removeItemsAtPaths:paths error:nil];
}


+(BOOL)x_removeItemsAtPaths:(NSArray *)paths error:(NSError **)error
{
    BOOL success = YES;
    
    for(NSString *path in paths)
    {
        success &= [self x_removeItemAtPath:[self x_absolutePath:path] error:error];
    }
    
    return success;
}

+ (NSString *)x_readFileAsStringWithPath:(NSString *)path {
    return [self x_readFileAsStringWithPath:path Error:nil];
}

+ (NSString *)x_readFileAsStringWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error {
    return [NSString stringWithContentsOfFile:[self x_absolutePath:path] encoding:NSUTF8StringEncoding error:error];
}

+ (NSArray *)x_readFileAsArrayWithPath:(NSString *)path {
    return [NSArray arrayWithContentsOfFile:[self x_absolutePath:path]];
}

+ (NSMutableArray *)x_readFileAsMutableArrayWithPath:(NSString *)path {
    return [NSMutableArray arrayWithContentsOfFile:[self x_absolutePath:path]];
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
