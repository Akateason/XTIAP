//
//  XTColorFetcher.m
//
//  Created by teason on 16/8/16.
//  Copyright © 2016年 teason. All rights reserved.
//

#import "XTColorFetcher.h"
#import "UIColor+XTAddition.h"

static NSString *const kOriginalColorSourceName = @"XTColors" ;

@interface XTColorFetcher ()
@property (nonatomic,strong,readwrite) NSDictionary *dicData   ;
@property (nonatomic,copy)             NSString     *plistName ;
@end

@implementation XTColorFetcher

static XTColorFetcher *_instance ;

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init] ;
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return  _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return  _instance;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[XTColorFetcher alloc] init] ;
        _instance.plistName = kOriginalColorSourceName ; // in pod bundle .
    });
    return _instance ;
}

- (void)configureCustomPlistWithFilePath:(NSString *)filePath {
    self.plistName = filePath ;
    if (![filePath isEqualToString:kOriginalColorSourceName]) {
        [self appendData] ;
    }    
}

- (NSDictionary *)dicData {
    if (!_dicData) {
        _dicData = [self fromPlist] ;
    }
    return _dicData ;
}

- (void)appendData {
    NSMutableDictionary *tmpDic = [self.dicData mutableCopy] ;
    [tmpDic addEntriesFromDictionary:[self fromPlist]] ;
    self.dicData = [tmpDic copy] ;
}

- (NSDictionary *)fromPlist {
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.plistName ofType:@"plist"] ;  // deprecated, will cause a crash in pods. canot found resource .
    if (![self.plistName isEqualToString:kOriginalColorSourceName]) {
        // custom
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.plistName ofType:@"plist"] ;
        return [[NSDictionary alloc] initWithContentsOfFile:plistPath] ;
    }
    else {
        // in pod bundle .
        return [self getOriginPlist] ;
    }
}

- (NSDictionary *)getOriginPlist {
    NSString *plistPath = [[NSBundle bundleForClass:XTColorFetcher.class] pathForResource:kOriginalColorSourceName ofType:@"plist"] ;
    return [[NSDictionary alloc] initWithContentsOfFile:plistPath] ;
}

- (UIColor *)getColorWithRed:(float)fRed
                       green:(float)fGreen
                        Blue:(float)fBlue
{
    return [self getColorWithRed:fRed
                           green:fGreen
                            Blue:fBlue
                           alpha:1.0] ;
}

- (UIColor *)getColorWithRed:(float)fRed
                       green:(float)fGreen
                        Blue:(float)fBlue
                       alpha:(float)alpha
{
    return [UIColor colorWithRed:((float) fRed   / 255.0f)
                           green:((float) fGreen / 255.0f)
                            blue:((float) fBlue  / 255.0f)
                           alpha:alpha] ;
}

- (NSString *)dealString:(NSString *)string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
    string = [string stringByReplacingOccurrencesOfString:@"  " withString:@" "] ;
    string = [string stringByReplacingOccurrencesOfString:@"   " withString:@" "] ;
    string = [string stringByReplacingOccurrencesOfString:@"    " withString:@" "] ;
    if ([string hasSuffix:@","] || [string hasSuffix:@" "]) {
        string = [string substringToIndex:[string length] - 1] ;
    }
    return string ;
}

- (UIColor *)xt_colorWithKey:(NSString *)key {
    NSString *jsonStr = [[XTColorFetcher sharedInstance].dicData objectForKey:key] ;
    jsonStr = [self dealString:jsonStr] ;
    
    if ([jsonStr containsString:@"["]) {
        NSArray *colorValList = [self.class getJsonWithStr:jsonStr] ;
        return [self colorRGB:colorValList] ;
    }
    else if ([jsonStr containsString:@","]) {
        NSArray *commaList = [jsonStr componentsSeparatedByString:@","] ;
        return [self colorRGB:commaList] ;
    }
    else if ([jsonStr containsString:@" "]) {
        NSArray *spaceList = [jsonStr componentsSeparatedByString:@" "] ;
        return [self colorRGB:spaceList] ;
    }
    else {
        if ([UIColor colorWithHexString:jsonStr] && jsonStr) {
            return [UIColor colorWithHexString:jsonStr] ;
        }
        else {
            if (![self.plistName isEqualToString:kOriginalColorSourceName]) {
                //if in plist is custom not found .  to origin plist
                self.plistName = kOriginalColorSourceName ;
                [self appendData] ;
                return [self xt_colorWithKey:key] ;
            }
            else {
                return nil ;
            }
        }
        
    }
    
    
    return nil ;
}

- (UIColor *)colorRGB:(NSArray *)colorValList {
    if (colorValList.count == 3) {
        return [[XTColorFetcher sharedInstance] getColorWithRed:[colorValList[0] floatValue]
                                                 green:[colorValList[1] floatValue]
                                                  Blue:[colorValList[2] floatValue]] ;
    }
    else if (colorValList.count > 3) {
        return [[XTColorFetcher sharedInstance] getColorWithRed:[colorValList[0] floatValue]
                                                 green:[colorValList[1] floatValue]
                                                  Blue:[colorValList[2] floatValue]
                                                 alpha:[colorValList[3] floatValue]] ;
    }
    else if (colorValList.count == 2) {
        return [UIColor colorWithHexString:colorValList[0]
                                     alpha:[colorValList[1] floatValue]] ;
    }
    
    return nil ;
}

- (UIColor *)randomColor {
    return [self getColorWithRed:arc4random() % 256
                           green:arc4random() % 256
                            Blue:arc4random() % 256] ;
}

+ (id)getJsonWithStr:(NSString *)jsonStr {
    if (!jsonStr) return nil ;
    NSError *error ;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:0
                                                   error:&error] ;
    if (!jsonObj) {
        NSLog(@"error : %@",error) ;
        return nil ;
    }
    else {
        return jsonObj ;
    }
}

@end
