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
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
    }
    
    if (self.g_transactionBlock) {
        self.g_transactionBlock(transaction);
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
    if (self.g_transactionBlock) {
        self.g_transactionBlock(transaction);
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@ %ld", transaction.error.localizedDescription,(long)transaction.error.code);
    }
    
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        
        if (self.g_transactionBlock) {
            self.g_transactionBlock(transaction);
        }
    }
}


- (void)checkReceipt:(NSData *)receiptData
        sharedSecret:(NSString *)secretKey
          excludeOld:(BOOL)isExcludeOld
         inDebugMode:(BOOL)inDebugMode
        onCompletion:(checkReceiptCompleteResponseBlock)completion {
    
    self.checkReceiptCompleteBlock = completion;
    
    NSString *receiptBase64 = [receiptData base64EncodedString] ;
    NSMutableDictionary *dicBody = [@{@"receipt-data":receiptBase64 ,
                                      @"exclude-old-transactions":@(isExcludeOld ? 1 : 0)} mutableCopy] ;
    if (secretKey != nil) {
        [dicBody setObject:secretKey forKey:@"password"] ;
    }
    
    NSString *url = nil ;
    if (inDebugMode) url = @"https://sandbox.itunes.apple.com/verifyReceipt" ;
    else url = @"https://buy.itunes.apple.com/verifyReceipt" ;
    
    [XTRequest reqWithUrl:url mode:XTRequestMode_POST_MODE header:nil parameters:nil rawBody:[dicBody yy_modelToJSONString] hud:NO success:^(id json, NSURLResponse *response) {
        NSLog(@"checkReceipt : %@",json) ;
        NSInteger status = [json[@"status"] integerValue]  ;
        if (status == 21007) { // testFlight问题,在product包中使用沙盒.
            [self checkReceipt:receiptData sharedSecret:secretKey excludeOld:isExcludeOld inDebugMode:YES onCompletion:completion] ;
        }
        else {
            if (self.checkReceiptCompleteBlock) {
                self.checkReceiptCompleteBlock(json, nil) ;
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (self.checkReceiptCompleteBlock) {
            self.checkReceiptCompleteBlock(nil, error) ;
        }
    }] ;
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

@end
