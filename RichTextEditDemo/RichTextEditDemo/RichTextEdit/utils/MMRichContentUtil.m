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
#import "MMRichTitleModel.h"
#import "UIImage+Util.h"
#import "UtilMacro.h"
#import "MMTextView.h"
#import "MMRichTextConfig.h"

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
            NSString* htmlText = [textContent.textContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
            [htmlContent appendString:@"<div>"];
            [htmlContent appendString:htmlText];
            [htmlContent appendString:@"</div>"];
        }
    }
    
    return htmlContent;
}

+ (NSString*)plainContentFromRichContents:(NSArray*)richContents {
    NSMutableString *plainContent = [NSMutableString string];
    
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichTextModel class]]) {
            MMRichTextModel* textContent = (MMRichTextModel*)content;
            [plainContent appendString:textContent.textContent];
        }
    }
    
    return plainContent;
}

// 验证Title不为空
+ (BOOL)validateTitle:(MMRichTitleModel*)titleModel {
    NSInteger textCount = [titleModel.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
    return textCount > 0;
}

// 验证内容，存在图片或者文字满足要求（1-20000）
+ (BOOL)validataContentNotEmptyWithRichContents:(NSArray*)richContents {
    NSInteger textCount = 0;
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            return YES;
        } else if ([content isKindOfClass:[MMRichTextModel class]]) {
            MMRichTextModel* textContent = (MMRichTextModel*)content;
            textCount += [textContent.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
            if (textCount > 0) {
                return YES;
            }
        }
    }
    return NO;
}

// 验证内容没有超过限制（1-20000）
+ (BOOL)validataContentNotOverflowWithRichContents:(NSArray*)richContents {
    NSInteger textCount = 0;
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichTextModel class]]) {
            MMRichTextModel* textContent = (MMRichTextModel*)content;
            textCount += textContent.textContent.length;
            if (textCount > MMEditConfig.maxTextContentCount) {
                return NO;
            }
        }
    }
    return YES;
}

+ (BOOL)validateImagesWithRichContents:(NSArray*)richContents {
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            if (imgContent.isFailed == YES) {
                return NO;
            }
        }
    }
    return YES;
}

+ (BOOL)validateImagesIsUploadIngWithRichContents:(NSArray*)richContents {
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            if (imgContent.isDone == NO && imgContent.isFailed == NO) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSArray*)imagesFromRichContents:(NSArray*)richContents {
    NSMutableArray* images = [NSMutableArray array];
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            NSDictionary* imgDict
            = @{
                @"image" : ValueOrEmpty(imgContent.remoteImageUrlString),
                @"imageWidth" : @(imgContent.image.size.width),
                @"imageHeight" : @(imgContent.image.size.height),
                };
            [images addObject:imgDict];
        }
    }
    return images;
}

+ (UIImage*)scaleImage:(UIImage*)originalImage {
    float scaledWidth = 800;
    return [originalImage scaletoSize:scaledWidth];
}

// 图片本地保存路径
+ (NSString*)imageSavedLocalPath {
    NSString *path=[self createDirectory:kRichContentEditCache];
    return path;
}

+ (NSString*)saveImageToLocal:(UIImage*)image {
    NSString* path = [self.class imageSavedLocalPath];
    NSString* savedName = [self.class genRandomFileName];
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    NSString *fileSavedPath = [path stringByAppendingPathComponent:savedName];
    BOOL result = [data writeToFile:fileSavedPath atomically:YES];
    if (result) {
        return savedName;
    }
    return nil;
}

// 获取图片上传失败数
+ (NSInteger)imageUploadFailedCountFromRichContents:(NSArray*)richContents {
    NSInteger count = 0;
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            if (imgContent.isFailed) count++ ;
        }
    }
    return count;
}

// 获取图片数
+ (NSInteger)imageCountFromRichContents:(NSArray*)richContents {
    NSInteger count = 0;
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            count++ ;
        }
    }
    return count;
}

// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content {
    return [self computeHeightInTextVIewWithContent:content minHeight:0];
}

// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content minHeight:(float)minHeight {
    UITextView* textView = nil;
    if ([content isKindOfClass:[NSString class]]) {
        textView = [self computePlainTextView];
        textView.text = (NSString*)content;
    } else if ([content isKindOfClass:[NSAttributedString class]]) {
        textView = [self computeAttrTextView];
        textView.attributedText = (NSAttributedString*)content;
    }
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    textView.text = nil;
    textView.attributedText = nil;
    
    return MAX(size.height, minHeight);
}

// 是否需要显示placeholder
+ (BOOL)shouldShowPlaceHolderFromRichContents:(NSArray*)richContents {
    if (richContents.count == 1) {
        id content = richContents.firstObject;
        if ([content isKindOfClass:[MMRichTextModel class]]) {
            MMRichTextModel* textContent = (MMRichTextModel*)content;
            if (textContent.textContent.length <= 0 || [textContent.textContent isEqualToString:@"\n"]) {
                return YES;
            }
        }
    }
    return NO;
}


#pragma mark - ......::::::: helper :::::::......

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

// 随机文件名
+ (NSString*)genRandomFileName {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    uint32_t random = arc4random_uniform(10000);
    return [NSString stringWithFormat:@"%@-%@.png", @(timeStamp), @(random)];
}

+ (MMTextView *)computePlainTextView {
    static MMTextView* __mm_computePlainTextView;
    if (!__mm_computePlainTextView) {
        __mm_computePlainTextView = [[MMTextView alloc] init];
        __mm_computePlainTextView.font = MMEditConfig.defaultEditContentFont;
        __mm_computePlainTextView.textContainerInset = UIEdgeInsetsMake(MMEditConfig.editAreaTopPadding, MMEditConfig.editAreaLeftPadding, MMEditConfig.editAreaBottomPadding, MMEditConfig.editAreaRightPadding);
        __mm_computePlainTextView.scrollEnabled = NO;
        __mm_computePlainTextView.frame = CGRectMake(0, 0, kScreenWidth, 100000);
    }
    return __mm_computePlainTextView;
}

+ (MMTextView *)computeAttrTextView {
    static MMTextView* __mm_computeAttrTextView;
    if (!__mm_computeAttrTextView) {
        __mm_computeAttrTextView = [[MMTextView alloc] init];
        __mm_computeAttrTextView.font = MMEditConfig.defaultEditContentFont;
        __mm_computeAttrTextView.textContainerInset = UIEdgeInsetsMake(MMEditConfig.editAreaTopPadding, MMEditConfig.editAreaLeftPadding, MMEditConfig.editAreaBottomPadding, MMEditConfig.editAreaRightPadding);
        __mm_computeAttrTextView.scrollEnabled = NO;
        __mm_computeAttrTextView.frame = CGRectMake(0, 0, kScreenWidth, 100000);
    }
    return __mm_computeAttrTextView;
}

@end
