//
//  XTRequest+Reachability.h
//  XTReq
//
//  Created by teason23 on 2018/9/10.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "XTRequest.h"


@interface XTRequest (Reachability)

+ (void)startMonitor;
+ (void)stopMonitor;
+ (NSString *)netWorkStatus;
+ (BOOL)isWifi;
+ (BOOL)isReachable;

@end
