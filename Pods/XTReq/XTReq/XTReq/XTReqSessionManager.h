//
//  XTReqSessionManager.h
//  XTlib
//
//  Created by teason23 on 2017/5/12.
//  Copyright © 2017年 teason. All rights reserved.

// Global ACCEPT
#define ACCEPTABLE_CONTENT_TYPES @"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain"
#define XTReq_isDebug [XTReqSessionManager shareInstance].isDebug

#import <AFNetworking/AFNetworking.h>


@interface XTReqSessionManager : AFHTTPSessionManager
+ (instancetype)shareInstance;

// config settings
@property (nonatomic) BOOL isDebug;
@property (nonatomic) float timeout;
@property (copy, nonatomic) NSString *tipRequestFailed;
@property (copy, nonatomic) NSString *tipBadNetwork;

// clear session Mannager responseSerializer.acceptableContentTypes and http headers
- (void)reset;
@end
