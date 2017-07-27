//
//  PlaceHolderTextView.m
//  mmosite
//
//  Created by aron on 2017/3/10.
//  Copyright © 2017年 qingot. All rights reserved.
//

#import "MMPlaceHolderTextView.h"
#import "UtilMacro.h"


@implementation MMPlaceHolderTextView {
    UILabel* _placeHolderLabel;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultConfig];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self defaultConfig];
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter ] removeObserver:self];
}

- (void)defaultConfig {
    _maxInputs = 1000;
    _placeHolderFrame = CGRectMake(12, 10, kScreenWidth, 18);
    _debugMode = NO;
}

- (void)setupUI {
    UILabel* placeHolderLabel = [UILabel new];
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    placeHolderLabel.font = self.font;
    placeHolderLabel.text = @"";
    placeHolderLabel.frame = _placeHolderFrame;
    [self addSubview:placeHolderLabel];
    _placeHolderLabel = placeHolderLabel;
    
    // 设置内容的内边距
    self.textContainerInset = UIEdgeInsetsMake(9, 7, 0, 7);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _placeHolderLabel.font = self.font;
    _placeHolderLabel.frame = _placeHolderFrame;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    _placeHolderLabel.font = self.font;
    _placeHolderLabel.frame = _placeHolderFrame;
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight
{
    return ceilf([self sizeThatFits:self.frame.size].height + 10);
}


#pragma mark - ......::::::: notification :::::::......

- (void)textDidChange:(NSNotification*)notification {
    NSObject* obj = notification.object;
    if ([obj isKindOfClass:[MMPlaceHolderTextView class]] && obj == self) {
        [self handleTextDidChange];
    }
}

- (void)handleTextDidChange {
    
    if (_debugMode) {
        return;
    }
    
    if (self.text != nil && self.text.length > 0) {
        _placeHolderLabel.hidden = YES;
    }else {
        _placeHolderLabel.hidden = NO;
    }
    
    // 字数限制
    NSString *toBeString = self.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > _maxInputs) {
                self.text = [toBeString substringToIndex:_maxInputs];
            }
        } else{
            // 有高亮选择的字符串，则暂不对文字进行统计和限制 pandahomeapi.ifjing.com
        }
    } else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > _maxInputs) {
            self.text = [toBeString substringToIndex:_maxInputs];
        }
    }
}


#pragma mark - ......::::::: override :::::::......

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    _placeHolderLabel.font = font;
    [self resetPlaceHolderFrame];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    [self resetPlaceHolderFrame];
}


#pragma mark - ......::::::: private :::::::......
// 重新设置PlaceHolder的Frame
// 设置了font、textContainerInset之后需要重新设置
- (void)resetPlaceHolderFrame {
    CGFloat leftDelta = 5;
    CGFloat topDelta = -1;
    UIEdgeInsets insets = self.textContainerInset;
    [self setPlaceHolderFrame:CGRectMake(insets.left + leftDelta, insets.top + topDelta, kScreenWidth - insets.left - insets.right, self.font.lineHeight + 2)];
}


#pragma mark - ......::::::: public :::::::......

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolderLabel.text = placeHolder;
}

- (void)setPlaceHolderFrame:(CGRect)placeHolderFrame {
    _placeHolderFrame = placeHolderFrame;
    _placeHolderLabel.frame = placeHolderFrame;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    _placeHolderLabel.textColor = placeHolderColor;
}

- (void)setShowPlaceHolder:(BOOL)showPlaceHolder {
    if (showPlaceHolder) {
        if (self.text != nil && self.text.length > 0) {
            _placeHolderLabel.hidden = YES;
        }else {
            _placeHolderLabel.hidden = NO;
        }
    } else {
        _placeHolderLabel.hidden = YES;
    }
}

@end
