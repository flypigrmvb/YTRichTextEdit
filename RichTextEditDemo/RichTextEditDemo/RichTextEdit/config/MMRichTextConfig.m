//
//  MMRichTextConfig.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/20.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichTextConfig.h"
#import <UIKit/UIKit.h>
#import "UtilMacro.h"

@implementation MMRichTextConfig

+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _editAreaLeftPadding = convertLength(20);
        _editAreaRightPadding = convertLength(20);
        _editAreaTopPadding = convertLength(7.5f);
        _editAreaBottomPadding = convertLength(7.5f);
        _editAreaWidth = [UIScreen mainScreen].bounds.size.width;
        _imageDeltaWidth = 10.0f;
        
        _editTitleAreaLeftPadding = convertLength(20);
        _editTitleAreaRightPadding = convertLength(20);
        _editTitleAreaTopPadding = convertLength(17);
        _editTitleAreaBottomPadding = convertLength(17);
        
        _defaultEditContentFont = [UIFont systemFontOfSize:16];
        _defaultEditTitleFont = [UIFont systemFontOfSize:20];
    }
    return self;
}

@end
