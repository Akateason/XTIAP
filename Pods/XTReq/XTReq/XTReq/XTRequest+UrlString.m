//
//  XTRequest+UrlString.m
//  XTReq
//
//  Created by teason23 on 2018/2/23.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "XTRequest+UrlString.h"


@implementation XTRequest (UrlString)

+ (NSString *)getFinalUrlWithBaseUrl:(NSString *)baseUrlStr
                            trailStr:(NSString *)strPartOfUrl {
    return [baseUrlStr stringByAppendingString:strPartOfUrl];
}

+ (NSString *)getFinalUrlWithBaseUrl:(NSString *)baseUrlStr
                               param:(NSDictionary *)diction {
    return [baseUrlStr stringByAppendingString:[self getTrailUrlInGetReqModeWithDic:diction]];
}

+ (NSString *)getUniqueKeyWithUrl:(NSString *)url
                           header:(NSDictionary *)header
                            param:(NSDictionary *)param
                             body:(NSString *)body {
    NSString *finalUrl   = [self getFinalUrlWithBaseUrl:url param:param];
    if (header) finalUrl = [finalUrl stringByAppendingString:[NSString stringWithFormat:@"&%@", [self dicToString:header]]];
    if (body) finalUrl   = [finalUrl stringByAppendingString:[NSString stringWithFormat:@"&%@", body]];
    return finalUrl;
}

+ (NSString *)getTrailUrlInGetReqModeWithDic:(NSDictionary *)dict {
    NSArray *allKeys       = [dict allKeys];
    BOOL bFirst            = YES;
    NSString *appendingStr = @"";
    for (NSString *key in allKeys) {
        NSString *val  = [dict objectForKey:key];
        NSString *item = @"";
        if (bFirst) {
            bFirst = NO;
            item   = [NSString stringWithFormat:@"?%@=%@", key, val];
        }
        else {
            item = [NSString stringWithFormat:@"&%@=%@", key, val];
        }
        appendingStr = [appendingStr stringByAppendingString:item];
    }
    return appendingStr;
}

+ (NSString *)dicToString:(NSDictionary *)dic {
    NSString *result = @"";
    for (NSString *key in dic) {
        NSString *val = dic[key];
        result        = [result stringByAppendingString:[NSString stringWithFormat:@"&%@", val]];
    }
    return result;
}

@end
