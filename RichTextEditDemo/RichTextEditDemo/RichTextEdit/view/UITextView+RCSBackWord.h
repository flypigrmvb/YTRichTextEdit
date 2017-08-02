//
//  UITextView+RCSBackWord.h
//  mmosite
//
//  Created by aron on 2017/7/31.
//  Copyright © 2017年 qingot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCSBackWordTextFieldDelegate <NSObject>

- (void)textViewWillDelete;
- (void)textFieldDidDeleteBackward:(UITextView *)textView;

@end

@interface UITextView (RCSBackWord)
@property (weak, nonatomic) id<RCSBackWordTextFieldDelegate> delegate;
@end
