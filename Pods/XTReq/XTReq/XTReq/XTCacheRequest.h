//
//  XTCacheRequest.h
//  XTlib
//
//  Created by teason23 on 2017/5/8.
//  Copyright © 2017年 teason. All rights reserved.
// XTCacheRequest
//  1. Persistent save the response of requests .
//  2. three policy for how you save requests .
//  3. can control save or not when server crashed or bug .

#import "XTRequest.h"
#import "XTResponseDBModel.h"

typedef NS_ENUM(NSUInteger, XTReqSaveJudgment) {
    XTReqSaveJudgment_willSave = 0,
    XTReqSaveJudgment_NotSave  = 1,
};


@interface XTCacheRequest : XTRequest

#pragma mark - config
/**
 config when App is launching .
 @param dbPath      local path string .
 */
+ (void)configXTCacheReqWhenAppDidLaunchWithDBPath:(NSString *)dbPath;


#pragma mark - cache req
/**
 XTCacheRequest judgeResult designated MAIN FUNC
 
 @param reqMode         XTRequestMode               get / post mode .
 @param url             string
 @param hud             bool
 @param header          dic                         HTTP header if has .
 @param param           dic                         param if has .
 @param body            str                         post rawbody if has .
 @param cachePolicy     XTReqPolicy                 req policy .
 @param overTimeIfNeed   INT (seconds)               only in XTReqPolicyOverTime mode .
 @param completion      (XTReqSaveJudgment(^)(BOOL isNewest, id json))completion
                PARAM  isNewest          : isCacheOrNewest
                PARAM  json              : respObj
                RETURN XTReqSaveJudgment : judge If Need Cache
 */
+ (void)cachedReq:(XTRequestMode)reqMode
              url:(NSString *)url
              hud:(BOOL)hud
           header:(NSDictionary *)header
            param:(NSDictionary *)param
             body:(NSString *)body
           policy:(XTReqPolicy)cachePolicy
   overTimeIfNeed:(int)overTimeIfNeed
      judgeResult:(XTReqSaveJudgment (^)(BOOL isNewest, id json))completion;

/**
 XTCacheRequest completion MAIN FUNC
*/
+ (void)cachedReq:(XTRequestMode)reqMode
              url:(NSString *)url
              hud:(BOOL)hud
           header:(NSDictionary *)header
            param:(NSDictionary *)param
             body:(NSString *)body
           policy:(XTReqPolicy)cachePolicy
   overTimeIfNeed:(int)overTimeIfNeed
       completion:(void (^)(BOOL isNewest, id json))completion;

/**
 judgeResult with default policy
 */
+ (void)cachedReq:(XTRequestMode)reqMode
              url:(NSString *)url
              hud:(BOOL)hud
           header:(NSDictionary *)header
            param:(NSDictionary *)param
             body:(NSString *)body
      judgeResult:(XTReqSaveJudgment (^)(BOOL isNewest, id json))completion;

@end
