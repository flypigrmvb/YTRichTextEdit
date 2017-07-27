//
//  MMRichTextConfig.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/20.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MMEditConfig    [MMRichTextConfig sharedInstance]

@interface MMRichTextConfig : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) CGFloat editAreaLeftPadding;
@property (nonatomic, assign, readonly) CGFloat editAreaRightPadding;
@property (nonatomic, assign, readonly) CGFloat editAreaTopPadding;
@property (nonatomic, assign, readonly) CGFloat editAreaBottomPadding;
@property (nonatomic, assign, readonly) CGFloat editAreaWidth;
@property (nonatomic, assign, readonly) CGFloat imageDeltaWidth;

@property (nonatomic, assign, readonly) CGFloat editTitleAreaLeftPadding;
@property (nonatomic, assign, readonly) CGFloat editTitleAreaRightPadding;
@property (nonatomic, assign, readonly) CGFloat editTitleAreaTopPadding;
@property (nonatomic, assign, readonly) CGFloat editTitleAreaBottomPadding;


@property (nonatomic, strong, readonly) UIFont* defaultEditContentFont;
@property (nonatomic, strong, readonly) UIFont* defaultEditTitleFont;

@end
