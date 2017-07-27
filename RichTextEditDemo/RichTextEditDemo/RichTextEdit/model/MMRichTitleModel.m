//
//  MMRichTitleModel.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichTitleModel.h"

@implementation MMRichTitleModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _titleViewFrame = CGRectMake(0, 0, 300, 58);
        _textContent = @"";
    }
    return self;
}

@end
