//
//  IAPClass.m
//  IAPTestDemo
//
//  Created by 李一贤 on 2018/10/12.
//  Copyright © 2018 李一贤. All rights reserved.
//

#import "IAPClass.h"



@implementation IAPClass

#pragma mark - private method

+ (instancetype)shareInstance{
    static IAPClass *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [IAPClass new];
    });
    return instance;
}


//去苹果服务器请求商品
- (void)requestProductsInfo:(NSArray *)productIds{
    NSLog(@"-------------请求对应的产品信息----------------");
    
    NSSet *nsset = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}


- (void)iapTestWithProductId:(NSString *)productId{
    
    if (!self.iapProducts) {
        NSLog(@"iapTestWithProductId:从苹果服务器反馈回来的商品列表为空！");
    }
    for (SKProduct *pro in self.iapProducts){
        if ([pro.productIdentifier isEqualToString:productId]) {
            NSLog(@"===点击了具体商品:创建制服票据对象前：即将打印创建支付凭据的对象信息:===\n");
            NSLog(@"%@", [pro description]);
            NSLog(@"%@", [pro localizedTitle]);
            NSLog(@"%@", [pro localizedDescription]);
            NSLog(@"%@", [pro price]);
            NSLog(@"%@", [pro productIdentifier]);
            // 下面两句代码将创建制服票据对象,弹出支付流程相关的操作窗口
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:pro];
            // 添加到制服队列
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        
    }
}

#pragma mark  - SKProductsRequestDelegate Delegate Implementation
//收到苹果返回的商品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSArray *products = response.products;
    if([products count] == 0){
        NSLog(@"未找到该商品");
        return;
    }
    self.iapProducts = products;
    NSLog(@"--------------收到产品反馈消息:---------------------\n%@",self.iapProducts);
    
    if ([self.delegate respondsToSelector:@selector(productsResponseDelegate:withData:)]){
        
        [self.delegate productsResponseDelegate:@"收到产品反馈消息" withData:self.iapProducts];
        
    }
}

//请求失败: 这里容易报错：无法连接到i s
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    if ([self.delegate respondsToSelector:@selector(productsResponseDelegate:withData:)]){
        
        [self.delegate productsResponseDelegate:@"request-didFailWithError" withData:error];
        
    }
}


#pragma mark  - SKPaymentTransactionObserver Delegate Implementation

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    //菊花去掉
    NSLog(@"PaymentQueue:viewController:self%@",self);
//    [self finishProgressAnimation];
    //    注意在模拟器上测试,交易永远都是失败的
    for (SKPaymentTransaction *tran in transactions) {
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                
                // 发送到苹果服务器验证凭证：不再验证购买，而是让后台做这件事情
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                //                [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                //                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                // 恢复购买
                
            }
                break;
                
            case SKPaymentTransactionStateDeferred: {
                NSLog(@"SKPaymentTransactionStateDeferred：The transaction is in the queue, but its final status is pending external action.");
                
                
            }
                break;
                
            case SKPaymentTransactionStateFailed: {
                
                NSLog(@"交易失败");
                //关闭交易
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark  - Getter & Setter

-(NSArray*)iapIds{
    if (_iapIds) {
        return _iapIds;
    }
    _iapIds = @[
                @"com.gold.coin100",//6元
                @"com.gold.coin98",//98元
                @"com.gold.coin500",//50元
                @"com.gold.coin1980",//198元
                ];
    return _iapIds;
}

@end
