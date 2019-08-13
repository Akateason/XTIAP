//
//  UIColor+XTAddition.m
//  XTColor
//
//  Created by teason23 on 2018/5/29.
//  Copyright © 2018年 teason23. All rights reserved.
//

#import "UIColor+XTAddition.h"
#import <CoreImage/CoreImage.h>

@implementation UIColor (XTAddition)

+ (UIColor *)colorBetweengGradientColor:(UIColor *)startColor
                               andColor:(UIColor *)endColor
                                percent:(CGFloat)percent
{
    CIColor *ciStart = [CIColor colorWithCGColor:startColor.CGColor] ;
    CIColor *ciEnd = [CIColor colorWithCGColor:endColor.CGColor] ;
    
    double resultRed = ciStart.red + percent * (ciEnd.red - ciStart.red);
    double resultGreen = ciStart.green + percent * (ciEnd.green - ciStart.green);
    double resultBlue = ciStart.blue + percent * (ciEnd.blue - ciStart.blue);
    return [UIColor colorWithRed:(resultRed) green:(resultGreen) blue:(resultBlue) alpha:(1.0)] ;
}

@end



@implementation UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)color {
    return  color ? [self colorWithHexString:color alpha:1.] : nil ;
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(float)alpha {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

@end
