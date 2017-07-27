//
//  MMBaseRichContentCell.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/21.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMBaseRichContentCell.h"

@implementation MMBaseRichContentCell


#pragma mark - ......::::::: public :::::::......

- (UITableView*)containerTableView {
    UITableView* containerTableView = (UITableView*)self.superview;
    while (containerTableView != nil && ![containerTableView isKindOfClass:[UITableView class]]) {
        containerTableView = (UITableView*)containerTableView.superview;
    }
    return containerTableView;
}

- (void)handleReloadSelf {
    // 获取Container TableView
    UITableView* containerTableView = [self containerTableView];
    if (containerTableView) {
        NSIndexPath* indexPath = [containerTableView indexPathForCell:self];
        if (indexPath) {
            [containerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [containerTableView reloadData];
        }
    }
}

- (NSIndexPath*)curIndexPath {
    UITableView* containerTableView = [self containerTableView];
    NSIndexPath* indexPath = [containerTableView indexPathForCell:self];
    return indexPath;
}

@end
