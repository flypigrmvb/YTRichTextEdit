//
//  UITextView+RCSBackWord.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/31.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "UITextView+RCSBackWord.h"
#import <objc/runtime.h>

@implementation UITextView (RCSBackWord)

+ (void)load {
    //! 交换2个方法中的IMP
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
    Method method2 = class_getInstanceMethod([self class], @selector(Rcs_deleteBackward));
    method_exchangeImplementations(method1, method2);
    //! 下面这个交换主要解决大于等于8.0小于8.3系统不调用deleteBackward的问题
    Method method3 = class_getInstanceMethod([self class], NSSelectorFromString(@"keyboardInputShouldDelete:"));
    Method method4 = class_getInstanceMethod([self class], @selector(Rcs_keyboardInputShouldDelete:));
    method_exchangeImplementations(method3, method4);
}

- (void)Rcs_deleteBackward
{
    [self Rcs_deleteBackward];
    if ([self.delegate respondsToSelector:@selector(textFieldDidDeleteBackward:)]){
        id <RCSBackWordTextFieldDelegate> delegate = (id<RCSBackWordTextFieldDelegate>)self.delegate;
        [delegate textFieldDidDeleteBackward:self];
    }
}

- (BOOL)Rcs_keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = [self Rcs_keyboardInputShouldDelete:textField];
    BOOL isMoreThanIos8_0 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f);
    BOOL isLessThanIos8_3 = ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3f);
    if (![textField.text length] && isMoreThanIos8_0 && isLessThanIos8_3) {
        [self deleteBackward];
    }
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(textViewWillDelete)]){
        id <RCSBackWordTextFieldDelegate> delegate = (id<RCSBackWordTextFieldDelegate>)self.delegate;
        [delegate textViewWillDelete];
    }
    
    return shouldDelete;
}
@end
