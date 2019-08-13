//
//  XTResponseDBModel.h
//  XTlib
//
//  Created by teason23 on 2017/5/10.
//  Copyright © 2017年 teason. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 XTResponseCacheType
 -  XTResponseCachePolicyNeverUseCache                  从不缓存适合每次都实时的数据流.
 -  XTResponseCachePolicyAlwaysCache                    总是获取缓存的数据.不再更新.
 -  XTResponseCachePolicyTimeout                        规定时间内.返回缓存.超时则更新数据. 需设置timeout时间. timeout默认1小时
 */
typedef NS_OPTIONS(NSUInteger, XTResponseCachePolicy) {
    XTResponseCachePolicyNeverUseCache = 1 << 0, // DEFAULT
    XTResponseCachePolicyAlwaysCache   = 1 << 1,
    XTResponseCachePolicyOverTime      = 1 << 2,
};

/**
 XTReturnPolicy
 - XTResponseReturnPolicyWaitUtilReqDone:               等待请求返回
 - XTResponseReturnPolicyImmediatelyReturnThenUpdate:   立即返回缓存如果有,然后请求最新结果返回.
 */
typedef NS_OPTIONS(NSUInteger, XTReturnPolicy) {
    XTResponseReturnPolicyWaitUtilReqDone             = 1 << 10, // DEFAULT
    XTResponseReturnPolicyImmediatelyReturnThenUpdate = 1 << 11,
};

/*****************************************************
 ******XTReqPolicy*****************MAIN policy********
 *****************************************************
 */
typedef NS_OPTIONS(NSUInteger, XTReqPolicy) {
    XTReqPolicy_NeverCache_WaitReturn  = XTResponseCachePolicyNeverUseCache | XTResponseReturnPolicyWaitUtilReqDone, // DEFAULT
    XTReqPolicy_AlwaysCache_WaitReturn = XTResponseCachePolicyAlwaysCache | XTResponseReturnPolicyWaitUtilReqDone,
    XTReqPolicy_OverTime_WaitReturn    = XTResponseCachePolicyOverTime | XTResponseReturnPolicyWaitUtilReqDone,

    XTReqPolicy_NeverCache_IRTU  = XTResponseCachePolicyNeverUseCache | XTResponseReturnPolicyImmediatelyReturnThenUpdate,
    XTReqPolicy_AlwaysCache_IRTU = XTResponseCachePolicyAlwaysCache | XTResponseReturnPolicyImmediatelyReturnThenUpdate,
    XTReqPolicy_OverTime_IRTU    = XTResponseCachePolicyOverTime | XTResponseReturnPolicyImmediatelyReturnThenUpdate,
};


@interface XTResponseDBModel : NSObject

@property (nonatomic, copy) NSString *requestUrl; // as UNIQUE KEY
@property (nonatomic, copy) NSString *response;   // response string

@property (nonatomic) NSUInteger cachePolicy; // XTReqPolicy !!!

@property (nonatomic) int overTimeSec; // overTime rate(Seconds). DEFAULT is 1 hour .

// new a Default Model
+ (instancetype)newDefaultModelWithKey:(NSString *)urlStr
                                   val:(NSString *)respStr;

+ (instancetype)newDefaultModelWithKey:(NSString *)urlStr
                                   val:(NSString *)respStr
                                policy:(int)policy
                              overTime:(int)timeout;
// is overTime ?
- (BOOL)isOverTime;

// decode Response
- (NSString *)decodeResponse; // 如果插入时经过单引号转义. 获取时用这个方法获得Response .

@end
