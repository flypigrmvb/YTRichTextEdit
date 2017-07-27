//
//  MMRichContentUtil.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/24.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichContentUtil.h"
#import "MMRichImageModel.h"
#import "MMRichTextModel.h"
#import "UIImage+Util.h"
#import "UtilMacro.h"


#define kRichContentEditCache      @"RichContentEditCache"


@implementation MMRichContentUtil

+ (NSString*)htmlContentFromRichContents:(NSArray*)richContents {
    NSMutableString *htmlContent = [NSMutableString string];

    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            [htmlContent appendString:[NSString stringWithFormat:@"<img src=\"%@\" width=\"%@\" height=\"%@\" />", imgContent.remoteImageUrlString, @(imgContent.image.size.width), @(imgContent.image.size.height)]];
        } else if ([content isKindOfClass:[MMRichTextModel class]]) {
            MMRichTextModel* textContent = (MMRichTextModel*)content;
            [htmlContent appendString:textContent.textContent];
        }
        
        // 添加换行
        if (i != richContents.count - 1) {
            [htmlContent appendString:@"<br />"];
        }
    }
    
    return htmlContent;
}

+ (BOOL)validateRichContents:(NSArray*)richContents {
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            if (imgContent.isDone == NO) {
                return NO;
            }
        }
    }
    return YES;
}

+ (UIImage*)scaleImage:(UIImage*)originalImage {
    float scaledWidth = 1242;
    return [originalImage scaletoSize:scaledWidth];
}

+ (NSString*)saveImageToLocal:(UIImage*)image {
    NSString *path=[self createDirectory:kRichContentEditCache];
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    NSString *filePath = [path stringByAppendingPathComponent:[self.class genRandomFileName]];
    [data writeToFile:filePath atomically:YES];
    return filePath;
}

// 创建文件夹
+ (NSString *)createDirectory:(NSString *)path {
    BOOL isDir = NO;
    NSString *finalPath = [CACHE_PATH stringByAppendingPathComponent:path];
    
    if (!([[NSFileManager defaultManager] fileExistsAtPath:finalPath
                                               isDirectory:&isDir]
          && isDir))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:finalPath
                                 withIntermediateDirectories :YES
                                                  attributes :nil
                                                       error :nil];
    }
    
    return finalPath;
}

+ (NSString*)genRandomFileName {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    uint32_t random = arc4random_uniform(10000);
    return [NSString stringWithFormat:@"%@-%@.png", @(timeStamp), @(random)];
}

@end
