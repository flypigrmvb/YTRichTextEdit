//
//  UIImage+Util.m
//  RichTextEditDemo
//
//  Created by aron on 2017/8/2.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "UIImage+Util.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import <UIImageView+WebCache.h>

@implementation UIImage (Util)

- (UIImage *)scaletoSize:(float)imageSize {
    if (self.size.width < imageSize) {
        return self;
    }
    CGFloat imageHeight = self.size.height * 1.0 /self.size.width * imageSize;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageHeight), NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, imageSize, imageHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
