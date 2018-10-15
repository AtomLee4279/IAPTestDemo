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

@class IAPClass;

@protocol IAPDelegate <NSObject>

@required

-(void) productsResponseDelegate:(NSString*)ResponseState withData:(nullable id)products;

-(void) transactionUpdateDelegate:(NSString*)transactionState withData:(nullable id)data;

@end

@interface IAPClass : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>


@property(weak,nonatomic) id<IAPDelegate> delegate;

@property(strong,nonatomic) NSArray *iapIds;

@property(strong,nonatomic) NSArray *iapProducts;



+ (instancetype)shareInstance;

- (void)requestProductsInfo:(NSArray *)productIds;

- (void)iapTestWithProductId:(NSString*)productId application_username:(NSString*)application_username;

@end

NS_ASSUME_NONNULL_END
