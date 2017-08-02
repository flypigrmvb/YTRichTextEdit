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
        if (indexPath.row == 0) {
            self.textView.showPlaceHolder = YES;
        } else {
            self.textView.showPlaceHolder = NO;
        }
    }
}

- (void)mm_beginEditing {
    [_textView becomeFirstResponder];
    
    //    if (![_textView.text isEqualToString:_textModel.textContent]) {
    //        _textView.text = _textModel.textContent;
    //
    //        // 手动调用回调方法修改
    //        [self textViewDidChange:_textView];
    //    }
    if (_textModel.shouldUpdateSelectedRange) {
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
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // textView.inputAccessoryView = [self.delegate mm_inputAccessoryView];
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
    if (NO == self.isEditing) {
        // 隐藏键盘TextView显示的文字特殊处理
        self.isEditing = YES;
        return NO;
    }
    if (textView.text.length + text.length >= MMEditConfig.maxTextContentCount) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"");
}

#pragma mark delete handler

- (void)textViewDeleteBackward:(MMTextView *)textView {
    /*
     BOOL isMoreThanIos9_0 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f);
     if (isMoreThanIos9_0) {
     // IOS9以上处理删除
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
     */
}

- (void)textFieldDidDeleteBackward:(UITextView *)textView {
    NSLog(@"=======");
    //    // 处理删除
    //    NSRange selRange = textView.selectedRange;
    //    if (selRange.location == 0) {
    //        if ([self.delegate respondsToSelector:@selector(mm_preDeleteItemAtIndexPath:)]) {
    //            [self.delegate mm_preDeleteItemAtIndexPath:[self curIndexPath]];
    //        }
    //    } else {
    //        if ([self.delegate respondsToSelector:@selector(mm_PostDeleteItemAtIndexPath:)]) {
    //            [self.delegate mm_PostDeleteItemAtIndexPath:[self curIndexPath]];
    //        }
    //    }
}

- (void)textViewWillDelete {
    NSLog(@"=======");
    //    BOOL isMoreThanIos9_0 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f);
    //    if (NO == isMoreThanIos9_0) {
    // 处理ios8的删除
    NSRange selRange = self.textView.selectedRange;
    // IOS8 BUG，需要延迟回调，否则光标定位到上一行是图片会到子图片内容消失
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
    //    }
}

@end
