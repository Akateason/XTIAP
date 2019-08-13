//
//  AppDelegate.m
//  XTRequest
//
//  Created by teason on 15/11/12.
//  Copyright © 2015年 teason. All rights reserved.
// XTRequest
// 1. share one manager .
// 2. async and sync .
// 3. Get/Post/Put , fast append HTTP header / formdata / rawbody
// 4. log success or failure
// 5. show hud
// 6. cancel req


#import "XTReqSessionManager.h"
@class NSURLSessionDataTask;

// req mode
typedef NS_ENUM(NSInteger, XTRequestMode) {
    XTRequestMode_GET_MODE,
    XTRequestMode_POST_MODE,
    XTRequestMode_PUT_MODE,
    XTRequestMode_DELETE_MODE,
    XTRequestMode_PATCH_MODE,
};

// get PARAM
#define XT_GET_PARAM NSMutableDictionary *param = [XTRequest getParameters];


@interface XTRequest : XTReqSessionManager
+ (NSMutableDictionary *)getParameters;
+ (void)cancelAllRequest;

#pragma mark - async
+ (NSURLSessionDataTask *)reqWithUrl:(NSString *)url
                                mode:(XTRequestMode)mode
                              header:(NSDictionary *)header
                          parameters:(NSDictionary *)param
                             rawBody:(NSString *)rawBody
                                 hud:(BOOL)hud
                   completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

+ (NSURLSessionDataTask *)reqWithUrl:(NSString *)url
                                mode:(XTRequestMode)mode
                              header:(NSDictionary *)header
                          parameters:(NSDictionary *)param
                             rawBody:(NSString *)rawBody
                                 hud:(BOOL)hud
                             success:(void (^)(id json, NSURLResponse *response))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail;

#pragma mark - sync
+ (id)syncWithReqMode:(XTRequestMode)mode
              timeout:(int)timeout
                  url:(NSString *)url
               header:(NSDictionary *)header
           parameters:(NSDictionary *)dict;

+ (id)syncWithReqMode:(XTRequestMode)mode
                  url:(NSString *)url
               header:(NSDictionary *)header
           parameters:(NSDictionary *)dict;

#pragma mark - upload download
// UPLOAD one File
+ (NSURLSessionUploadTask *)uploadFileWithData:(NSData *)fileData
                                        urlStr:(NSString *)urlString
                                        header:(NSDictionary *)header
                                      progress:(nullable void (^)(float))progressValueBlock
                                       success:(void (^)(NSURLResponse *response, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail;
// DOWNLOAD one File
+ (NSURLSessionDownloadTask *)downLoadFileWithSavePath:(NSString *)savePath
                                         fromUrlString:(NSString *)urlString
                                                header:(NSDictionary *)header
                                      downLoadProgress:(void (^)(float progressVal))progress
                                               success:(void (^)(NSURLResponse *response, id dataFile))success
                                               failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))fail;

@end
