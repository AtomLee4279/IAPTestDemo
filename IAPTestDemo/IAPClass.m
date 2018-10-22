//
//  IAPClass.m
//  IAPTestDemo
//
//  Created by 李一贤 on 2018/10/12.
//  Copyright © 2018 李一贤. All rights reserved.
//

#import "IAPClass.h"
#import <CommonCrypto/CommonCrypto.h>


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
- (void)requestProductsInfo{
    NSLog(@"-------------请求对应的产品信息----------------");
    
    NSSet *nsset = [NSSet setWithArray:self.iapIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}


- (void)iapTestWithProductId:(NSString *)productId
        application_username:(NSString*)application_username{
    
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
//            payment.applicationUsername = [self hashedValueForAccountName:application_username];
            payment.applicationUsername = application_username;
            NSLog(@"点击具体商品applicationUserName:%@",payment.applicationUsername);
            // 添加到制服队列
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        
    }
}


// Custom method to calculate the SHA-256 hash using Common Crypto
//安全散列算法：苹果推荐，用来加密application_username
- (NSString *)hashedValueForAccountName:(NSString*)userAccountName
{
    const int HASH_SIZE = 32;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [userAccountName UTF8String];
    size_t accountNameLen = strlen(accountName);
    
    // Confirm that the length of the user name is small enough
    // to be recast when calling the hash function.
    if (accountNameLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", userAccountName);
        return nil;
    }
    CC_SHA256(accountName, (CC_LONG)accountNameLen, hashedChars);
    
    // Convert the array of bytes into a string showing its hex representation.
    NSMutableString *userAccountHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }
    
    return userAccountHash;
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
                NSLog(@"交易完成:paymentQueue:currentTransaction.payment.applicationUsername:%@",tran.payment.applicationUsername);
                self.currentTransaction = tran;
                NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
                if ([self.delegate respondsToSelector:@selector(transactionPurchasedDelegate:withData:)]){
                    
                    [self.delegate transactionPurchasedDelegate:tran withData:receiptData];
                    
                }
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
                
                NSLog(@"交易失败:%@",SKErrorDomain);
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                if ([self.delegate respondsToSelector:@selector(transactionPurchasedDelegate:withData:)]){
                    
                    [self.delegate transactionPurchasedDelegate:tran withData:SKErrorDomain];
                    
                }
                //关闭交易
            }
                break;
            default:
                break;
        }
    }
}

//- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product{
//    NSLog(@"==shouldAddStorePayment==");
//    return YES;
//}

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
