//
//  MMRichTitleModel.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMRichTitleModel : NSObject

@property (nonatomic, assign) CGRect titleViewFrame;
@property (nonatomic, copy) NSString* textContent;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSRange selectedRange;

@end
