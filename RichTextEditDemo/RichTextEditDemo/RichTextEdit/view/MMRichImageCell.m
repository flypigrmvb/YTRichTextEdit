//
//  MMRichImageCell.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichImageCell.h"
#import <Masonry.h>
#import "UtilMacro.h"
#import "MMRichImageModel.h"
#import "MMRichTextConfig.h"
#import "MMTextView.h"

@interface MMRichImageCell () <MMTextViewDelegate, UITextViewDelegate, MMRichImageUploadDelegate>
@property (nonatomic, strong) MMTextView* textView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) MMRichImageModel* imageModel;
@end


@implementation MMRichImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.textView];
    [self addSubview:self.progressView];
    [self addSubview:self.reloadButton];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self).priority(900);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(MMEditConfig.editAreaLeftPadding + MMEditConfig.imageDeltaWidth/2);
        make.right.equalTo(self).offset(-(MMEditConfig.editAreaRightPadding + MMEditConfig.imageDeltaWidth/2));
        make.top.equalTo(self).offset(MMEditConfig.editAreaTopPadding);
        make.height.equalTo(@(4));
    }];
    [self.reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(convertLength(60)));
        make.center.equalTo(self);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)updateWithData:(id)data {
    if ([data isKindOfClass:[MMRichImageModel class]]) {
        MMRichImageModel* imageModel = (MMRichImageModel*)data;
        // 设置旧的数据delegate为nil
        _imageModel.uploadDelegate = nil;
        _imageModel = imageModel;
        // 设置新的数据delegate
        _imageModel.uploadDelegate = self;

        CGFloat width = [MMRichTextConfig sharedInstance].editAreaWidth;
        NSAttributedString* imgAttrStr = [_imageModel attrStringWithContainerWidth:width];
        _textView.attributedText = imgAttrStr;
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(imageModel.imageFrame.size.height));
        }];
        
        self.reloadButton.hidden = YES;
        
        // 根据上传的状态设置图片信息
        if (_imageModel.isDone) {
            self.progressView.hidden = NO;
            self.progressView.progress = _imageModel.uploadProgress;
            self.reloadButton.hidden = YES;
        }
        if (_imageModel.isFailed) {
            self.progressView.hidden = NO;
            self.progressView.progress = _imageModel.uploadProgress;
            self.reloadButton.hidden = NO;
        }
        if (_imageModel.uploadProgress > 0) {
            self.progressView.hidden = NO;
            self.progressView.progress = _imageModel.uploadProgress;
            self.reloadButton.hidden = YES;
        }
    }
}

- (void)beginEditing {
    [_textView becomeFirstResponder];
}

- (void)getPreFlag:(BOOL*)isPre postFlag:(BOOL*)isPost {
    NSRange selRange = self.textView.selectedRange;
    
    // 设置标记值
    if (isPre) {
        if (selRange.location == 0) {
            *isPre = YES;
        } else {
            *isPre = NO;
        }
    }
    
    if (isPost) {
        if (selRange.location+selRange.length == _textView.text.length) {
            *isPost = YES;
        } else {
            *isPost = NO;
        }
    }
}


#pragma mark - ......::::::: lazy load :::::::......

- (MMTextView *)textView {
    if (!_textView) {
        _textView = [MMTextView new];
        _textView.font = MMEditConfig.defaultEditContentFont;
        _textView.textContainerInset = UIEdgeInsetsMake(MMEditConfig.editAreaTopPadding, MMEditConfig.editAreaLeftPadding, MMEditConfig.editAreaBottomPadding, MMEditConfig.editAreaRightPadding);
        _textView.scrollEnabled = NO;
        _textView.delegate = self;
        _textView.mm_delegate = self;
    }
    return _textView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [UIProgressView new];
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.backgroundColor = [UIColor lightGrayColor];
    }
    return _progressView;
}

- (UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadButton setImage:[UIImage imageNamed:@"editpost_reupload"] forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(onReloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}

- (void)onReloadBtnClick:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(mm_reloadItemAtIndexPath:)]) {
        [self.delegate mm_reloadItemAtIndexPath:[self curIndexPath]];
    }
}


#pragma mark - ......::::::: UITextViewDelegate :::::::......

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 处理换行
    if ([text isEqualToString:@"\n"]) {
        if (range.location == 0 && range.length == 0) {
            // 在前面添加换行
            if ([self.delegate respondsToSelector:@selector(mm_preInsertTextLineAtIndexPath:textContent:)]) {
                [self.delegate mm_preInsertTextLineAtIndexPath:[self curIndexPath]textContent:text];
            }
        } else if (range.location == 1 && range.length == 0) {
            // 在后面添加换行
            if ([self.delegate respondsToSelector:@selector(mm_postInsertTextLineAtIndexPath:textContent:)]) {
                [self.delegate mm_postInsertTextLineAtIndexPath:[self curIndexPath] textContent:text];
            }
        } else if (range.location == 0 && range.length == 2) {
            // 选中和换行
        }
    }
    
    if (![text isEqualToString:@"\n"] && text.length > 0) {
        if (range.location == 1 && range.length == 0) {
            // 在后面添加换行
            if ([self.delegate respondsToSelector:@selector(mm_postInsertTextLineAtIndexPath:textContent:)]) {
                [self.delegate mm_postInsertTextLineAtIndexPath:[self curIndexPath] textContent:text];
            }
        }
    }
    
    // 处理删除
    if ([text isEqualToString:@""]) {
        NSRange selRange = textView.selectedRange;
        if (selRange.location == 0 && selRange.length == 0) {
            // 处理删除
            if ([self.delegate respondsToSelector:@selector(mm_preDeleteItemAtIndexPath:)]) {
                [self.delegate mm_preDeleteItemAtIndexPath:[self curIndexPath]];
            }
        } else if (selRange.location == 1 && selRange.length == 0) {
            // 处理删除
            if ([self.delegate respondsToSelector:@selector(mm_PostDeleteItemAtIndexPath:)]) {
                [self.delegate mm_PostDeleteItemAtIndexPath:[self curIndexPath]];
            }
        } else if (selRange.location == 0 && selRange.length == 2) {
            // 处理删除
            if ([self.delegate respondsToSelector:@selector(mm_preDeleteItemAtIndexPath:)]) {
                [self.delegate mm_preDeleteItemAtIndexPath:[self curIndexPath]];
            }
        }
    }
    return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.inputAccessoryView = [self.delegate mm_inputAccessoryView];
    if ([self.delegate respondsToSelector:@selector(mm_updateActiveIndexPath:)]) {
        [self.delegate mm_updateActiveIndexPath:[self curIndexPath]];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    textView.inputAccessoryView = nil;
    return YES;
}


#pragma mark - ......::::::: MMRichImageUploadDelegate :::::::......

// 上传进度回调
- (void)uploadProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress];
    });
}

// 上传失败回调
- (void)uploadFail {
    [self.progressView setProgress:0.01f];
    self.reloadButton.hidden = NO;
}

// 上传完成回调
- (void)uploadDone {
    [self.progressView setProgress:1.0f];
}


@end
