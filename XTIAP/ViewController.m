//
//  ViewController.m
//  XTIAP
//
//  Created by teason23 on 2019/8/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ViewController.h"
#import "XTIAP.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSSet *dataSet = [[NSSet alloc] initWithObjects:@"iap.octopus.month", nil] ;
    [[XTIAP sharedInstance] setup:dataSet] ;
    
//    [[XTIAP sharedInstance] requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
//
//        NSString *title = XT_STR_FORMAT(@"%@ 订阅 %@",[[XTIAP sharedInstance] getLocalePrice:response.products.firstObject],response.products.firstObject.localizedTitle) ;
//        NSLog(@"11%@",title) ;
//
//    }] ;
    
    

    
    
    [XTIAP sharedInstance].g_transactionBlock = ^(SKPaymentTransaction *transaction) {
        
        NSLog(@"transactionState %ld",(long)transaction.transactionState) ;
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            
            [[XTIAP sharedInstance] checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] sharedSecret:@"5498d6de8ace4f52acd789f795ee9a81" inDebugMode:YES onCompletion:^(NSDictionary *rec, NSError *error) {

                NSDictionary *dictLatestReceiptsInfo = rec[@"latest_receipt_info"];
                long long int expirationDateMs = [[dictLatestReceiptsInfo valueForKeyPath:@"@max.expires_date_ms"] longLongValue] ; // 结束时间
                long long requestDateMs = [rec[@"receipt"][@"request_date_ms"] longLongValue] ;//请求时间
                NSLog(@"%lld--%lld", expirationDateMs, requestDateMs) ;
                NSDate *resExpiraDate = [NSDate xt_getDateWithTick:(expirationDateMs / 1000.0)] ;
                NSLog(@"新订单截止到 : %@", resExpiraDate) ;
                
            }] ;
            
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            
        }
        
    } ;
    
    
    
    UIButton *bt = [UIButton new] ;
    [bt setTitle:@"buy ++" forState:0] ;
    bt.backgroundColor = [UIColor redColor] ;
    [self.view addSubview:bt] ;
    [bt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 40)) ;
        make.center.equalTo(self.view) ;
    }] ;
    [bt addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside] ;
}

- (void)buy {
    
    [[XTIAP sharedInstance] requestProductWithID:@"iap.octopus.month" complete:^(SKProduct *product) {
        
        NSString *title = XT_STR_FORMAT(@"%@ 订阅 %@",[[XTIAP sharedInstance] getLocalePrice:product], product.localizedTitle) ;
        NSLog(@"22%@",title) ;
        [[XTIAP sharedInstance] buyProduct:product] ;
    }] ;
}

@end
