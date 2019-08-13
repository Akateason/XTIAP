//
//  XTRequest+UrlString.h
//  XTReq
//
//  Created by teason23 on 2018/2/23.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "XTRequest.h"


@interface XTRequest (UrlString)

+ (NSString *)getFinalUrlWithBaseUrl:(NSString *)baseUrlStr
                            trailStr:(NSString *)strPartOfUrl;

+ (NSString *)getFinalUrlWithBaseUrl:(NSString *)baseUrlStr
                               param:(NSDictionary *)diction;

+ (NSString *)getUniqueKeyWithUrl:(NSString *)url
                           header:(NSDictionary *)header
                            param:(NSDictionary *)param
                             body:(NSString *)body;

+ (NSString *)getTrailUrlInGetReqModeWithDic:(NSDictionary *)dict;

@end
