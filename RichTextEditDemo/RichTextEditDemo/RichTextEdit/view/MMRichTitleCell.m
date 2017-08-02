//
//  MMRichTitleCell.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichTitleCell.h"
#import "MMTextView.h"
#import "MMRichTitleModel.h"
#import <Masonry.h>
#import "MMRichTextConfig.h"
#import "UtilMacro.h"


@interface MMRichTitleCell () <MMTextViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) MMTextView* textView;
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) MMRichTitleModel* titleModel;

@property (nonatomic, assign) BOOL isEditing;

@end


@implementation MMRichTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    _textView.delegate = nil;
    [[NSNotificationCenter defaultCenter ] removeObserver:self];
}

- (void)setupUI {
    [self addSubview:self.textView];
    [self addSubview:self.separatorView];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self).priority(900);
    }];
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(convertLength(20));
        make.right.equalTo(self).offset(-convertLength(20));
        make.bottom.equalTo(self).offset(-convertLength(0.5));
        make.height.equalTo(@(convertLength(7.5)));
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)updateWithData:(id)data indexPath:(NSIndexPath*)indexPath {
    if ([data isKindOfClass:[MMRichTitleModel class]]) {
        MMRichTitleModel* titleModel = (MMRichTitleModel*)data;
        _titleModel = titleModel;
        
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(_titleModel.titleContentHeight));
        }];
        
        // Content
        self.textView.text = _titleModel.textContent;
    }
}

- (void)mm_beginEditing {
    [self.textView becomeFirstResponder];
    
    if (![self.textView.text isEqualToString:_titleModel.textContent]) {
        self.textView.text = _titleModel.textContent;
        
        // 手动调用回调方法修改
        [self textViewDidChange:self.textView];
    }
}

- (void)mm_endEditing {
    BOOL result = [self.textView resignFirstResponder];
    NSLog(@"result = %d", result);
}


#pragma mark - ......::::::: lazy load :::::::......

- (MMTextView *)textView {
    if (!_textView) {
        _textView = [MMTextView new];
        _textView.font = MMEditConfig.defaultEditTitleFont;
        _textView.textContainerInset = UIEdgeInsetsMake(MMEditConfig.editTitleAreaTopPadding, MMEditConfig.editTitleAreaLeftPadding, MMEditConfig.editTitleAreaBottomPadding, MMEditConfig.editTitleAreaRightPadding);
        _textView.scrollEnabled = NO;
        _textView.maxInputs = MMEditConfig.titleMaxCount;
        _textView.placeHolder = @"请输入标题";
        _textView.showPlaceHolder = YES;
        _textView.delegate = self;
        _textView.mm_delegate = self;
    }
    return _textView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor whiteColor];
        
        UIView* separatorLine = [UIView new];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
        [_separatorView addSubview:separatorLine];
        [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(convertLength(0.5)));
            make.left.top.right.equalTo(_separatorView);
        }];
    }
    return _separatorView;
}


#pragma mark - ......::::::: UITextViewDelegate :::::::......

- (void)textViewDidChange:(UITextView *)textView {
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(mm_shouldShowAccessoryView:)]) {
        [self.delegate mm_shouldShowAccessoryView:NO];
    }
    self.isEditing = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.isEditing = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"");
    if (NO == self.isEditing) {
        // 隐藏键盘TextView显示的文字特殊处理
        self.isEditing = YES;
        return NO;
    }
    if (textView.text.length + text.length >= MMEditConfig.titleMaxCount) {
        return NO;
    }
    return YES;
}

- (void)handleTextViewDidChange {
    CGRect frame = self.textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [self.textView sizeThatFits:constraintSize];
    
    // 更新模型数据
    _titleModel.titleContentHeight = size.height;
    _titleModel.textContent = self.textView.text;
    _titleModel.selectedRange = self.textView.selectedRange;
    _titleModel.isEditing = YES;
    
    if (ABS(_textView.frame.size.height - size.height) > 5) {
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(_titleModel.titleContentHeight));
        }];
        
        UITableView* tableView = [self containerTableView];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}


#pragma mark - ......::::::: notification :::::::......

- (void)textDidChange:(NSNotification*)notification {
    NSObject* obj = notification.object;
    if (obj == self.textView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleTextViewDidChange];
        });
    }
}


@end
