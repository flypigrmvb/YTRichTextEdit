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
        make.height.equalTo(@(convertLength(0.5)));
    }];
}

- (void)updateWithData:(id)data indexPath:(NSIndexPath*)indexPath {
    if ([data isKindOfClass:[MMRichTitleModel class]]) {
        MMRichTitleModel* titleModel = (MMRichTitleModel*)data;
        _titleModel = titleModel;
        
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(_titleModel.titleViewFrame.size.height));
        }];
        // Content
        _textView.text = _titleModel.textContent;
    }
}

- (void)beginEditing {
    [_textView becomeFirstResponder];
    
    if (![_textView.text isEqualToString:_titleModel.textContent]) {
        _textView.text = _titleModel.textContent;
        
        // 手动调用回调方法修改
        [self textViewDidChange:_textView];
    }
}


#pragma mark - ......::::::: lazy load :::::::......

- (MMTextView *)textView {
    if (!_textView) {
        _textView = [MMTextView new];
        _textView.font = MMEditConfig.defaultEditTitleFont;
        _textView.textContainerInset = UIEdgeInsetsMake(MMEditConfig.editTitleAreaTopPadding, MMEditConfig.editTitleAreaLeftPadding, MMEditConfig.editTitleAreaBottomPadding, MMEditConfig.editTitleAreaRightPadding);
        _textView.scrollEnabled = NO;
        _textView.placeHolder = _(@"Title");
        _textView.delegate = self;
        _textView.mm_delegate = self;
    }
    return _textView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor lightGrayColor];
    }
    return _separatorView;
}


#pragma mark - ......::::::: UITextViewDelegate :::::::......

- (void)textViewDidChange:(UITextView *)textView {
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    // 更新模型数据
    _titleModel.titleViewFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    _titleModel.textContent = textView.text;
    _titleModel.selectedRange = textView.selectedRange;
    _titleModel.isEditing = YES;
    
    if (ABS(_textView.frame.size.height - size.height) > 5) {
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(_titleModel.titleViewFrame.size.height));
        }];
        
        UITableView* tableView = [self containerTableView];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

@end
