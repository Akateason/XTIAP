//
//  XTIAP.m
//  XTIAP
//
//  Created by teason23 on 2019/8/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTIAP.h"



@interface XTIAP ()
@property (nonatomic,copy) IAPProductsResponseBlock             requestProductsBlock ;
@property (nonatomic,copy) resoreProductsCompleteResponseBlock  restoreCompletedBlock ;
@property (nonatomic,copy) checkReceiptCompleteResponseBlock    checkReceiptCompleteBlock ;
@property (nonatomic,strong) NSMutableData                      *receiptRequestData ;
@property (nonatomic,copy) RefreshReceiptBlock                  refreshReceiptBlock ;

@property (nonatomic,strong) NSData *m_receiptData ;
@property (nonatomic,copy) NSString *m_secretKey ;
@property (nonatomic) BOOL m_isExcludeOld ;
@end


@implementation XTIAP
XT_SINGLETON_M(XTIAP)

#pragma mark - life

- (void)dealloc {
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self] ;
    }
}

- (void)setup:(NSSet *)productIdentifiers {
    _productIdentifiers = productIdentifiers ;
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self] ;
    }
}

#pragma mark --
#pragma mark - func

- (void)requestProductsWithCompletion:(IAPProductsResponseBlock)completion {
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] ;
    _request.delegate = self ;
    self.requestProductsBlock = completion ; //SKProductsRequestDelegate
    [_request start] ;
}

- (void)requestProductWithID:(NSString *)identifier complete:(void(^)(SKProduct *product))completion {
    [self requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
        if (response > 0) {
            for (SKProduct *product in response.products) {
                if ([product.productIdentifier isEqualToString:identifier]) {
                    if (completion) completion(product) ;
                }
            }
        }
    }] ;
}

- (void)buyProduct:(SKProduct *)product {
    self.restoreCompletedBlock = nil;
    SKPayment *payment = [SKPayment paymentWithProduct:product] ;
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] addPayment:payment] ; //SKPaymentTransactionObserver
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    if ([SKPaymentQueue defaultQueue] && !self.isManuallyFinishTransaction) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    if ([SKPaymentQueue defaultQueue] && !self.isManuallyFinishTransaction) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@ %ld", transaction.error.localizedDescription,(long)transaction.error.code);
    }
    
    if ([SKPaymentQueue defaultQueue] && !self.isManuallyFinishTransaction) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
} ;

+ (NSString *)base64StringFromData:(NSData *)data length:(long)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}



- (void)checkReceipt:(NSData *)receiptData
        sharedSecret:(NSString *)secretKey
          excludeOld:(BOOL)isExcludeOld
         inDebugMode:(BOOL)inDebugMode
        onCompletion:(checkReceiptCompleteResponseBlock)completion {
    
    if (!receiptData) return ;

    self.checkReceiptCompleteBlock = completion;
    self.m_receiptData = receiptData ;
    self.m_secretKey = secretKey ;
    self.m_isExcludeOld = isExcludeOld ;
    
/*
 https://stackoverflow.com/questions/32836058/ios-receipt-validation-error-21002
 解决21002报错
    exception = "com.apple.its.drm.InvalidDrmArgumentException";
    status = 21002;
 */
    NSString *receiptBase64 = [self.class base64StringFromData:receiptData length:[receiptData length]] ;
    
    NSMutableDictionary *dicBody = [@{@"receipt-data":receiptBase64 ,
                                      @"exclude-old-transactions":@(isExcludeOld ? 1 : 0)} mutableCopy] ;
    if (secretKey != nil) {
        [dicBody setObject:secretKey forKey:@"password"] ;
    }
    
    NSString *url = nil ;
    if (inDebugMode) url = @"https://sandbox.itunes.apple.com/verifyReceipt" ;
    else url = @"https://buy.itunes.apple.com/verifyReceipt" ;
    
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:dicBody
                                    options:NSJSONWritingPrettyPrinted
                                      error:nil] ;

    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]] ;
    [req setHTTPMethod:@"POST"] ;
    [req setHTTPBody:jsonData] ;
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        self.receiptRequestData = [[NSMutableData alloc] init];
    }
    else {
        NSError *error = nil;
        NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
        [errorDetail setValue:@"Can't create connection" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
        if(_checkReceiptCompleteBlock) {
            _checkReceiptCompleteBlock(nil,error);
        }
    }

//xtreq有bug换成原生的请求.
//    [XTRequest reqWithUrl:url mode:XTRequestMode_POST_MODE header:nil parameters:nil rawBody:[dicBody yy_modelToJSONString] hud:NO success:^(id json, NSURLResponse *response) {
//        NSLog(@"checkReceipt : %@",json) ;
//        NSInteger status = [json[@"status"] integerValue]  ;
//        if (status == 21007) { // testFlight问题,在product包中使用沙盒.
//            [self checkReceipt:receiptData sharedSecret:secretKey excludeOld:isExcludeOld inDebugMode:YES onCompletion:completion] ;
//        }
//        else {
//            if (self.checkReceiptCompleteBlock) {
//                self.checkReceiptCompleteBlock(json, nil) ;
//            }
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        if (self.checkReceiptCompleteBlock) {
//            self.checkReceiptCompleteBlock(nil, error) ;
//        }
//    }] ;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Cannot transmit receipt data. %@",[error localizedDescription]);
    if(_checkReceiptCompleteBlock) {
        _checkReceiptCompleteBlock(nil,error);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receiptRequestData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receiptRequestData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *response = [[NSString alloc] initWithData:self.receiptRequestData encoding:NSUTF8StringEncoding];
    NSDictionary *json = [self.class dictionaryWithJsonString:response] ;

    NSInteger status = [json[@"status"] integerValue]  ;
    if (status == 21007) { // testFlight问题,在product包中使用沙盒.
        [self checkReceipt:self.m_receiptData sharedSecret:self.m_secretKey excludeOld:self.m_isExcludeOld inDebugMode:YES onCompletion:self.checkReceiptCompleteBlock] ;
    }
    else {
        if (self.checkReceiptCompleteBlock) {
            if (!json) { // fail 收据为空，刷新收据 如果收据无效或丢失，请使用此API请求新收据。在沙盒环境中，您可以使用任何属性组合请求收据，以测试与批量采购计划收据相关的状态转换。 https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest/1506038-initwithreceiptproperties?language=objc

                @weakify(self)
                [self refreshReceipt:^(NSData *receiptData) {
                    @strongify(self)
                    self.m_receiptData = receiptData ;
                    [self checkReceipt:receiptData sharedSecret:self.m_secretKey excludeOld:self.m_isExcludeOld inDebugMode:YES onCompletion:self.checkReceiptCompleteBlock] ;
                }] ;
            }
            else { // success
                self.checkReceiptCompleteBlock(json, nil) ;
            }
        }
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


- (NSString *)getLocalePrice:(SKProduct *)product {
    if (product) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:product.priceLocale];
        
        return [formatter stringFromNumber:product.price];
    }
    return @"";        
}

#pragma mark --

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    self.request = nil  ;
    if(_requestProductsBlock) {
        _requestProductsBlock(request,response);
    }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        if (self.g_transactionBlock) self.g_transactionBlock(transaction) ;
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

#pragma mark ====  刷新凭证
- (void)refreshReceipt:(RefreshReceiptBlock)block {
    self.refreshReceiptBlock = block ;
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
    request.delegate = self ;
    [request start] ;
}

#pragma mark - ================ SKRequestDelegate =================
- (void)requestDidFinish:(SKRequest *)request {
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        self.refreshReceiptBlock(receiptData) ;
    }
}



@end
