//
//  MMTextView.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/20.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMTextView.h"

@implementation MMTextView

- (void)deleteBackward {
    [super deleteBackward];
    
    if ([_mm_delegate respondsToSelector:@selector(textViewDeleteBackward:)]) {
        [_mm_delegate textViewDeleteBackward:self];
    }
}

@end
