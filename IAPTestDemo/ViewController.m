//
//  ViewController.m
//  IAPTestDemo
//
//  Created by 李一贤 on 2018/9/28.
//  Copyright © 2018 李一贤. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "IAPClass.h"
#import <CommonCrypto/CommonCrypto.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain,nonatomic) UIView *bgCoverView;//菊花转动时的view

@property (retain,nonatomic) UIActivityIndicatorView *activityIndicatorView;//菊花转动时的view

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"ViewController ===viewdidLoad===:self%@",self);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[IAPClass shareInstance] requestProductsInfo];
}




//转菊花动画
-(void)inProgressAnimation{
    
    NSLog(@"==inProgressAnimation:self==:%@",self);
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    
    self.activityIndicatorView.center = self.view.center;
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self.bgCoverView addSubview:self.activityIndicatorView];
    [self.view insertSubview:self.bgCoverView aboveSubview:self.tableView];
     [self.activityIndicatorView startAnimating];
//    [self.view addSubview:self.bgCoverView];
//    [self.view addSubview:activityIndicatorView];
}

-(void)finishProgressAnimation{
    
    NSLog(@"==finishProgressAnimation:self==%@",self);
   
//    NSArray *array =  self.bgCoverView.subviews;
    NSArray *array = self.view.subviews;

    for (int i=0; i<array.count; i++) {
        id obj = [array objectAtIndex:i];
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {

            [(UIActivityIndicatorView*)obj stopAnimating];
        }
    }
    [self.bgCoverView removeFromSuperview];
    
}









#pragma mark  - TableViewDataSource Delegate Implementation



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [IAPClass shareInstance].iapIds.count;
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
    cell.textLabel.text = [IAPClass shareInstance].iapIds[indexPath.row];
    return cell;
}

#pragma mark  - TableViewDelegate Delegate Implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"tableView:didSelect:self%@",self);
//    [self inProgressAnimation];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *productId = cell.textLabel.text;
    if (!productId.length) {
        return;
    }
    NSString *application_username = [NSString stringWithFormat:@"orderId:%@,uid:%@", @"123456", @"573096385"];
    
    [[IAPClass shareInstance] iapTestWithProductId:productId
                              application_username:[self hashedValueForAccountName:application_username]];
    
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

#pragma mark  - Getter & Setter


-(UIView*)bgCoverView{
    if (_bgCoverView) {
        return _bgCoverView;
    }
    
    CGRect rec = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    _bgCoverView = [[UIView alloc] initWithFrame:rec];
    
    return _bgCoverView;
}

@end
