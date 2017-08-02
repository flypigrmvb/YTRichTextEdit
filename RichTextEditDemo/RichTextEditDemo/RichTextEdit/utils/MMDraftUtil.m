//
//  MMDraftUtil.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/25.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMDraftUtil.h"
#import "MMDraftModel.h"
#import "MMRichTextModel.h"
#import "MMRichImageModel.h"
#import "MMRichTitleModel.h"
#import "NSString+NSDate.h"
#import "MMRichContentUtil.h"

@implementation MMDraftUtil

// 保存草稿数据
+ (void)saveDraftData:(MMDraftModel*)draftData {
    [MMDraftModel insertDraft:draftData error:nil];
}

// 删除草稿数据
+ (void)delateDraftData:(MMDraftModel*)draftData {
    // 删除图片
    [self deleteImagesFromDraft:draftData];
    
    // 删除数据库记录
    [MMDraftModel deleteDraft:draftData error:nil];
}

// 获取草稿
+ (void)retriveDraftWithCompletion:(void (^)(NSArray *aDrafts, NSError *aError))aCompletionBlock {
    [MMDraftModel retriveDraftWithCompletion:aCompletionBlock];
}

// 数据库读取的草稿序列化
+ (MMDraftModel*)draftModelWithDraftDataString:(NSString*)draftDataString {
    
    MMDraftModel* draftModel = nil;
    
    NSDictionary* dic = nil;
    NSData* jsonData = [(NSString *)draftDataString dataUsingEncoding : NSUTF8StringEncoding];
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    }
    if (dic) {
        draftModel = [MMDraftModel yy_modelWithDictionary:dic];
        
        // Title
        NSDictionary* titleModelDict = [dic objectForKey:@"titleModel"];
        if ([titleModelDict isKindOfClass:[NSDictionary class]]) {
            MMRichTitleModel* titleModel = [MMRichTitleModel yy_modelWithDictionary:titleModelDict];
            if (nil == titleModel) {
                titleModel = [MMRichTitleModel new];
            }
            draftModel.titleModel = titleModel;
        }
        
        // Contents
        NSMutableArray* tmpContentModels = [NSMutableArray array];
        NSArray* contentModelsArr = [dic objectForKey:@"contentModels"];
        if ([contentModelsArr isKindOfClass:[NSArray class]]) {
            for (NSDictionary* richContentDict in contentModelsArr) {
                NSNumber* richContentTypeNum = [richContentDict objectForKey:@"richContentType"];
                if ([richContentTypeNum respondsToSelector:@selector(integerValue)]) {
                    MMRichContentType richContentType = [richContentTypeNum integerValue];
                    if (richContentType == MMRichContentTypeImage) {
                        MMRichImageModel* imageModel = [MMRichImageModel yy_modelWithDictionary:richContentDict];
                        if (imageModel) {
                            [tmpContentModels addObject:imageModel];
                        }
                    } else if (richContentType == MMRichContentTypeText) {
                        MMRichTextModel* textModel = [MMRichTextModel yy_modelWithDictionary:richContentDict];
                        if (textModel) {
                            [tmpContentModels addObject:textModel];
                        }
                    }
                }
            }
        }
        draftModel.contentModels = tmpContentModels;
    }

    return draftModel;
}

// 更新草稿修改时间
+ (void)updateModifyTimeWithDraftData:(MMDraftModel*)draftData {
    draftData.modifyTimeString = [NSString yyyyMMddTHHmmssZDateStringFromDate:[NSDate date]];
}


// 编辑模型生产草稿模型
+ (MMDraftModel*)draftModelWithTitleModel:(MMBaseRichContentModel*)titleModel contents:(NSArray<MMBaseRichContentModel*>*)contents tid:(NSString*)tid draftId:(NSInteger)draftId {
    MMDraftModel* draftModel = [MMDraftModel new];
    draftModel.draftId = draftId > 0 ? draftId : [[NSDate date] timeIntervalSince1970];
    draftModel.createTimeString = [NSString yyyyMMddTHHmmssZDateStringFromDate:[NSDate date]];
    draftModel.modifyTimeString = draftModel.createTimeString;
    draftModel.tid = tid;
    draftModel.userId = @"TEST_USER_ID";
    draftModel.titleModel = titleModel;
    draftModel.contentModels = contents;
    return draftModel;
}

+ (NSString*)contentFromDraftModel:(MMDraftModel*)draftModel {
    return [MMRichContentUtil plainContentFromRichContents:draftModel.contentModels];
}


#pragma mark - ......::::::: helper :::::::......

+ (void)deleteImagesFromDraft:(MMDraftModel*)draftModel {
    for (int i = 0; i< draftModel.contentModels.count; i++) {
        NSObject* content = draftModel.contentModels[i];
        if ([content isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imgContent = (MMRichImageModel*)content;
            [self deleteImageContent:imgContent];
        }
    }
}

+ (void)deleteImageContent:(MMRichImageModel*)imgContent {
    NSString* imgPath = [[MMRichContentUtil imageSavedLocalPath] stringByAppendingPathComponent:imgContent.localImageName];
    if (imgPath) {
        // 删除单张图片
        [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
    }
}

@end
