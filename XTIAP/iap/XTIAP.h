//
//  XTIAP.h
//  XTIAP
//
//  Created by teason23 on 2019/8/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"
#import <XTlib/XTlib.h>

typedef void (^IAPProductsResponseBlock)(SKProductsRequest* request , SKProductsResponse* response);

typedef void (^IAPSKPaymentTransactionValueChangedBlock)(SKPaymentTransaction* transaction);

typedef void (^checkReceiptCompleteResponseBlock)(NSDictionary *json,NSError* error);

typedef void (^resoreProductsCompleteResponseBlock) (SKPaymentQueue* payment,NSError* error);


@interface XTIAP : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
XT_SINGLETON_H(XTIAP)

@property (nonatomic, copy)  NSSet              *productIdentifiers ;
@property (nonatomic, copy)  NSArray            *products ;
@property (nonatomic,strong) SKProductsRequest  *request ;
// global block transaction call back
@property (nonatomic,copy) IAPSKPaymentTransactionValueChangedBlock g_transactionBlock ;

// init With Product Identifiers
- (void)setup:(NSSet *)productIdentifiers ;

//get Products List
- (void)requestProductsWithCompletion:(IAPProductsResponseBlock)completion ;
//get one product .
- (void)requestProductWithID:(NSString *)identifier complete:(void(^)(SKProduct *product))completion ;

//Buy Product
- (void)buyProduct:(SKProduct *)product ;

//restore Products
//- (void)restoreProductsWithCompletion:(resoreProductsCompleteResponseBlock)completion;

//check receipt
- (void)checkReceipt:(NSData *)receiptData
        sharedSecret:(NSString *)secretKey
         inDebugMode:(BOOL)inDebugMode
        onCompletion:(checkReceiptCompleteResponseBlock)completion ;

// get local price
- (NSString *)getLocalePrice:(SKProduct *)product ;

@end


