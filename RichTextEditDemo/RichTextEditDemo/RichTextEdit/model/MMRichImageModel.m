//
//  MMRichImageModel.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichImageModel.h"
#import "MMRichTextConfig.h"

@interface MMRichImageModel ()
@property (nonatomic, strong) NSAttributedString* attrString;
@end

@implementation MMRichImageModel

/**
 显示图片的属性文字
 */
- (NSAttributedString*)attrStringWithContainerWidth:(NSInteger)containerWidth {
    if (!_attrString) {
        CGFloat showImageWidth = containerWidth - MMEditConfig.editAreaLeftPadding - MMEditConfig.editAreaRightPadding - MMEditConfig.imageDeltaWidth;
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        CGRect rect = CGRectZero;
        rect.size.width = showImageWidth;
        rect.size.height = showImageWidth * self.image.size.height / self.image.size.width;
        textAttachment.bounds = rect;
        textAttachment.image = self.image;
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        [attributedString insertAttributedString:attachmentString atIndex:0];
        _attrString = attributedString;
        
        // 设置Size
        CGRect tmpImageFrame = rect;
        tmpImageFrame.size.height += MMEditConfig.editAreaTopPadding + MMEditConfig.editAreaBottomPadding;
        _imageFrame = tmpImageFrame;
    }
    return _attrString;
}


- (void)setUploadProgress:(float)uploadProgress {
    _uploadProgress = uploadProgress;
    if ([_uploadDelegate respondsToSelector:@selector(uploadProgress:)]) {
        [_uploadDelegate uploadProgress:uploadProgress];
    }
}

- (void)setIsDone:(BOOL)isDone {
    _isDone = isDone;
    if ([_uploadDelegate respondsToSelector:@selector(uploadDone)]) {
        [_uploadDelegate uploadDone];
    }
}

- (void)setIsFailed:(BOOL)isFailed {
    _isFailed = isFailed;
    if ([_uploadDelegate respondsToSelector:@selector(uploadFail)]) {
        [_uploadDelegate uploadFail];
    }
}


#pragma mark - ......::::::: UploadItemCallBackProtocal :::::::......
- (void)mm_uploadProgress:(float)progress {
    self.uploadProgress = progress;
}

- (void)mm_uploadFailed {
    self.isFailed = YES;
}

- (void)mm_uploadDone:(NSString *)remoteImageUrlString {
    self.remoteImageUrlString = remoteImageUrlString;
    self.isDone = YES;
}


#pragma mark - ......::::::: UploadItemProtocal :::::::......
- (NSData*)mm_uploadData {
    return UIImageJPEGRepresentation(_image, 0.6);
}

- (NSURL*)mm_uploadFileURL {
    return nil;
}

@end
