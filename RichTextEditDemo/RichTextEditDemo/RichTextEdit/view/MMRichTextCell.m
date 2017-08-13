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
#import "UITextView+RCSBackWord.h"


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


#pragma mark - ......::::::: public :::::::......

- (void)updateWithData:(id)data indexPath:(NSIndexPath*)indexPath {
    if ([data isKindOfClass:[MMRichTextModel class]]) {
        MMRichTextModel* textModel = (MMRichTextModel*)data;
        _textModel = textModel;
        
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(textModel.textContentHeight));
        }];
        // Content
        _textView.text = textModel.textContent;
        
        // Placeholder
        [self handlePlaceholder];
    }
}

- (void)mm_beginEditing {
    [_textView becomeFirstResponder];
    
    _textView.text = _textModel.textContent;
    if (_textModel.shouldUpdateSelectedRange) {
        // 手动调用回调方法修改
        [self textViewDidChange:_textView];
    }
    
    // Placeholder
    [self handlePlaceholder];
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(mm_updateActiveIndexPath:)]) {
        [self.delegate mm_updateActiveIndexPath:[self curIndexPath]];
    }
}

- (void)mm_endEditing {
    BOOL result = [self.textView resignFirstResponder];
    NSLog(@"result = %d", result);
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
        _textView.placeHolder = @"请输入内容";
        _textView.maxInputs = MMEditConfig.maxTextContentCount;
        _textView.delegate = self;
        _textView.mm_delegate = self;
    }
    return _textView;
}


#pragma mark - ......::::::: private :::::::......

- (void)scrollToCursorForTextView:(UITextView*)textView {
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [self.containerTableView convertRect:cursorRect fromView:textView];
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.containerTableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible:(CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.containerTableView.contentOffset;
    visibleRect.origin.y += self.containerTableView.contentInset.top;
    visibleRect.size = self.containerTableView.bounds.size;
    visibleRect.size.height -= self.containerTableView.contentInset.top + self.containerTableView.contentInset.bottom;
    return CGRectContainsRect(visibleRect, rect);
}

- (void)handlePlaceholder {
    if ([self.delegate respondsToSelector:@selector(mm_shouldCellShowPlaceholder)]) {
        BOOL showPlaceholder = [self.delegate mm_shouldCellShowPlaceholder];
        self.textView.showPlaceHolder = showPlaceholder;
    } else {
        self.textView.showPlaceHolder = NO;
    }
}


#pragma mark - ......::::::: UITextViewDelegate :::::::......

- (void)textViewDidChange:(UITextView *)textView {
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    // 更新模型数据
    _textModel.textContentHeight = size.height;
    _textModel.textContent = textView.text;
    if (_textModel.shouldUpdateSelectedRange) {
        // 光标位置特殊处理
        textView.selectedRange = _textModel.selectedRange;
        _textModel.shouldUpdateSelectedRange = NO;
    }
    _textModel.isEditing = YES;
    
    if (ABS(_textView.frame.size.height - size.height) > 5) {
        
        UITableView* tableView = [self containerTableView];
        [tableView beginUpdates];
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).priority(900);
            make.height.equalTo(@(_textModel.textContentHeight));
        }];
        [tableView endUpdates];
        
        // 移动光标 https://stackoverflow.com/questions/18368567/uitableviewcell-with-uitextview-height-in-ios-7
        [self scrollToCursorForTextView:textView];
    }
    
    if (textView.text.length <= 0) {
        // Placeholder
        [self handlePlaceholder];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(mm_shouldShowAccessoryView:)]) {
        [self.delegate mm_shouldShowAccessoryView:YES];
    }
    self.isEditing = YES;
    if ([self.delegate respondsToSelector:@selector(mm_updateActiveIndexPath:)]) {
        [self.delegate mm_updateActiveIndexPath:[self curIndexPath]];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    textView.inputAccessoryView = nil;
    self.isEditing = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"");
    // 处理删除，防止输入的字数为最大值的时候删除无效
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if (NO == self.isEditing) {
        // 隐藏键盘,TextView会自动填充选中的联想词，这个地方返回NO做特殊处理，
        // 不让TextView自动填充选中的联想词
        self.isEditing = YES;
        return NO;
    }
    // 中间位置不能插入更多导致超过最大值
    // 结尾位置支持插入更多   && range.location < textView.text.length
    if (textView.text.length + text.length > MMEditConfig.maxTextContentCount) {
        return NO;
    }
    return YES;
}


#pragma mark delete handler

- (void)textViewWillDelete {
    // 处理的删除
    NSRange selRange = self.textView.selectedRange;
    if (selRange.location == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(mm_preDeleteItemAtIndexPath:)]) {
                [self.delegate mm_preDeleteItemAtIndexPath:[self curIndexPath]];
            }
        });
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(mm_PostDeleteItemAtIndexPath:)]) {
                [self.delegate mm_PostDeleteItemAtIndexPath:[self curIndexPath]];
            }
        });
    }
}

@end
