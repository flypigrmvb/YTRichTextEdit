//
//  RichTextEditViewController.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LMSegmentedControl.h"
#import "MMRichEditAccessoryView.h"

@protocol RichTextEditDelegate <NSObject>

// 下面的属性相当远Delegate的属性，暂时放在类的属性中处理，把当前类作为弱引用提供给Cell
- (MMRichEditAccessoryView *)mm_inputAccessoryView;

- (void)mm_preInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent;
- (void)mm_postInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent;
- (void)mm_preDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)mm_PostDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)mm_updateActiveIndexPath:(NSIndexPath*)activeIndexPath;
- (void)mm_reloadItemAtIndexPath:(NSIndexPath*)actionIndexPath;

@end

@interface RichTextEditViewController : UIViewController

@end
