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
        _textContentHeight = 40;
        _textContent = @"";
        self.richContentType = MMRichContentTypeText;
    }
    return self;
}

- (void)setTextContent:(NSString *)textContent {
    if ([textContent isEqualToString:@"\n"]) {
        _textContent = @"";
    } else {
        _textContent = textContent;
    }
}

@end
