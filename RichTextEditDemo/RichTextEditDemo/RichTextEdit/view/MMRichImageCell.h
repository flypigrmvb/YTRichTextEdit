//
//  MMRichImageCell.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBaseRichContentCell.h"
#import "RichTextEditViewController.h"


@interface MMRichImageCell : MMBaseRichContentCell

@property (nonatomic, weak) id<RichTextEditDelegate> delegate;

- (void)updateWithData:(id)data;
- (void)beginEditing;

- (void)getPreFlag:(BOOL*)isPre postFlag:(BOOL*)isPost;

@end
