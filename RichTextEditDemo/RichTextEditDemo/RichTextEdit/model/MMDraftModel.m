//
//  MMDraftModel.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/25.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMDraftModel.h"
#import "MMDatabaseConn.h"
#import <YYModel.h>
#import "MMDraftUtil.h"
#import "UtilMacro.h"
#import "MMRichImageModel.h"

static NSString* draft_tableName = @"t_draft";

@implementation MMDraftModel

- (void)setContentModels:(NSArray<MMBaseRichContentModel *> *)contentModels {
    for (MMBaseRichContentModel* obj in contentModels) {
        if ([obj isKindOfClass:[MMRichImageModel class]]) {
            MMRichImageModel* imageModel = (MMRichImageModel*)obj;
            if (imageModel.remoteImageUrlString != nil
                && imageModel.remoteImageUrlString.length > 0) {
                imageModel.isFailed = NO;
                imageModel.isDone = YES;
            } else {
                imageModel.isFailed = YES;
                imageModel.isDone = NO;
            }
        }
    }
    _contentModels = contentModels;
}

/**
 *  创建表
 */
+ (void)createTableIfNotExists {
    NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (draftID INTEGER, userId TEXT, tid TEXT, contentJsonString TEXT, createTimeString TEXT, modifyTimeString TEXT, PRIMARY KEY(draftID));", draft_tableName];
    
    [[MMDatabaseConn sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

/**
 获取草稿
 */
+ (void)retriveDraftWithCompletion:(void (^)(NSArray *aDrafts, NSError *aError))aCompletionBlock {
    NSMutableArray *results = [NSMutableArray array];
    NSMutableString* sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE 1=1", draft_tableName];
    [sql appendFormat:@" AND userId = '%@'", @"TEST_USER_ID"];
    [sql appendString:@" ORDER BY modifyTimeString DESC"];
    [[MMDatabaseConn sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        while (set.next) {
            
            NSString* contentJsonString = [set objectForColumnName:@"contentJsonString"];
            contentJsonString = [contentJsonString stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
            MMDraftModel* draftData = [MMDraftUtil draftModelWithDraftDataString:contentJsonString];
            
            if (draftData) {
                [results addObject:draftData];
            }
        }
    }];
    !aCompletionBlock ?: aCompletionBlock(results, nil);
}

/**
 插入一条草稿
 */
+ (void)insertDraft:(MMDraftModel*)draft
              error:(NSError **)pError {
    NSString* contentJsonString = [draft yy_modelToJSONString];
    contentJsonString = [contentJsonString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString* sql = [NSMutableString stringWithFormat:@"REPLACE INTO %@ (draftID, userId, tid, contentJsonString, createTimeString, modifyTimeString) VALUES (%@, '%@', '%@', '%@', '%@', '%@')", draft_tableName,
                            @(draft.draftId),
                            ValueOrEmpty(draft.userId),
                            ValueOrEmpty(draft.tid),
                            ValueOrEmpty(contentJsonString),
                            ValueOrEmpty(draft.createTimeString),
                            ValueOrEmpty(draft.modifyTimeString)];
    [self.class doUpdateWithSql:sql error:pError];
}

/**
 删除草稿
 */
+ (void)deleteDraft:(MMDraftModel*)draft
              error:(NSError **)pError {
    NSMutableString* sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE 1=1 AND draftID = %@", draft_tableName, @(draft.draftId)];
    [self.class doUpdateWithSql:sql error:pError];
}


#pragma mark - ......::::::: helper :::::::......

+ (void)doUpdateWithSql:(NSString* )sql error:(NSError **)pError {
    __block BOOL result = NO;
    [[MMDatabaseConn sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (result == NO && pError) {
        *pError = [NSError errorWithDomain:@"" code:1 userInfo:@{}];
    }
}

@end
