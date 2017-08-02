//
//  MMDraftUtil.h
//  mmosite
//
//  Created by aron on 2017/7/25.
//  Copyright © 2017年 qingot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMDraftModel, MMBaseRichContentModel, MMDraftViewModel, MMRichImageModel;

@interface MMDraftUtil : NSObject

// 保存草稿数据
+ (void)saveDraftData:(MMDraftModel*)draftData;
// 删除草稿数据
+ (void)delateDraftData:(MMDraftModel*)draftData;
// 删除单张图片
+ (void)deleteImageContent:(MMRichImageModel*)imgContent;
// 获取草稿
+ (void)retriveDraftWithCompletion:(void (^)(NSArray *aDrafts, NSError *aError))aCompletionBlock;

// 数据库读取的草稿序列化
+ (MMDraftModel*)draftModelWithDraftDataString:(NSString*)draftDataString;
// 编辑模型生产草稿模型
+ (MMDraftModel*)draftModelWithTitleModel:(MMBaseRichContentModel*)titleModel contents:(NSArray<MMBaseRichContentModel*>*)contents tid:(NSString*)tid draftId:(NSInteger)draftId ;
// 更新草稿修改时间
+ (void)updateModifyTimeWithDraftData:(MMDraftModel*)draftData;
// 模型转换
+ (NSArray<MMDraftViewModel*>*)draftViewModelsFromDraftModels:(NSArray<MMDraftModel*>*)draftModels;

@end
