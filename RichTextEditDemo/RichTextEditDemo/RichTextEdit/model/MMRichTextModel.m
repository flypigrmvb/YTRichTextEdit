//
//  MMRichTextModel.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichTextModel.h"

@implementation MMRichTextModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textFrame = CGRectMake(0, 0, 300, 40);
        _textContent = @"";
    }
    return self;
}

@end
