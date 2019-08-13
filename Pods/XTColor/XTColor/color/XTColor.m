//
//  XTColor.m
//  XTColor
//
//  Created by teason23 on 2018/3/15.
//  Copyright © 2018年 teason23. All rights reserved.
//

#import "XTColor.h"
#import "XTColorFetcher.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation XTColor

+ (void)configCustomPlistName:(NSString *)name {
    [[XTColorFetcher sharedInstance] configureCustomPlistWithFilePath:name] ;
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel) ;
    if ([[[XTColorFetcher sharedInstance].dicData allKeys] containsObject:selectorString]) {
        Method method = class_getClassMethod(self, @selector(autoFetchColor)) ;
        return class_addMethod(object_getClass(self) ,
                               sel ,
                               method_getImplementation(method) ,
                               method_getTypeEncoding(method)) ;
    }
    return [super resolveClassMethod:sel] ;
}

+ (instancetype)autoFetchColor {
    NSString *selectorString = NSStringFromSelector(_cmd) ;
    return (XTColor *)[[XTColorFetcher sharedInstance] xt_colorWithKey:selectorString] ;
}



@end
