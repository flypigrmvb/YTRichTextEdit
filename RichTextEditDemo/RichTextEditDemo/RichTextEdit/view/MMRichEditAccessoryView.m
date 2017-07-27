//
//  MMRichEditAccessoryView.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMRichEditAccessoryView.h"
#import <Masonry.h>
#import "UtilMacro.h"

@interface MMRichEditAccessoryView ()
@property (nonatomic, strong) UIImageView* kbImageIcon;
@property (nonatomic, strong) UIImageView* picImageIcon;
@end


@implementation MMRichEditAccessoryView

- (instancetype)init {
    if (self = [super init]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.kbImageIcon];
    [self addSubview:self.picImageIcon];
    
    [self.kbImageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(convertLength(20));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.picImageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-convertLength(20));
        make.centerY.equalTo(self.mas_centerY);
    }];
}

- (UIImageView *)kbImageIcon {
    if (!_kbImageIcon) {
        _kbImageIcon = [UIImageView new];
        _kbImageIcon.contentMode = UIViewContentModeScaleAspectFit;
        _kbImageIcon.image = [UIImage imageNamed:@"ABC_icon"];
        _kbImageIcon.userInteractionEnabled = YES;
        [_kbImageIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onKbImageIconTap:)]];
    }
    return _kbImageIcon;
}

- (UIImageView *)picImageIcon {
    if (!_picImageIcon) {
        _picImageIcon = [UIImageView new];
        _picImageIcon.contentMode = UIViewContentModeScaleAspectFit;
        _picImageIcon.image = [UIImage imageNamed:@"img_icon"];
        _picImageIcon.userInteractionEnabled = YES;
        [_picImageIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPicImageIconTap:)]];
    }
    return _picImageIcon;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 绘制顶部分割线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0.5f)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), 0.5f)];
    [path moveToPoint:CGPointMake(0, CGRectGetMaxY(rect) - 0.5f)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) - 0.5f)];
    path.lineWidth = 1.f;
    [[UIColor colorWithWhite:0.9 alpha:1.f] setStroke];
    [path stroke];
}


#pragma mark - ......::::::: ui action :::::::......

- (void)onKbImageIconTap:(UITapGestureRecognizer*)gesture {
    if ([self.delegate respondsToSelector:@selector(mm_didKeyboardTapInaccessoryView:)]) {
        [self.delegate mm_didKeyboardTapInaccessoryView:self];
    }
}

- (void)onPicImageIconTap:(UITapGestureRecognizer*)gesture {
    if ([self.delegate respondsToSelector:@selector(mm_didImageTapInaccessoryView:)]) {
        [self.delegate mm_didImageTapInaccessoryView:self];
    }
}

@end
