//
//  MMRichContentUtil.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/24.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMRichContentUtil : NSObject

// 生成HTML格式的内容
+ (NSString*)htmlContentFromRichContents:(NSArray*)richContents;
// 验证内容是否有效，判断图片时候全部上传成功
+ (BOOL)validateRichContents:(NSArray*)richContents;
// 压缩图片
+ (UIImage*)scaleImage:(UIImage*)originalImage;
// 保存图片到本地
+ (NSString*)saveImageToLocal:(UIImage*)image;

@end
