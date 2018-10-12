//
//  IAPClass.h
//  IAPTestDemo
//
//  Created by 李一贤 on 2018/10/12.
//  Copyright © 2018 李一贤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface IAPClass : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property(strong,nonatomic) NSArray *iapIds;

@property(strong,nonatomic) NSArray *iapProducts;

- (void)requestProductsInfo:(NSArray *)productIds;

- (void)iapTestWithProductId:(NSString*)productId;

@end

NS_ASSUME_NONNULL_END
