//
//  MMDatabaseConn
//  RichTextEditDemo
//
//  Created by aron on 2017/5/3.
//  Copyright © 2017年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "UtilMacro.h"

@interface MMDatabaseConn : NSObject

AS_SINGLETON

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;
@property (nonatomic, copy) NSString* DBFilePath;

@end
