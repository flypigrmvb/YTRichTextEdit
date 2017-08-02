//
//  MMRichImageModel.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichImageModel.h"
#import "MMRichTextConfig.h"
#import "MMRichContentUtil.h"

@interface MMRichImageModel ()
@property (nonatomic, strong) NSAttributedString* attrString;
@end

@implementation MMRichImageModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.richContentType = MMRichContentTypeImage;
    }
    return self;
}

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist {
    return @[@"localImageName", @"remoteImageUrlString", @"imageContentHeight", @"uploadProgress", @"isFailed", @"isDone", @"richContentType"];
}

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
        
        // 设置Height
        if (_imageContentHeight <= 0) {
            _imageContentHeight = MAX(rect.size.height + MMEditConfig.editAreaTopPadding + MMEditConfig.editAreaBottomPadding, MMEditConfig.minImageContentCellHeight);
        }
    }
    return _attrString;
}

- (UIImage *)image {
    if (!_image) {
        _image = [UIImage imageWithContentsOfFile:[[MMRichContentUtil imageSavedLocalPath] stringByAppendingPathComponent:self.localImageName]];
    }
    return _image;
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
    return UIImageJPEGRepresentation(_image, 0.5);
}

- (NSURL*)mm_uploadFileURL {
    return nil;
}

@end
