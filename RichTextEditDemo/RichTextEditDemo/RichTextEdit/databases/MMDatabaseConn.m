//
//  MMDatabaseConn
//  RichTextEditDemo
//
//  Created by aron on 2017/5/3.
//  Copyright © 2017年 aron. All rights reserved.
//

#define DBMainThreadCheck() NSAssert([NSThread mainThread] == NO,  \
@"The query DB action in main thread is too slow,which may block main thread")

#import "MMDatabaseConn.h"
#import <sqlite3.h>
#import <pthread.h>


@interface MMDatabaseConn (){
    pthread_mutex_t _dbLock;
    FMDatabaseQueue *_databaseQueue;
}

@end

@implementation MMDatabaseConn

DEF_SINGLETON

- (instancetype)init{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_dbLock, NULL);
    }
    return self;
}

- (void)dealloc{
    pthread_mutex_destroy(&_dbLock);
}

- (void)receiveMemoryWarning{
    pthread_mutex_lock(&_dbLock);
    _databaseQueue = nil;
    pthread_mutex_unlock(&_dbLock);
}

#pragma mark - ......::::::: public :::::::......

- (pthread_mutex_t*) dbLock {
    return &_dbLock;
}

#pragma mark - ......::::::: public :::::::......

- (FMDatabaseQueue *)databaseQueue {
    pthread_mutex_lock(&_dbLock);
    if (_databaseQueue == nil) {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_DBFilePath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
    }
    pthread_mutex_unlock(&_dbLock);
    return _databaseQueue;
}

@end
