//
//  MMRichTextCell.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichTextCell.h"
#import <Masonry.h>
#import "MMRichTextModel.h"
#import "MMTextView.h"
#import "MMRichTextConfig.h"
#import "UtilMacro.h"


@interface MMRichTextCell () <MMTextViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) MMTextView* textView;
@property (nonatomic, strong) MMRichTextModel* textModel;
@property (nonatomic, assign) BOOL isEditing;
@end


@implementation MMRichTextCell

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
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self).priority(900);
    }];
}

- (void)updateWithData:(id)data indexPath:(NSIndexPath*)indexPath {
    if ([data isKindOfClass:[MMRichTextModel class]]) {
        MMRichTextModel* textModel = (MMRichTextModel*)data;
        _textModel = textModel;
        
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(textModel.textFrame.size.height));
        }];
        // Content
        _textView.text = textModel.textContent;
        // Placeholder
        if (indexPath.row == 0) {
            self.textView.showPlaceHolder = YES;
        } else {
            self.textView.showPlaceHolder = NO;
        }
    }
}

- (void)beginEditing {
    [_textView becomeFirstResponder];
    
    if (![_textView.text isEqualToString:_textModel.textContent]) {
        _textView.text = _textModel.textContent;
        
        // 手动调用回调方法修改
        [self textViewDidChange:_textView];
    }
    
    if ([self curIndexPath].row == 0) {
        self.textView.showPlaceHolder = YES;
    } else {
        self.textView.showPlaceHolder = NO;
    }
}

- (NSRange)selectRange {
    return _textView.selectedRange;
}

- (NSArray<NSString*>*)splitedTextArrWithPreFlag:(BOOL*)isPre postFlag:(BOOL*)isPost {
    NSMutableArray* splitedTextArr = [NSMutableArray new];
    
    NSRange selRange = self.selectRange;
    
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
    
    // 0 - selectRange.location
    if (selRange.location > 0) {
        [splitedTextArr addObject:[_textView.text substringToIndex:selRange.location]];
    }
    
    // selectRange.location+selectRange.length - end
    if (selRange.location+selRange.length < _textView.text.length) {
        [splitedTextArr addObject:[_textView.text substringWithRange:NSMakeRange(selRange.location+selRange.length, _textView.text.length - (selRange.location+selRange.length))]];
    }
    
    return splitedTextArr;
}


#pragma mark - ......::::::: lazy load :::::::......

- (MMTextView *)textView {
    if (!_textView) {
        _textView = [MMTextView new];
        _textView.font = MMEditConfig.defaultEditContentFont;
        _textView.textContainerInset = UIEdgeInsetsMake(MMEditConfig.editAreaTopPadding, MMEditConfig.editAreaLeftPadding, MMEditConfig.editAreaBottomPadding, MMEditConfig.editAreaRightPadding);
        _textView.scrollEnabled = NO;
        _textView.placeHolder = _(@"Please enter here");
        _textView.delegate = self;
        _textView.mm_delegate = self;
    }
    return _textView;
}


#pragma mark - ......::::::: UITextViewDelegate :::::::......

- (void)textViewDidChange:(UITextView *)textView {
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    // 更新模型数据
    _textModel.textFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    _textModel.textContent = textView.text;
//    _textModel.selectedRange = textView.selectedRange;
    if (_textModel.shouldUpdateSelectedRange) {
        textView.selectedRange = _textModel.selectedRange;
        _textModel.shouldUpdateSelectedRange = NO;
    }
    _textModel.isEditing = YES;
    
    if (ABS(_textView.frame.size.height - size.height) > 5) {
        
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(_textModel.textFrame.size.height));
        }];
        
        UITableView* tableView = [self containerTableView];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
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

- (void)textViewDeleteBackward:(MMTextView *)textView {
    // 处理删除
    NSRange selRange = textView.selectedRange;
    if (selRange.location == 0) {
        if ([self.delegate respondsToSelector:@selector(mm_preDeleteItemAtIndexPath:)]) {
            [self.delegate mm_preDeleteItemAtIndexPath:[self curIndexPath]];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(mm_PostDeleteItemAtIndexPath:)]) {
            [self.delegate mm_PostDeleteItemAtIndexPath:[self curIndexPath]];
        }
    }
}

@end
