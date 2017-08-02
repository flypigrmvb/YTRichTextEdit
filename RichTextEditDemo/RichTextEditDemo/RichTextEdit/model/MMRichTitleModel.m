//
//  MMRichTitleModel.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichTitleModel.h"
#import "UtilMacro.h"

@implementation MMRichTitleModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        // TextHeight + separatorHeight
        _extraContentHeight = convertLength(7.5);
        _titleContentHeight = convertLength(58);
        _textContent = @"";
        self.richContentType = MMRichContentTypeTitle;
    }
    return self;
}

- (CGFloat)cellHeight {
    return _extraContentHeight + _titleContentHeight;
}

@end
