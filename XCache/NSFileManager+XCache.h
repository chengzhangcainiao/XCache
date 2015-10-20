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

+ (NSString *)x_rootFolder;

#pragma makr - Path

//判断传入的全路径是系统中的六种路径（document、library、cache、temp、appsuport、mainBundle）下的子路径
+(BOOL)x_assertPath:(NSString *)path;
+(NSMutableArray *)x_absoluteDirectories;
+(NSString *)x_absoluteDirectoryForPath:(NSString *)path;
+(NSString *)x_absolutePath:(NSString *)path;//帮助修正传入的路径是不存在的路径

+(NSString *)x_pathForApplicationSupportDirectory;
+(NSString *)x_pathForCachesDirectory;
+(NSString *)x_pathForDocumentsDirectory;
+(NSString *)x_pathForLibraryDirectory;
+(NSString *)x_pathForTemporaryDirectory;
+(NSString *)x_pathForMainBundleDirectory;
+(NSString *)x_pathForRootDirectory;

+(NSString *)x_pathForApplicationSupportDirectoryWithPath:(NSString *)path;
+(NSString *)x_pathForCachesDirectoryWithPath:(NSString *)path;
+(NSString *)x_pathForDocumentsDirectoryWithPath:(NSString *)path;
+(NSString *)x_pathForLibraryDirectoryWithPath:(NSString *)path;
+(NSString *)x_pathForMainBundleDirectoryWithPath:(NSString *)path;
+(NSString *)x_pathForPlistNamed:(NSString *)name;
+(NSString *)x_pathForTemporaryDirectoryWithPath:(NSString *)path;
+(NSString *)x_pathForRootDirectoryWithPath:(NSString *)path;

#pragma makr - 文件大小、创建、移动or重命令

+ (NSNumber *)x_fileSizeWithFilepath:(NSString *)filePath;

+(BOOL)x_createDirectoriesForFileAtPath:(NSString *)path;
+(BOOL)x_createDirectoriesForFileAtPath:(NSString *)path error:(NSError **)error;

+(BOOL)x_createDirectoriesForPath:(NSString *)path;
+(BOOL)x_createDirectoriesForPath:(NSString *)path error:(NSError **)error;

+(BOOL)x_createFileAtPath:(NSString *)path;
+(BOOL)x_createFileAtPath:(NSString *)path error:(NSError **)error;
+(BOOL)x_createFileAtPath:(NSString *)path withContent:(NSObject *)content;
+(BOOL)x_createFileAtPath:(NSString *)path withContent:(NSObject *)content error:(NSError **)error;

#pragma mark - 移动

+(BOOL)x_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath;
+(BOOL)x_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

#pragma mark - 删除

//直接删除目录下的所有文件
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path;
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path error:(NSError **)error;

//直接删除目录下的文件扩展名对应的文件
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension;
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error;

//直接删除目录下的文件名前缀对应的文件
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix;
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error;

//直接删除目录下的文件名后缀对应的文件
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix;
+(BOOL)x_removeFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error;

//直接删除目录下的文件or文件夹
+(BOOL)x_removeItemsInDirectoryAtPath:(NSString *)path;
+(BOOL)x_removeItemsInDirectoryAtPath:(NSString *)path error:(NSError **)error;

//直接删除目录下某个项
+(BOOL)x_removeItemAtPath:(NSString *)path;
+(BOOL)x_removeItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 是否存在、是否是文件夹、是否是文件

+(BOOL)x_existsItemAtPath:(NSString *)path;

+(BOOL)x_isFileItemAtPath:(NSString *)path;
+(BOOL)x_isFileItemAtPath:(NSString *)path error:(NSError **)error;

+(BOOL)x_isDirectoryItemAtPath:(NSString *)path;
+(BOOL)x_isDirectoryItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 遍历目录下的子项

//遍历指定目录下的所有的子目录或子文件（需要deep遍历才有其他子文件、目录）
+(NSArray *)x_listDirectoriesInDirectoryAtPath:(NSString *)path;
+(NSArray *)x_listDirectoriesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

//遍历指定目录下的所有的文件
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path;
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

//遍历指定目录下的所有的文件，并且符合指定的扩展名
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension;
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep;

//遍历指定目录下的所有的文件，并且符合指定的前缀
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix;
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep;

//遍历指定目录下的所有的文件，并且符合指定的后缀
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix;
+(NSArray *)x_listFilesInDirectoryAtPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep;

//遍历指定目录下的所有的项（文件、文件夹）
+(NSArray *)x_listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

#pragma makr - 获取文件的属性

+(id)x_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key;
+(id)x_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;
+(NSDictionary *)x_attributesOfItemAtPath:(NSString *)path;
+(NSDictionary *)x_attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 万能写入

+(BOOL)x_writeFileAtPath:(NSString *)path content:(id)content;
+(BOOL)x_writeFileAtPath:(NSString *)path content:(id)content error:(NSError **)error;

#pragma mark - 读取文件

+ (NSString *)x_readFileAsStringWithPath:(NSString *)path;
+ (NSString *)x_readFileAsStringWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

+ (NSArray *)x_readFileAsArrayWithPath:(NSString *)path;
+ (NSMutableArray *)x_readFileAsMutableArrayWithPath:(NSString *)path;

+ (NSObject *)x_readFileAsObjectWithPath:(NSString *)path;

+ (NSData *)x_readFileAsDataWithPath:(NSString *)path;
+ (NSData *)x_readFileAsDataWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;
+ (NSMutableData *)readFileAsMutableDataWithPath:(NSString *)path;
+ (NSMutableData *)readFileAsMutableDataWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

+ (NSDictionary *)x_readFileAtPathAsDictionary:(NSString *)path;
+ (NSMutableDictionary *)x_readFileAtPathAsMutableDictionary:(NSString *)path;

+ (UIImage *)x_readFileAsImageWithPath:(NSString *)path;
+ (UIImage *)x_readFileAsImageWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;;

+ (UIImage *)x_readFileAsImageViewWithPath:(NSString *)path;
+ (UIImage *)x_readFileAsImageViewWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;

+(NSJSONSerialization *)x_readFileAsJSONWithPath:(NSString *)path;
+(NSJSONSerialization *)x_readFileAsJSONWithPath:(NSString *)path Error:(NSError *__autoreleasing*)error;



@end
