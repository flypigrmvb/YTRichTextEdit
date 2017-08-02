//
//  MMRichTitleModel.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMBaseRichContentModel.h"
#import <YYModel.h>

@interface MMRichTitleModel : MMBaseRichContentModel <YYModel>

@property (nonatomic, assign) CGFloat titleContentHeight;
@property (nonatomic, assign) CGFloat extraContentHeight;
@property (nonatomic, copy) NSString* textContent;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSRange selectedRange;

@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end
