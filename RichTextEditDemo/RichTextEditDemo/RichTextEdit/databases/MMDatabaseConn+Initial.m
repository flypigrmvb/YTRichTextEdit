//
//  MMDatabaseConn+Initial.m
//  Pods
//
//  Created by arons on 2016/12/22.
//
//

#import "MMDatabaseConn+Initial.h"
#import <pthread.h>
#import "MMDraftModel.h"

#define kDBCache            @"DBCache"
#define kDBVERSION          @"DBVersion"

/** 当前使用的数据库版本，程序会根据版本号的改变升级数据库以及迁移旧的数据 */
static NSString* DB_Version = @"1.0.1";
/** 数据库文件名称 */
static NSString* DB_NAME = @"DB.sqlite";


@implementation MMDatabaseConn (Initial)

#pragma mark - ......::::::: public :::::::......

/**
 初始化数据库，如果使用APPGroup需要传入APPGroup的URL，否则传入空
 默认把数据库文件保存在Cache目录下
 */
-(void)initDBWithAppGroupURL:(NSURL *)appGroupURL {
    NSURL* emojiDBURL = nil;
    if (appGroupURL) {
        emojiDBURL = [appGroupURL URLByAppendingPathComponent:DB_NAME];
    } else {
        NSString *DBPath = [self createDirectory:kDBCache];
        emojiDBURL = [NSURL fileURLWithPath:[DBPath stringByAppendingPathComponent:DB_NAME]];
    }
    self.DBFilePath = [emojiDBURL path];
    [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:self.DBFilePath error:NULL];
    
    // 数据库版本控制
    [self dbVersionControl];
    
    // 拷贝数据库文件
    [self copyDefaultDBResources];
    
    // 在子线程中初始化数据表
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 数据库表初始化
        [self initTables];
    });
}

// 创建文件夹
- (NSString *)createDirectory:(NSString *)path {
    BOOL isDir = NO;
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [cachePath stringByAppendingPathComponent:path];
    
    if (!([[NSFileManager defaultManager] fileExistsAtPath:finalPath isDirectory:&isDir]
          && isDir)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:finalPath
                                 withIntermediateDirectories :YES
                                                  attributes :nil
                                                       error :nil];
    }
    return finalPath;
}


/**
 初始化默认数据
 */
- (void)initDefaultDatas {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
}

#pragma mark - ......::::::: private :::::::......


- (void)copyDefaultDBResources {
    // FIXME: ZYT 拷贝默认的数据库资源
    NSString* sourceFilePath = @"";
    NSString* destDBFilePath = @"";

    if (![[NSFileManager defaultManager] fileExistsAtPath:destDBFilePath]) {
        BOOL isSourceFileExist = [[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath];
        if (isSourceFileExist) {
            NSError* err;
            [[NSFileManager defaultManager] copyItemAtPath:sourceFilePath toPath:destDBFilePath error:&err];
        }
    }
}

/**
 *  初始化数据表
 */
-(void)initTables{
    [MMDraftModel createTableIfNotExists];
}

#pragma mark - ......::::::: upgrade :::::::......

/**
 *  数据库版本控制
 *  版本号保存在DB_Version宏定义中
 */
- (void)dbVersionControl {
    // 基础数据库版本管理
    [self baseDBVersionControl];
}

// 创建新的临时表，把数据导入临时表，然后用临时表替换原表
- (void)baseDBVersionControl {
    NSString * version_old = [[NSUserDefaults standardUserDefaults] stringForKey:kDBVERSION];
    NSString * version_new = [NSString stringWithFormat:@"%@", DB_Version];
    NSLog(@"dbVersionControl before: %@ after: %@",version_old,version_new);
    
    // 数据库版本升级
    if (version_old != nil && ![version_new isEqualToString:version_old]) {
        
        // 获取数据库中旧的表
        NSArray* existsTables = [self sqliteExistsTables];
        NSMutableArray* tmpExistsTables = [NSMutableArray array];
        
        // 修改表名,添加后缀“_bak”，把旧的表当做备份表
        for (NSString* tablename in existsTables) {
            [tmpExistsTables addObject:[NSString stringWithFormat:@"%@_bak", tablename]];
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                NSString* sql = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_bak", tablename, tablename];
                [db executeUpdate:sql];
            }];
        }
        existsTables = tmpExistsTables;
        
        // 创建新的表
        [self initTables];
        
        // 获取新创建的表
        NSArray* newAddedTables = [self sqliteNewAddedTables];
        
        // 遍历旧的表和新表，对比取出需要迁移的表的字段
        NSDictionary* migrationInfos = [self generateMigrationInfosWithOldTables:existsTables newTables:newAddedTables];
        
        // 数据迁移处理
        [migrationInfos enumerateKeysAndObjectsUsingBlock:^(NSString* newTableName, NSArray* publicColumns, BOOL * _Nonnull stop) {
            NSMutableString* colunmsString = [NSMutableString new];
            for (int i = 0; i<publicColumns.count; i++) {
                [colunmsString appendString:publicColumns[i]];
                if (i != publicColumns.count-1) {
                    [colunmsString appendString:@", "];
                }
            }
            NSMutableString* sql = [NSMutableString new];
            [sql appendString:@"INSERT INTO "];
            [sql appendString:newTableName];
            [sql appendString:@"("];
            [sql appendString:colunmsString];
            [sql appendString:@")"];
            [sql appendString:@" SELECT "];
            [sql appendString:colunmsString];
            [sql appendString:@" FROM "];
            [sql appendFormat:@"%@_bak", newTableName];
            
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:sql];
            }];
        }];
        
        // 删除备份表
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db beginTransaction];
            for (NSString* oldTableName in existsTables) {
                NSString* sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", oldTableName];
                [db executeUpdate:sql];
            }
            [db commit];
        }];
        
        [[NSUserDefaults standardUserDefaults] setObject:version_new forKey:kDBVERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:version_new forKey:kDBVERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSDictionary*)generateMigrationInfosWithOldTables:(NSArray*)oldTables newTables:(NSArray*)newTables {
    NSMutableDictionary<NSString*, NSArray* >* migrationInfos = [NSMutableDictionary dictionary];
    for (NSString* newTableName in newTables) {
        NSString* oldTableName = [NSString stringWithFormat:@"%@_bak", newTableName];
        if ([oldTables containsObject:oldTableName]) {
            // 获取表数据库字段信息
            NSArray* oldTableColumns = [self sqliteTableColumnsWithTableName:oldTableName];
            NSArray* newTableColumns = [self sqliteTableColumnsWithTableName:newTableName];
            NSArray* publicColumns = [self publicColumnsWithOldTableColumns:oldTableColumns newTableColumns:newTableColumns];
            
            if (publicColumns.count > 0) {
                [migrationInfos setObject:publicColumns forKey:newTableName];
            }
        }
    }
    return migrationInfos;
}

- (NSArray*)publicColumnsWithOldTableColumns:(NSArray*)oldTableColumns newTableColumns:(NSArray*)newTableColumns {
    NSMutableArray* publicColumns = [NSMutableArray array];
    for (NSString* oldTableColumn in oldTableColumns) {
        if ([newTableColumns containsObject:oldTableColumn]) {
            [publicColumns addObject:oldTableColumn];
        }
    }
    return publicColumns;
}

- (NSArray*)sqliteTableColumnsWithTableName:(NSString*)tableName {
    __block NSMutableArray<NSString*>* tableColumes = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')", tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString* columnName = [rs stringForColumn:@"name"];
            [tableColumes addObject:columnName];
        }
    }];
    return tableColumes;
}

- (NSArray*)sqliteExistsTables {
    __block NSMutableArray<NSString*>* existsTables = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"SELECT * from sqlite_master WHERE type='table'";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString* tablename = [rs stringForColumn:@"name"];
            [existsTables addObject:tablename];
        }
    }];
    return existsTables;
}

- (NSArray*)sqliteNewAddedTables {
    __block NSMutableArray<NSString*>* newAddedTables = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"SELECT * from sqlite_master WHERE type='table' AND name NOT LIKE '%_bak'";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString* tablename = [rs stringForColumn:@"name"];
            [newAddedTables addObject:tablename];
        }
    }];
    return newAddedTables;
}

@end
