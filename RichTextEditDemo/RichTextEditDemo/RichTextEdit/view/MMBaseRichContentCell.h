//
//  MMBaseRichContentCell.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMBaseRichContentCell : UITableViewCell

- (UITableView*)containerTableView;
- (NSIndexPath*)curIndexPath;

@end
