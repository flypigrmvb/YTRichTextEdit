//
//  MMRichImageModel.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMFileUploadUtil.h"
#import "MMBaseRichContentModel.h"
#import <YYModel.h>

@protocol MMRichImageUploadDelegate <NSObject>

// 上传进度回调
- (void)uploadProgress:(float)progress;
// 上传失败回调
- (void)uploadFail;
// 上传完成回调
- (void)uploadDone;;

@end


@interface MMRichImageModel : MMBaseRichContentModel <UploadItemProtocal, UploadItemCallBackProtocal, YYModel>

@property (nonatomic, strong) UIImage* image;///<图片
@property (nonatomic, copy) NSString* localImageName;///<本地保存的名称
@property (nonatomic, copy) NSString* remoteImageUrlString;///<上传完成之后的远程路径
@property (nonatomic, assign) CGFloat imageContentHeight;///<Frame
@property (nonatomic, assign, readonly) CGRect imageFrame;

// 上传处理
@property (nonatomic, assign) float uploadProgress;
@property (nonatomic, assign) BOOL isFailed;
@property (nonatomic, assign) BOOL isDone;
@property (nonatomic, weak) id<MMRichImageUploadDelegate> uploadDelegate;///<上传回调

/**
 显示图片的属性文字
 */
- (NSAttributedString*)attrStringWithContainerWidth:(NSInteger)containerWidth;

@end
