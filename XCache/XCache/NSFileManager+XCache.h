//
//  NSFileManager+XCache.h
//  XCache
//
//  Created by XiongZenghui on 15/9/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@interface NSFileManager (XCache)

+ (NSString *)rootFolder;

#pragma makr - Path

//判断传入的全路径是否符合六种全路径
+(void)assertPath:(NSString *)path;
+(NSMutableArray *)absoluteDirectories;
+(NSString *)absoluteDirectoryForPath:(NSString *)path;
+(NSString *)absolutePath:(NSString *)path;//帮助修正传入的路径是不存在的路径

+(NSString *)pathForApplicationSupportDirectory;
+(NSString *)pathForCachesDirectory;
+(NSString *)pathForDocumentsDirectory;
+(NSString *)pathForLibraryDirectory;
+(NSString *)pathForTemporaryDirectory;
+(NSString *)pathForMainBundleDirectory;
+(NSString *)pathForRootDirectory;

+(NSString *)pathForApplicationSupportDirectoryWithPath:(NSString *)path;
+(NSString *)pathForCachesDirectoryWithPath:(NSString *)path;
+(NSString *)pathForDocumentsDirectoryWithPath:(NSString *)path;
+(NSString *)pathForLibraryDirectoryWithPath:(NSString *)path;
+(NSString *)pathForMainBundleDirectoryWithPath:(NSString *)path;
+(NSString *)pathForPlistNamed:(NSString *)name;
+(NSString *)pathForTemporaryDirectoryWithPath:(NSString *)path;
+(NSString *)pathForRootDirectoryWithPath:(NSString *)path;

#pragma makr - 文件大小、创建、移动or重命令

+ (NSNumber *)fileSizeWithFilepath:(NSString *)filePath;

+(BOOL)createDirectoriesForFileAtPath:(NSString *)path;
+(BOOL)createDirectoriesForFileAtPath:(NSString *)path error:(NSError **)error;

+(BOOL)createDirectoriesForPath:(NSString *)path;
+(BOOL)createDirectoriesForPath:(NSString *)path error:(NSError **)error;

+(BOOL)createFileAtPath:(NSString *)path;
+(BOOL)createFileAtPath:(NSString *)path error:(NSError **)error;
+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content;
+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content error:(NSError **)error;

+(BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath;
+(BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

#pragma mark - 是否存在、是否是文件夹、是否是文件

+(BOOL)existsItemAtPath:(NSString *)path;

+(BOOL)isFileItemAtPath:(NSString *)path;
+(BOOL)isFileItemAtPath:(NSString *)path error:(NSError **)error;

+(BOOL)isDirectoryItemAtPath:(NSString *)path;
+(BOOL)isDirectoryItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 遍历目录下的子项

//遍历指定目录下的所有的子目录或子文件（需要deep遍历才有其他子文件、目录）
+(NSArray *)listDirectoriesInDirectoryAtPath:(NSString *)path;
+(NSArray *)listDirectoriesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

//遍历指定目录下的所有的文件
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path;
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

//遍历指定目录下的所有的文件，并且符合指定的扩展名
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension;
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep;

//遍历指定目录下的所有的文件，并且符合指定的前缀
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix;
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep;

//遍历指定目录下的所有的文件，并且符合指定的后缀
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix;
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep;

//遍历指定目录下的所有的项（文件、文件夹）
+(NSArray *)listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

#pragma makr - 获取文件的属性

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key;
+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;
+(NSDictionary *)attributesOfItemAtPath:(NSString *)path;
+(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 万能写入

+(BOOL)writeFileAtPath:(NSString *)path content:(id)content;
+(BOOL)writeFileAtPath:(NSString *)path content:(id)content error:(NSError **)error;

#pragma mark - 读取文件

+ (NSString *)readFileAsStringWithPath:(NSString *)path;
+ (NSString *)readFileAsStringWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

+ (NSArray *)readFileAsArrayWithPath:(NSString *)path;
+ (NSMutableArray *)readFileAsMutableArrayWithPath:(NSString *)path;

+ (NSObject *)readFileAsObjectWithPath:(NSString *)path;

+ (NSData *)readFileAsDataWithPath:(NSString *)path;
+ (NSData *)readFileAsDataWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;
+ (NSMutableData *)readFileAsMutableDataWithPath:(NSString *)path;
+ (NSMutableData *)readFileAsMutableDataWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

+ (NSDictionary *)readFileAtPathAsDictionary:(NSString *)path;
+ (NSMutableDictionary *)readFileAtPathAsMutableDictionary:(NSString *)path;

+ (UIImage *)readFileAsImageWithPath:(NSString *)path;
+ (UIImage *)readFileAsImageWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;;

+ (UIImage *)readFileAsImageViewWithPath:(NSString *)path;
+ (UIImage *)readFileAsImageViewWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

+(NSJSONSerialization *)readFileAsJSONWithPath:(NSString *)path;
+(NSJSONSerialization *)readFileAsJSONWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;



@end
