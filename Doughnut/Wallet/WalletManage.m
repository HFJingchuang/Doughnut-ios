//
//  WalletManage.m
//  Doughnut
//
//  Created by xumingyang on 2019/8/7.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//
//  提供与井通接口连接的方法
#import "SocketRocketUtility.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"
#import "WalletManage.h"
#import <Transaction.h>
#import <Wallet.h>
#import <Remote.h>
#import "TPOSApiClient.h"

#import <JccdexInfo.h>
#import <JccdexMacro.h>
#import <JccdexConfig.h>
#import <JccdexExchange.h>
#import <stdlib.h>

#define JC_SCAN_SERVER @"https://swtcscan.jccdex.cn"
#define TOKEN_ROUTER @"/sum/all/"

@interface WalletManage (){
    NSURLSession *_sharedSession;
    WalletUserDefaults *walletInfo;
    Remote *remote;
}

@end
@implementation WalletManage

- (instancetype)shareInstance {
//    if (self = [super init]){
//        walletInfo = [[WalletUserDefaults alloc] init];
//        remote = [self createRemote];
//    }
//    return self;
    static dispatch_once_t onceToken;
    static WalletManage *manager;
    dispatch_once(&onceToken, ^{
        manager = [[WalletManage alloc] init];
    });
    return manager;
}

- (Remote *) createRemote{
    remote = [Remote instance];
    [remote connectWithURLString:@"ws://ts5.jingtum.com:5020" local_sign:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketdidReceiveMessage object:nil];
    return remote;
}

- (void) changeUrl:(NSString *) url {
    [remote disconnect];
    Remote * remote1 = [Remote instance];
    [remote1 connectWithURLString:url local_sign:YES];
    remote = remote1;
}

- (void) SRWebSocketDidOpen {
    NSLog(@"balance is");
    [self getBalance];
};

- (void) SRWebSocketDidReceiveMsg:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the response from server is: %@", message);
};

//创建钱包
- (void) createWallet{
    NSDictionary * wallet = [Wallet generate];
    NSString *address = [wallet objectForKey:@"address"];
    NSString *secret = [wallet objectForKey:@"secret"];
    walletInfo = [[WalletUserDefaults alloc]init];
    [walletInfo insertAddress:address AndSecret:secret];
    NSLog(@"the wallet is %@", wallet);
//    [walletInfo getAddress];
//    [walletInfo getSecret];
}

- (void) createWalletWithSecret:(NSString *) secret {
    NSDictionary * wallet = [Wallet fromSecret:secret];
    NSString *address = [wallet objectForKey:@"address"];
    [walletInfo insertAddress:address AndSecret:secret];
    NSLog(@"the wallet is %@", wallet);
}

//转账
- (void) transferWithPassword {
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    [options setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
    [options setObject:@"jpKcDjvqT1BJZ6G674tvLhYdNPtwPDU6vD" forKey:@"to"];
    
    NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
    NSNumber *value = [NSNumber numberWithFloat:2];
    [amount setObject:value forKey:@"value"];
    [amount setObject:@"SWT" forKey:@"currency"];
    [amount setObject:@" " forKey:@"issuer"];
    
    [options setObject:amount forKey:@"amount"];
    
    Transaction *tx = [[Remote instance] buildPaymentTx:options];
    
    [tx setSecret:@"sn37nYrQ6KPJvTFmaBYokS3FjXUWd"];
    [tx addMemo:@"给jDUjqoDZLhzx4DCf6pvSivjkjgtRESY62c支付0.5swt."];
    [tx addMemo:@"测试jerry"];
    [tx submit];
}

//获取交易记录
- (void) getTansferHishory:(NSUnit *) limit {
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    //    NSString *account = [walletInfo getAddress];
    //    [options setObject:account forKey:@"account"];
    [options setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
    [options setObject:limit forKey:@"limit"];
    [remote requestAccountTx:options];
}

//获取余额
- (void) getBalance{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    //    NSString *account = [walletInfo getAddress];
    //    [options setObject:account forKey:@"account"];
    [options setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
    [remote requestAccountInfo:options];
}

//获取全部tokens
- (void) getAllTokens{
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@%@",JC_SCAN_SERVER,TOKEN_ROUTER,[[NSUUID UUID] UUIDString]];
    [[TPOSApiClient sharedInstance]getFromUrl:requsetUrl parameter:nil success:^(id responseObject) {
        
        <#code#>
    } failure:^(NSError *error) {
        <#code#>
    }];
    }
}

@end
