//
//  XTColor.h
//  XTColor
//
//  Created by teason23 on 2018/3/15.
//  Copyright © 2018年 teason23. All rights reserved.
//


#import "UIColor+XTColors.h"
#import "XTColorFetcher.h"
#import "UIColor+XTAddition.h"


#define UIColorRGBA(r, g, b, a)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define UIColorRGB(r, g, b)             UIColorRGBA(r, g, b, 1.0)


#define UIColorHex(X)                   [UIColor colorWithHexString:X]
#define UIColorHexA(X,a)                [UIColor colorWithHexString:X alpha:a]


@interface XTColor : UIColor

+ (void)configCustomPlistName:(NSString *)name ;

@end
