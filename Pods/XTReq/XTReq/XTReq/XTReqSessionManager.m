//
//  XTReqSessionManager.m
//  XTlib
//
//  Created by teason23 on 2017/5/12.
//  Copyright © 2017年 teason. All rights reserved.
//


#import "XTReqSessionManager.h"

// Global timeout
static const float kTIMEOUT = 15.f;


@implementation XTReqSessionManager
static XTReqSessionManager *_instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance                                           = [[XTReqSessionManager alloc] initWithBaseURL:nil];
        _instance.requestSerializer                         = [AFHTTPRequestSerializer serializer];
        _instance.responseSerializer                        = [AFJSONResponseSerializer serializer];
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:ACCEPTABLE_CONTENT_TYPES, nil];
        _instance.requestSerializer.timeoutInterval         = kTIMEOUT;
        _instance.completionQueue                           = NULL;
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

#pragma mark -
- (float)timeout {
    if (!_timeout) {
        _timeout = kTIMEOUT;
    }
    return _timeout;
}

- (NSString *)tipRequestFailed {
    if (!_tipRequestFailed) {
        _tipRequestFailed = @"网络不太通畅..."; //请求失败
    }
    return _tipRequestFailed;
}

- (NSString *)tipBadNetwork {
    if (!_tipBadNetwork) {
        _tipBadNetwork = @"网络未连接, 请检查您的网络...";
    }
    return _tipBadNetwork;
}

#pragma mark -
// reset manager for share next time .
- (void)reset {
    self.requestSerializer                         = [AFHTTPRequestSerializer serializer];
    self.responseSerializer                        = [AFJSONResponseSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:ACCEPTABLE_CONTENT_TYPES, nil];
    self.requestSerializer.timeoutInterval         = kTIMEOUT;
    self.completionQueue                           = NULL;
}


@end
