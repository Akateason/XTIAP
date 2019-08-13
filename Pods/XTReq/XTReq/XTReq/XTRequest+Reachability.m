//
//  XTRequest+Reachability.m
//  XTReq
//
//  Created by teason23 on 2018/9/10.
//  Copyright © 2018年 teaason. All rights reserved.
//

#import "XTRequest+Reachability.h"


@implementation XTRequest (Reachability)

+ (void)startMonitor {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)stopMonitor {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (NSString *)netWorkStatus {
    return [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
}

+ (BOOL)isWifi {
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}

+ (BOOL)isReachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

@end
