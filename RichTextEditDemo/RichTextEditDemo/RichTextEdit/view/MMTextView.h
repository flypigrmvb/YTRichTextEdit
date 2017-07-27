//
//  MMTextView.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/20.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPlaceHolderTextView.h"

@class MMTextView;

@protocol MMTextViewDelegate<NSObject>
@optional
- (void)textViewDeleteBackward:(MMTextView *_Nullable)textView;
@end



@interface MMTextView : MMPlaceHolderTextView

@property(nullable,nonatomic,weak) id<MMTextViewDelegate> mm_delegate;

@end
