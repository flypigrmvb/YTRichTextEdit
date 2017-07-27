//
//  MMRichTextModel.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMRichTextModel : NSObject

@property (nonatomic, assign) CGRect textFrame;
@property (nonatomic, copy) NSString* textContent;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) BOOL shouldUpdateSelectedRange;


@end
