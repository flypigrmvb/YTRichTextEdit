//
//  RichTextEditViewController.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMRichEditAccessoryView.h"

#define kPostContentNotification            @"PostContentNotification"
#define kPostContentDispatchNotification    @"PostContentDispatchNotification"
#define kPostContentID                      @"PostContentID"
#define kPostContentPubID                   @"PostContentPubID"

@protocol RichTextEditDelegate <NSObject>

- (void)mm_shouldShowAccessoryView:(BOOL)shouldShow;
- (BOOL)mm_shouldCellShowPlaceholder;

- (void)mm_preInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent;
- (void)mm_postInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent;
- (void)mm_preDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)mm_PostDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)mm_updateActiveIndexPath:(NSIndexPath*)activeIndexPath;
- (void)mm_reloadItemAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)mm_uploadFailedAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)mm_uploadDonedAtIndexPath:(NSIndexPath*)actionIndexPath;

@end



@protocol RichContentPostDelegate <NSObject>

- (void)mm_richContentDidPost:(NSInteger)postID;

@end


@class MMDraftModel;

@interface RichTextEditViewController : UIViewController

- (instancetype)initWithTid:(NSString*)tid;
- (instancetype)initWithDraft:(MMDraftModel*)draft;

@property (nonatomic, weak) id<RichContentPostDelegate> contentPostDelegate;

@end
