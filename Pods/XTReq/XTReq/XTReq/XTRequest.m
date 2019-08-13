//
//  XTRequest
//
//  Created by teason on 15/11/12.
//  Copyright © 2015年 teason. All rights reserved.
//

#import "XTRequest.h"
#import "XTReqSessionManager.h"
#import "SVProgressHUD.h"
#import "YYModel.h"
#import "XTReqConst.h"


@implementation XTRequest

#pragma mark--
#pragma mark - util

+ (NSMutableDictionary *)getParameters {
    return [@{} mutableCopy];
}

+ (void)logTheReqInfoOfUrl:(NSString *)url
                      mode:(XTRequestMode)mode
                    header:(NSDictionary *)header
                     param:(NSDictionary *)param
                   rawbody:(NSString *)rawbody
                  response:(id)json
                     error:(NSError *)error {
    XTREQLog(@"\nURL: %@ ,\nmode: %@ ,\nheader: %@ ,\nparam: %@ ,\nbody: %@ ,\nsuccess: %@ ,\nfail: %@ \n", url, [self modeStr:mode], header, param, rawbody, [json yy_modelToJSONString], error);
}

+ (NSString *)modeStr:(XTRequestMode)mode {
    NSString *method = @"";
    switch (mode) {
        case XTRequestMode_GET_MODE: method    = @"GET"; break;
        case XTRequestMode_POST_MODE: method   = @"POST"; break;
        case XTRequestMode_PUT_MODE: method    = @"PUT"; break;
        case XTRequestMode_DELETE_MODE: method = @"DELETE"; break;
        case XTRequestMode_PATCH_MODE: method  = @"PATCH"; break;
        default:
            break;
    }
    return method;
}

#pragma mark - Cancel

+ (void)cancelAllRequest {
    XTREQLog(@"xtReq cancel all");
    [[XTReqSessionManager shareInstance].session
        getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *_Nonnull dataTasks,
                                        NSArray<NSURLSessionUploadTask *> *_Nonnull uploadTasks,
                                        NSArray<NSURLSessionDownloadTask *> *_Nonnull downloadTasks) {
            for (NSURLSessionDataTask *task in dataTasks) [task cancel];
        }];
}


//  async
#pragma mark--
#pragma mark - Async

+ (NSURLSessionDataTask *)reqWithUrl:(NSString *)url
                                mode:(XTRequestMode)mode
                              header:(NSDictionary *)header
                          parameters:(NSDictionary *)param
                             rawBody:(NSString *)rawBody
                                 hud:(BOOL)hud
                   completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if (hud) [SVProgressHUD show];
    });

    NSError *error;
    NSString *method = [self modeStr:mode];
    // url , param
    NSMutableURLRequest *request = [[XTReqSessionManager shareInstance].requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:url relativeToURL:[XTReqSessionManager shareInstance].baseURL] absoluteString] parameters:param error:&error];
    if (error) {
        if (completionHandler) {
            dispatch_async([XTReqSessionManager shareInstance].completionQueue ?: dispatch_get_main_queue(), ^{
                completionHandler(nil, nil, error);
            });
        }
        return nil;
    }

    // header
    if (header) {
        for (NSString *key in header) {
            [request setValue:header[key] forHTTPHeaderField:key];
        }
    }
    // body
    if (rawBody && rawBody.length > 0) {
        NSData *dataBody = [rawBody dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:dataBody];
    }

    NSURLSessionDataTask *task =
        [[XTReqSessionManager shareInstance] dataTaskWithRequest:request
                                                  uploadProgress:nil
                                                downloadProgress:nil
                                               completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {

                                                   if (hud) [SVProgressHUD dismiss];
                                                   [self logTheReqInfoOfUrl:url mode:mode header:header param:param rawbody:rawBody response:responseObject error:error];
                                                   [[XTReqSessionManager shareInstance] reset];

                                                   if (completionHandler) {
                                                       if (hud && error) {
                                                           [SVProgressHUD showErrorWithStatus:[XTReqSessionManager shareInstance].tipRequestFailed];
                                                       }
                                                       completionHandler(response, responseObject, error);
                                                   }
                                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                               }];
    [task resume];
    return task;
}

+ (NSURLSessionDataTask *)reqWithUrl:(NSString *)url
                                mode:(XTRequestMode)mode
                              header:(NSDictionary *)header
                          parameters:(NSDictionary *)param
                             rawBody:(NSString *)rawBody
                                 hud:(BOOL)hud
                             success:(void (^)(id json, NSURLResponse *response))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail {
    __block NSURLSessionDataTask *task =
        [self reqWithUrl:url mode:mode header:header parameters:param rawBody:rawBody hud:hud completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {

            if (error) {
                if (fail) fail(task, error);
            }
            else {
                if (success) success(responseObject, response);
            }
        }];
    return task;
}


#pragma mark--
#pragma mark - Sync

static inline dispatch_queue_t xt_getCompletionQueue() { return dispatch_queue_create("xt_ForAFnetworkingSync", NULL); }

// sync
+ (id)syncWithReqMode:(XTRequestMode)mode
                  url:(NSString *)url
               header:(NSDictionary *)header
           parameters:(NSDictionary *)dict {
    return [self syncWithReqMode:mode timeout:0 url:url header:header parameters:dict];
}

+ (id)syncWithReqMode:(XTRequestMode)mode
              timeout:(int)timeout
                  url:(NSString *)url
               header:(NSDictionary *)header
           parameters:(NSDictionary *)dict {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    __block id result           = nil;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        AFHTTPSessionManager *manager                     = [[AFHTTPSessionManager alloc] init];
        manager.requestSerializer                         = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer                        = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:ACCEPTABLE_CONTENT_TYPES, nil];
        manager.requestSerializer.timeoutInterval         = timeout ?: [XTReqSessionManager shareInstance].timeout;
        manager.completionQueue                           = xt_getCompletionQueue();
        if (header) {
            for (NSString *key in header) {
                [manager.requestSerializer setValue:header[key]
                                 forHTTPHeaderField:key];
            }
        }
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        switch (mode) {
            case XTRequestMode_GET_MODE: {
                [manager GET:url
                    parameters:dict
                    progress:nil
                    success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                        XTREQLog(@"url : %@ \n header : %@\n param : %@ \n resp \n %@", url, header, dict, [responseObject yy_modelToJSONString]);
                        result = responseObject;
                        dispatch_semaphore_signal(semaphore);
                    }
                    failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                        dispatch_semaphore_signal(semaphore);
                    }];
            } break;
            case XTRequestMode_POST_MODE: {
                [manager POST:url
                    parameters:dict
                    progress:nil
                    success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                        XTREQLog(@"url : %@ \n header : %@\n param : %@ \n resp \n %@ ", url, header, dict, [responseObject yy_modelToJSONString]);
                        result = responseObject;
                        dispatch_semaphore_signal(semaphore);
                    }
                    failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                        dispatch_semaphore_signal(semaphore);
                    }];
            } break;
            case XTRequestMode_PUT_MODE: {
                [manager PUT:url
                    parameters:dict
                    success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                        XTREQLog(@"url : %@ \n header : %@\n param : %@ \n resp \n %@", url, header, dict, [responseObject yy_modelToJSONString]);
                        result = responseObject;
                        dispatch_semaphore_signal(semaphore);
                    }
                    failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                        dispatch_semaphore_signal(semaphore);
                    }];
            } break;
            case XTRequestMode_DELETE_MODE: {
                [manager DELETE:url parameters:dict success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                    XTREQLog(@"url : %@ \n header : %@\n param : %@ \n resp \n %@", url, header, dict, [responseObject yy_modelToJSONString]);
                    result = responseObject;
                    dispatch_semaphore_signal(semaphore);
                } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                    dispatch_semaphore_signal(semaphore);
                }];
            } break;
            case XTRequestMode_PATCH_MODE: {
                [manager PATCH:url parameters:dict success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                    XTREQLog(@"url : %@ \n header : %@\n param : %@ \n resp \n %@", url, header, dict, [responseObject yy_modelToJSONString]);
                    result = responseObject;
                    dispatch_semaphore_signal(semaphore);
                } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                    dispatch_semaphore_signal(semaphore);
                }];
            } break;
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
    [operation start];
    [operation waitUntilFinished];

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    return result;
}

#pragma mark - upload download

+ (NSURLSessionUploadTask *)uploadFileWithData:(NSData *)fileData
                                        urlStr:(NSString *)urlString
                                        header:(NSDictionary *)header
                                      progress:(nullable void (^)(float))progressValueBlock
                                       success:(void (^)(NSURLResponse *response, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager             = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL                               = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request             = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    if (header) {
        for (NSString *key in header) {
            [request setValue:header[key] forHTTPHeaderField:key];
        }
    }

    __block NSURLSessionUploadTask *uploadTask =
        [manager uploadTaskWithRequest:request fromData:fileData progress:^(NSProgress *_Nonnull uploadProgress) {
            if (progressValueBlock) progressValueBlock(uploadProgress.fractionCompleted);
        } completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
            if (error) {
                XTREQLog(@"xt upload Error: %@", error);
                if (fail) fail(uploadTask, error);
            }
            else {
                XTREQLog(@"xt upload Success: %@", responseObject);
                if (success) success(response, responseObject);
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    [uploadTask resume];
    return uploadTask;
}

+ (NSURLSessionDownloadTask *)downLoadFileWithSavePath:(NSString *)savePath
                                         fromUrlString:(NSString *)urlString
                                                header:(NSDictionary *)header
                                      downLoadProgress:(void (^)(float progressVal))progress
                                               success:(void (^)(NSURLResponse *response, id dataFile))success
                                               failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))fail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url                   = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (header) {
        for (NSString *key in header.allKeys) {
            NSString *value = header[key];
            [request setValue:value forHTTPHeaderField:key];
        }
    }

    __block NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *_Nonnull downloadProgress) {
        XTREQLog(@"url: %@ \n下载进度：%.0f％", urlString, downloadProgress.fractionCompleted * 100);
        if (progress) progress(downloadProgress.fractionCompleted);
    } destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
        return [NSURL fileURLWithPath:savePath];
    } completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
        if (error) {
            XTREQLog(@"xt download fail error:%@ ", error);
            if (fail) fail(downloadTask, error);
        }
        else {
            XTREQLog(@"xt download success : %@", [response yy_modelToJSONString]);
            id file = [NSData dataWithContentsOfFile:savePath];
            if (success) success(response, file);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    }];
    [downloadTask resume];
    return downloadTask;
}


@end
