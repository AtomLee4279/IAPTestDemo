//
//  ViewController.m
//  IAPTestDemo
//
//  Created by 李一贤 on 2018/9/28.
//  Copyright © 2018 李一贤. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
@interface ViewController ()

@property(strong,nonatomic) NSArray *iapIds;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

+ (instancetype)getInstance {
    
    static ViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super new];
    });
    return instance;
}

+ (instancetype)shareInstance {
    
    return [self getInstance];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self requestProductId:self.iapIds];
}

//去苹果服务器请求商品
- (void)requestProductId:(NSArray *)productIds{
    NSLog(@"-------------请求对应的产品信息----------------");
    
    NSSet *nsset = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

#pragma mark  - SKProductsRequestDelegate Delegate Implementation

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
}


#pragma mark  - SKPaymentTransactionObserver Delegate Implementation

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
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

#pragma mark  - TableViewDataSource Delegate Implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.iapIds.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *ID = @"iapId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:ID];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (cell.textLabel.text.length) {
        cell.textLabel.text = self.iapIds[indexPath.row];
    }
    
    return cell;
}

#pragma mark  - TableViewDelegate Delegate Implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
