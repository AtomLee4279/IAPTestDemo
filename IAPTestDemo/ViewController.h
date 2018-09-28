//
//  ViewController.h
//  IAPTestDemo
//
//  Created by 李一贤 on 2018/9/28.
//  Copyright © 2018 李一贤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@interface ViewController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver,UITableViewDataSource,UITableViewDelegate>

+ (instancetype)getInstance;

+ (instancetype)shareInstance;


@end

