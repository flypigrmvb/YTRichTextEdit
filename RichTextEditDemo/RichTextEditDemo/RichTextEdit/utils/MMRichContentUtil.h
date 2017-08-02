//
//  MMRichContentUtil.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/24.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MMRichTitleModel;

@interface MMRichContentUtil : NSObject

// 生成HTML格式的内容
+ (NSString*)htmlContentFromRichContents:(NSArray*)richContents;
// 生成纯文本
+ (NSString*)plainContentFromRichContents:(NSArray*)richContents;
// 验证Title不为空
+ (BOOL)validateTitle:(MMRichTitleModel*)titleModel;
// 验证内容，存在图片或者文字满足要求（1-20000）
+ (BOOL)validataContentNotEmptyWithRichContents:(NSArray*)richContents;
// 验证内容没有超过限制（1-20000）
+ (BOOL)validataContentNotOverflowWithRichContents:(NSArray*)richContents;
// 验证内容是否有效，判断图片时候全部上传成功
+ (BOOL)validateImagesWithRichContents:(NSArray*)richContents;
// 获取内容中的图片
+ (NSArray*)imagesFromRichContents:(NSArray*)richContents;
// 压缩图片
+ (UIImage*)scaleImage:(UIImage*)originalImage;
// 图片本地保存路径
+ (NSString*)imageSavedLocalPath;
// 保存图片到本地
+ (NSString*)saveImageToLocal:(UIImage*)image;
// 获取图片上传失败数
+ (NSInteger)imageUploadFailedCountFromRichContents:(NSArray*)richContents;
// 获取图片数
+ (NSInteger)imageCountFromRichContents:(NSArray*)richContents;
// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content;
// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content minHeight:(float)minHeight;

@end
