//
//  MMBaseRichContentModel.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/25.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MMRichContentType) {
    MMRichContentTypeImage = 1,
    MMRichContentTypeText,
    MMRichContentTypeTitle,
};

@interface MMBaseRichContentModel : NSObject
@property (nonatomic, assign) MMRichContentType richContentType;
@end
