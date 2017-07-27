//
//  MMFileUploadUtil.h
//  RichTextEditDemo
//
//  Created by aron on 2017/7/23.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilMacro.h"

@protocol UploadItemCallBackProtocal <NSObject>

- (void)mm_uploadProgress:(float)progress;
- (void)mm_uploadFailed;
- (void)mm_uploadDone:(NSString*)remoteImageUrlString;

@end

@protocol UploadItemProtocal <NSObject>

- (NSData*)mm_uploadData;
- (NSURL*)mm_uploadFileURL;

@end

@interface MMFileUploadUtil : NSObject

AS_SINGLETON

- (void)uploadFileWithData:(NSData*)uploadData;
- (void)addUploadItem:(id<UploadItemProtocal, UploadItemCallBackProtocal>)uploadItem;
- (void)removeUploadItem:(id<UploadItemProtocal, UploadItemCallBackProtocal>)uploadItem;

@end
