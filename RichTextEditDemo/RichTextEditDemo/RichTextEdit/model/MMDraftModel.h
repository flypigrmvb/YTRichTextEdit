//
//  MMDraftModel.h
//  mmosite
//
//  Created by aron on 2017/7/25.
//  Copyright © 2017年 qingot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMBaseRichContentModel.h"

@interface MMDraftModel : NSObject <YYModel>
@property (nonatomic, assign) NSInteger draftId;
@property (nonatomic, copy) NSString* createTimeString;
@property (nonatomic, copy) NSString* modifyTimeString;
@property (nonatomic, copy) NSString* tid;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, strong) MMBaseRichContentModel* titleModel;
@property (nonatomic, strong) NSArray<MMBaseRichContentModel*>* contentModels;

/**
 *  创建表
 */
+ (void)createTableIfNotExists;

/**
 获取草稿
 */
+ (void)retriveDraftWithCompletion:(void (^)(NSArray *aDrafts, NSError *aError))aCompletionBlock;

/**
 插入一条草稿
 */
+ (void)insertDraft:(MMDraftModel*)draft
              error:(NSError **)pError;

/**
 删除草稿
 */
+ (void)deleteDraft:(MMDraftModel*)draft
              error:(NSError **)pError;

@end
