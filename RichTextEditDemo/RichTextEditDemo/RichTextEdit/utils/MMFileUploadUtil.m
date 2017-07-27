//
//  MMFileUploadUtil.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/23.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "MMFileUploadUtil.h"
#import <UIKit/UIKit.h>


//分隔符
#define Boundary @"1a2b3c"
//一般换行
#define Wrap1 @"\r\n"
//key-value换行
#define Wrap2 @"\r\n\r\n"
//开始分割
#define StartBoundary [NSString stringWithFormat:@"--%@%@",Boundary,Wrap1]
//文件分割完成
#define EndBody [NSString stringWithFormat:@"--%@--",Boundary]


@interface MMFileUploadUtil () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (strong,nonatomic) NSURLSession * session;
@property (nonatomic, strong) NSMutableArray* uploadingItems;
@property (nonatomic, strong) NSMutableDictionary* uploadingTaskIDToUploadItemMap;
@property (nonatomic, strong) NSMutableArray* todoItems;

@property (nonatomic, assign) NSInteger maxUploadTask;
@end

@implementation MMFileUploadUtil

DEF_SINGLETON

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}


#pragma mark - ......::::::: public :::::::......

- (void)uploadFileWithData:(NSData*)uploadData {
    NSMutableURLRequest * request = [self TSuploadTaskRequest];
    
    NSData* totalData = [self TSuploadTaskRequestBody:uploadData];
    
    NSURLSessionUploadTask * uploadtask = [self.session uploadTaskWithRequest:request fromData:totalData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"completionHandler  %@", result);
    }];
    [uploadtask resume];
}

- (void)addUploadItem:(id<UploadItemProtocal, UploadItemCallBackProtocal>)uploadItem {
    [self.todoItems addObject:uploadItem];
    [self startNextUploadTask];
}

- (void)removeUploadItem:(id<UploadItemProtocal, UploadItemCallBackProtocal>)uploadItem {
    
}


#pragma mark - ......::::::: private :::::::......

- (NSMutableArray *)uploadingItems {
    if (!_uploadingItems) {
        _uploadingItems = [NSMutableArray array];
    }
    return _uploadingItems;
}

- (NSMutableArray *)todoItems {
    if (!_todoItems) {
        _todoItems = [NSMutableArray array];
    }
    return _todoItems;
}

-(NSMutableDictionary *)uploadingTaskIDToUploadItemMap {
    if (!_uploadingTaskIDToUploadItemMap) {
        _uploadingTaskIDToUploadItemMap = [[NSMutableDictionary alloc] init];
    }
    return _uploadingTaskIDToUploadItemMap;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)startNextUploadTask {
    if (self.uploadingItems.count < _maxUploadTask) {
        // 添加下一个任务
        if (self.todoItems.count > 0) {
            id<UploadItemProtocal, UploadItemCallBackProtocal> uploadItem = self.todoItems.firstObject;
            [self.uploadingItems addObject:uploadItem];
            [self.todoItems removeObject:uploadItem];
            
            [self beginUploadItem:uploadItem];
        }
    }
}

- (void)beginUploadItem:(id<UploadItemProtocal, UploadItemCallBackProtocal>)uploadItem {
    NSMutableURLRequest * request = [self TSuploadTaskRequest];
    
    NSData* uploadData = [uploadItem mm_uploadData];
    NSData* totalData = [self TSuploadTaskRequestBody:uploadData];
    
    __block NSURLSessionUploadTask * uploadtask = nil;
    uploadtask = [self.session uploadTaskWithRequest:request fromData:totalData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"completionHandler  %@", result);
       
        if (nil == error) {
            NSString* imgUrlString = @"";
            if (data) {
                NSError *JSONSerializationError;
                id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONSerializationError];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    imgUrlString = [obj objectForKey:@"url"];
                }
            }
            // 成功回调
            // FIXME: ZYT uploadtask ？？？
            id<UploadItemProtocal, UploadItemCallBackProtocal> uploadItem = [self.uploadingTaskIDToUploadItemMap objectForKey:@(uploadtask.taskIdentifier)];
            if (uploadItem) {
                if ([uploadItem respondsToSelector:@selector(mm_uploadDone:)]) {
                    [uploadItem mm_uploadDone:imgUrlString];
                }
                [self.uploadingTaskIDToUploadItemMap removeObjectForKey:@(uploadtask.taskIdentifier)];
                [self.uploadingItems removeObject:uploadItem];
            }
        } else {
            id<UploadItemProtocal, UploadItemCallBackProtocal> uploadItem = [self.uploadingTaskIDToUploadItemMap objectForKey:@(uploadtask.taskIdentifier)];
            if (uploadItem) {
                if ([uploadItem respondsToSelector:@selector(mm_uploadFailed)]) {
                    [uploadItem mm_uploadFailed];
                }
                [self.uploadingTaskIDToUploadItemMap removeObjectForKey:@(uploadtask.taskIdentifier)];
                [self.uploadingItems removeObject:uploadItem];
            }
        }
       
        
        [self startNextUploadTask];
    }];
    [uploadtask resume];
    
    // 添加到映射中
    [self.uploadingTaskIDToUploadItemMap setObject:uploadItem forKey:@(uploadtask.taskIdentifier)];
}

- (void)defaultConfig {
    _maxUploadTask = 5;
}

/**
 上传请求配置bodyData
 */
-(NSData*)TSuploadTaskRequestBody:(NSData*)uploadData {
    NSMutableData* totlData=[NSMutableData new];
    NSDictionary* dictionary=@{@"name":@"testname",
                               @"APPversion":@"3.2.3",
                               @"serverIp":@"127.0.0.1",
                               @"clientType":@"2"};
    NSArray* allKeys=[dictionary allKeys];
    for (int i=0; i<allKeys.count; i++) {
        NSString *disposition = [NSString stringWithFormat:@"%@Content-Disposition: form-data; name=\"%@\"%@",StartBoundary,allKeys[i],Wrap2];
        NSString* object=[dictionary objectForKey:allKeys[i]];
        disposition =[disposition stringByAppendingString:object];
        disposition =[disposition stringByAppendingString:Wrap1];
        NSLog(@"%s\n%@",__FUNCTION__,disposition);
        [totlData appendData:[disposition dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *body=[NSString stringWithFormat:@"%@Content-Disposition: form-data; name=\"picture\"; filename=\"%@\";Content-Type:image/png%@",StartBoundary,@"demo_avatar_cook.png",Wrap2];
    [totlData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];

    [totlData appendData:uploadData];
    [totlData appendData:[Wrap1 dataUsingEncoding:NSUTF8StringEncoding]];
    [totlData appendData:[EndBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    return totlData;
}

/**
 上传请求配置
 */
-(NSMutableURLRequest*)TSuploadTaskRequest {
    NSString* uploadURLString = @"http://localhost:8080/JspJavaBeanDemo/servlet/UploadHandleServlet";
    
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadURLString]];
    request.HTTPMethod=@"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",Boundary] forHTTPHeaderField:@"Content-Type"];
    return request;
}


#pragma mark - ......::::::: NSURLSessionDelegate :::::::......

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"didCompleteWithError = %@",error.description);
    
    // 失败回调
    if (error) {
        id<UploadItemProtocal, UploadItemCallBackProtocal> uploadItem = [self.uploadingTaskIDToUploadItemMap objectForKey:@(task.taskIdentifier)];
        if (uploadItem) {
            if ([uploadItem respondsToSelector:@selector(mm_uploadFailed)]) {
                [uploadItem mm_uploadFailed];
            }
            [self.uploadingTaskIDToUploadItemMap removeObjectForKey:@(task.taskIdentifier)];
            [self.uploadingItems removeObject:uploadItem];
        }
    }
    
    [self startNextUploadTask];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    NSLog(@"bytesSent:%@-totalBytesSent:%@-totalBytesExpectedToSend:%@", @(bytesSent), @(totalBytesSent), @(totalBytesExpectedToSend));
    
    // 进度回调
    id<UploadItemProtocal, UploadItemCallBackProtocal> uploadItem = [self.uploadingTaskIDToUploadItemMap objectForKey:@(task.taskIdentifier)];
    if ([uploadItem respondsToSelector:@selector(mm_uploadProgress:)]) {
        [uploadItem mm_uploadProgress:(totalBytesSent * 1.0f/totalBytesExpectedToSend)];
    }

}

@end
