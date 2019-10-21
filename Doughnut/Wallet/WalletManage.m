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

#import "TPOSApiClient.h"
#import "NSObject+TPOS.h"
#import <WebKit/WebKit.h>
#import <JccdexInfo.h>
#import <JccdexMacro.h>
#import <JccdexConfig.h>
#import <JccdexExchange.h>
#import <stdlib.h>
#import "TPOSMacro.h"
#import "LineModel.h"
#import "AccountInfoModal.h"
#import "CaclUtil.h"

#define JC_SCAN_SERVER @"https://swtcscan.jccdex.cn"
#define TOKEN_ROUTER @"/sum/all/"
#define SCALE 4;

@interface WalletManage (){
    NSURLSession *_sharedSession;
    Remote *remote;
    CaclUtil *caclUtil;
    int accountInfoId;
    int accountTumsId;
    int accountRelationsTrustId;
    int accountRelationsFreezeId;
    int accountOffersId;
}

@property (nonatomic, strong) AccountInfoModal *accountInfo;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *trustlines;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *freezeLines;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *offerlist;

@end
@implementation WalletManage

- (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static WalletManage *manager;
    dispatch_once(&onceToken, ^{
        manager = [[WalletManage alloc] init];
    });
    return manager;
}

- (Remote *) createRemote{
    remote = [Remote instance];
    caclUtil = [[CaclUtil alloc]init];
    [remote connectWithURLString:@"wss://s.jingtum.com:5020" local_sign:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketdidReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountInfo:) name:requestAccountInfoFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountRelationsTrust:) name:requestAccountRelationsTrustFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountRelationsFreeze:) name:requestAccountRelationsFreezeFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountOffers:) name:requestAccountOffersFlag object:nil];
    return remote;
}

- (void) changeUrl:(NSString *) url {
    [remote disconnect];
    Remote * remote1 = [Remote instance];
    [remote1 connectWithURLString:url local_sign:YES];
    remote = remote1;
}

- (void) SRWebSocketDidOpen {
    NSLog(@"connect success!");
};

- (void) SRWebSocketDidReceiveMsg:(NSNotification *) notification {
    NSString * message = notification.object;
    //NSLog(@"the response from server is: %@", message);
    NSDictionary *data = [[self dictionaryWithJsonString:message] objectForKey:@"result"];
    int requestFlag = [[[self dictionaryWithJsonString:message] objectForKey:@"id"] intValue];
    if(requestFlag == accountInfoId){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountInfoFlag object:data];
    }else if (requestFlag == accountTumsId){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountTumsFlag object:data];
    }else if (requestFlag == accountRelationsTrustId){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountRelationsTrustFlag object:data];
    }else if (requestFlag == accountRelationsFreezeId){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountRelationsFreezeFlag object:data];
    }
};

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//创建钱包
- (void) createWallet{
    NSDictionary * wallet = [Wallet generate];
    NSLog(@"the wallet is %@", wallet);
}

- (void) createWalletWithSecret:(NSString *) secret {
    NSDictionary * wallet = [Wallet fromSecret:secret];
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

//获取账号信息
- (void) requestAccountInfoByAddress:(NSString *)address {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    accountInfoId = remote->req_id;
    [remote requestAccountInfo:options];
    
}

-(void) getAccountInfo:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the info from server is: %@", message);
    NSDictionary *accountData = [notification.object objectForKey:@"account_data"];
    _accountInfo = [AccountInfoModal mj_objectWithKeyValues:accountData];
    [self getBalance];
}

//获取账号可用币种
- (void)requestAccountTumByAddress:(NSString *)address {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    accountTumsId = remote->req_id;
    [remote requestAccountTums:options];
    
}

//获取账号挂单信息
- (void)requestAccountOffersByAddress:(NSString *)address {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    accountOffersId = remote->req_id;
    [remote requestAccountOffers:options];
}

- (void)getAccountOffers:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the Relations1 from server is: %@", message);
    _offerlist = [notification.object objectForKey:@"offers"];
    [self getBalance];
}

//获取账号关系 (可用)
- (void) requestAccountRelationByAddressTrust:(NSString *)address{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    [options setObject:@"trust" forKey:@"type"];
    accountRelationsTrustId = remote->req_id;
    [remote requestAccountRelations:options];
}

-(void) getAccountRelationsTrust:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the Relations1 from server is: %@", message);
    _trustlines = [notification.object objectForKey:@"lines"];
    [self getBalance];
}

//获取账号关系 (冻结)
- (void) requestAccountRelationByAddressFreeze:(NSString *)address{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    [options setObject:@"freeze" forKey:@"type"];
    accountRelationsFreezeId = remote->req_id;
    [remote requestAccountRelations:options];
}

-(void) getAccountRelationsFreeze:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the Relations2 from server is: %@", message);
    _freezeLines = [notification.object objectForKey:@"lines"];
    [self getBalance];
}

//获取交易记录
- (void) requestTansferHishory:(NSUnit *) limit {
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    [options setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
    [options setObject:limit forKey:@"limit"];
    [remote requestAccountTx:options];
}

//获取全部tokens
- (void) getAllTokens:(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure {
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@%@",JC_SCAN_SERVER,TOKEN_ROUTER,[[NSUUID UUID] UUIDString]];
    __weak typeof(self) weakSelf = self;
    [[TPOSApiClient sharedInstance]getFromUrl:requsetUrl parameter:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([[responseObject objectForKey:@"code"] isEqualToString:REQUEST_JC_SUCCESS_CODE]) {
                if (success) {
                    NSMutableArray *arr = [NSMutableArray new];
                    NSArray *datas = [responseObject objectForKey:@"data"];
                    for (NSDictionary *data in datas) {
                        if ([data isKindOfClass:[NSDictionary class]]) {
                        }
                    }
                    if (success) {
                        NSLog(@"s%@",success);
                        //success(arr);
                    }
                }
            } else {
                if (failure) {
                    NSLog(@"f%@",failure);
                    //failure([weakSelf errorDomain:url reason:@"code != 0"]);
                }
            }
        } else {
            if (failure) {
                //failure([weakSelf errorDomain:url reason:@"responseObject is not Dictionary"]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}



-(void) requestBalanceByAddress:(NSString *)address {
    [self requestAccountInfoByAddress:address];
    [self requestAccountOffersByAddress:address];
    [self requestAccountRelationByAddressTrust:address];
    [self requestAccountRelationByAddressFreeze:address];
}

-(void) getBalance{
    if (_accountInfo &&_trustlines&&_freezeLines){
        // 计算swt冻结数量
        int freezed = (_trustlines.count + _offerlist.count) * FREEZED + RESERVED;
        NSMutableDictionary *swtLine = [NSMutableDictionary new];
        NSString *valid = [caclUtil sub:_accountInfo.Balance :[NSString stringWithFormat:@"%d",freezed] :4];
        [swtLine setValue:valid forKey:@"balance"];
        [swtLine setValue:@"SWT" forKey:@"currency"];
        [swtLine setValue:[NSString stringWithFormat:@"%d",freezed] forKey:@"limit"];
        [_trustlines addObject:swtLine];
        // trust limit 置零
        for (int j = 0; j < _trustlines.count; j++) {
            NSString *currency = [_trustlines[j] valueForKey:@"currency"];
            if (![currency isEqualToString:@"SWT"]) {
                [_trustlines[j] setValue:@"0" forKey:@"limit"];
            }
        }
        
        // 根据挂单计算冻结数量
        for (int i = 0; i <_offerlist.count; i++) {
            NSString *getsCurrency = [[_offerlist[i] objectForKey:@"takerGets"] valueForKey:@"currency"];
            for (int j = 0; j < _trustlines.count; j++) {
                NSMutableDictionary *line = _trustlines[j];
                NSString *currency = [line valueForKey:@"currency"];
                if ([getsCurrency isEqualToString:currency]) {
                    NSString *offerValue = [[_offerlist[i] objectForKey:@"takerGets"] valueForKey:@"value"];;
                    NSString *tokenFreeze = [caclUtil add:[line valueForKey:@"limit"] :offerValue :0];
                    NSString *balance = [caclUtil sub:[line valueForKey:@"balance"] :offerValue :0];
                    [line setValue:balance forKey:@"balance"];
                    [line setValue:tokenFreeze forKey:@"limit"];
                    break;
                }
            }
        }
        // 根据冻结关系类型计算冻结数量
        for (int i = 0; i < _freezeLines.count; i++) {
            NSString *FCurrency = [_freezeLines[i] valueForKey:@"currency"];
            for (int j = 0; j < _trustlines.count; j++) {
                NSMutableDictionary *line = _trustlines[j];
                NSString *currency = [line valueForKey:@"currency"];
                if ([FCurrency isEqualToString:currency]) {
                    NSString *freeze = [_freezeLines[i] valueForKey:@"limit"];
                    NSString *tokenFreeze = [caclUtil add:[line valueForKey:@"limit"] :freeze :0];
                    NSString *balance = [caclUtil sub:[line valueForKey:@"balance"] :freeze :0];
                    [line setValue:balance forKey:@"balance"];
                    [line setValue:tokenFreeze forKey:@"limit"];
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:getBalanceList object:_trustlines];
}

@end
