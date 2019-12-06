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
#import "JccdexConfig.h"
#import "JccdexInfo.h"

#define JC_SCAN_SERVER @"https://swtcscan.jccdex.cn"

static NSString *SUCCESS = @"success";
static NSString *Error = @"error";
static NSString *TOKEN_ROUTER = @"/sum/all/";
static NSString *TX_ROUTER = @"/wallet/trans/";
static NSString *HASH_ROUTER = @"/hash/detail/";
static int SCALE = 4;
static int FREEZED = 5;
static int RESERVED = 20;
static NSString *CONFIG_HOST = @"https://weidex.vip";
static NSString *COUNTER = @"CNT";
@interface WalletManage (){
    NSURLSession *_sharedSession;
    CaclUtil *caclUtil;
    JccdexConfig *jccdexConfig;
    JccdexInfo *jccdexInfo;
    int accountInfoId;
    int accountRelationsTrustId;
    int accountRelationsFreezeId;
    int accountOffersId;
    NSMutableArray<NSNumber *> *accountInfoIds;
    NSMutableArray<NSNumber *> *accountRelationsTrustIds;
    NSMutableArray<NSNumber *> *accountRelationsFreezeIds;
    NSMutableArray<NSNumber *> *accountOffersIds;
    int accountTumsId;
    int accountTXId;
    int transactionId;
    BOOL isCurrent;
}

@property (nonatomic, copy) AccountInfoModal *accountInfo;
@property (nonatomic, copy) NSMutableArray<NSMutableDictionary *> *trustlines;
@property (nonatomic, copy) NSMutableArray<NSMutableDictionary *> *freezeLines;
@property (nonatomic, copy) NSMutableArray<NSMutableDictionary *> *offerlist;

@end
@implementation WalletManage

+ (instancetype)shareWalletManage {
    static dispatch_once_t onceToken;
    static WalletManage *manager;
    dispatch_once(&onceToken, ^{
        manager = [[WalletManage alloc]init];
        [manager createRemote];
    });
    return manager;
}

- (Remote *) createRemote{
    _remote = [Remote instance];
    caclUtil = [[CaclUtil alloc]init];
    jccdexConfig = [JccdexConfig shareInstance];
    jccdexInfo = [JccdexInfo shareInstance];
    [_remote connectWithURLString:@"wss://s.jingtum.com:5020" local_sign:YES];
    _currentNode = @"wss://s.jingtum.com:5020";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketdidReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountInfo:) name:requestAccountInfoFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountRelationsTrust:) name:requestAccountRelationsTrustFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountRelationsFreeze:) name:requestAccountRelationsFreezeFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountOffers:) name:requestAccountOffersFlag object:nil];
    return _remote;
}

- (Remote *) changeNodeAddress:(NSString *) url {
    [_remote disconnect];
    _remote = [Remote instance];
    [_remote connectWithURLString:url local_sign:YES];
    _currentNode = url;
    return _remote;
}

- (void) SRWebSocketDidOpen {
    NSLog(@"connect success!");
};

- (void) SRWebSocketDidReceiveMsg:(NSNotification *) notification {
    NSString * message = notification.object;
    NSDictionary *data = [self dictionaryWithJsonString:message];
    NSDictionary *result = [[self dictionaryWithJsonString:message] objectForKey:@"result"];
    int requestFlag = [[[self dictionaryWithJsonString:message] objectForKey:@"id"] intValue];
    if(requestFlag == accountInfoId || [accountInfoIds containsObject:[NSNumber numberWithInt:requestFlag]]){
        if([[[self dictionaryWithJsonString:message] valueForKey:@"status"]isEqualToString:SUCCESS]){
            [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountInfoFlag object:result];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountInfoFlag object:[data objectForKey:@"request"]];
        }
    }else if (requestFlag == accountTumsId){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountTumsFlag object:result];
    }else if (requestFlag == accountRelationsTrustId || [accountRelationsTrustIds containsObject:[NSNumber numberWithInt:requestFlag]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountRelationsTrustFlag object:result];
    }else if (requestFlag == accountRelationsFreezeId || [accountRelationsFreezeIds containsObject:[NSNumber numberWithInt:requestFlag]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountRelationsFreezeFlag object:result];
    }else if (requestFlag == accountOffersId || [accountOffersIds containsObject:[NSNumber numberWithInt:requestFlag]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:requestAccountOffersFlag object:result];
    }
//    else if (requestFlag == accountTXId) {
//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:requestAcountTXFlag object:data];
//    }
    else if(requestFlag == transactionId){
        [[NSNotificationCenter defaultCenter]postNotificationName:transactionFlag object:result];
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
- (NSDictionary *) createWallet{
    NSDictionary * wallet = [Wallet generate];
    return wallet;
}
//用私钥创建钱包
- (NSDictionary *) createWalletWithSecret:(NSString *) secret {
    NSDictionary * wallet = [Wallet fromSecret:secret];
    return wallet;
}

//转账
- (void) transactionWithData:(NSMutableDictionary *)txData {
    if (txData){
        NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
        [options setObject:[txData valueForKey:@"account"] forKey:@"account"];
        [options setObject:[txData valueForKey:@"to"] forKey:@"to"];
        NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
        [amount setObject:[txData valueForKey:@"value"] forKey:@"value"];
        [amount setObject:[txData valueForKey:@"currency"] forKey:@"currency"];
        if ([[txData valueForKey:@"currency"] isEqualToString:CURRENCY_SWTC]) {
            [amount setObject:CURRENCY_SWT forKey:@"currency"];
        } else if([[txData valueForKey:@"currency"] isEqualToString:@"CNT"]){
            [amount setObject:CURRENCY_CNY forKey:@"currency"];
        }
        [amount setObject:[txData valueForKey:@"issuer"] forKey:@"issuer"];
        [options setObject:amount forKey:@"amount"];
        [options setObject:[txData valueForKey:@"fee"] forKey:@"fee"];
        Transaction *tx = [[Remote instance] buildPaymentTx:options];
        [tx setSecret:[txData valueForKey:@"secret"]];
        [tx addMemo:[txData valueForKey:@"memo"]];
        transactionId = _remote->req_id + 1;
        [tx submit];
    }
}

//获取账号信息
- (void) requestAccountInfoByAddress:(NSString *)address {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    accountInfoId = _remote->req_id;
    if(!isCurrent){
        if (!accountInfoIds){
            accountInfoIds = [NSMutableArray new];
        }
        [accountInfoIds addObject:[NSNumber numberWithInt:_remote->req_id]];
    }
    [_remote requestAccountInfo:options];
    
}

-(void) getAccountInfo:(NSNotification *) notification {
    NSDictionary *accountData = [notification.object objectForKey:@"account_data"];
    if (accountData){
        _accountInfo = [AccountInfoModal mj_objectWithKeyValues:accountData];
    }else {
        _accountInfo = [AccountInfoModal new];
        [_accountInfo setAccount:[notification.object valueForKey:@"account"]];
    }
    [self getBalance];
}

//获取账号可用币种
- (void)requestAccountTumByAddress:(NSString *)address {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    accountTumsId = _remote->req_id;
    [_remote requestAccountTums:options];
    
}

//获取账号挂单信息
- (void)requestAccountOffersByAddress:(NSString *)address {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    accountOffersId = _remote->req_id;
    if(!isCurrent){
        if (!accountOffersIds){
            accountOffersIds = [NSMutableArray new];
        }
        [accountOffersIds addObject:[NSNumber numberWithInt:_remote->req_id]];
    }
    [_remote requestAccountOffers:options];
}

- (void)getAccountOffers:(NSNotification *) notification {
    _offerlist = [notification.object objectForKey:@"offers"];
    for (int i = 0;i < _offerlist.count ;i++){
        if ([[_offerlist[i] valueForKey:@"taker_gets"] isKindOfClass:NSString.class]){
            NSMutableDictionary *da = [NSMutableDictionary new];
            [da setValue:@"SWTC" forKey:@"currency"];
            CGFloat value = [[_offerlist[i] valueForKey:@"taker_gets"] integerValue]/1000000.0;
            NSString *balance = [NSString stringWithFormat:@"%.6f",value];
            [da setValue:balance forKey:@"value"];
            [_offerlist[i] setValue:da forKey:@"taker_gets"];
        }
    }
    [self getBalance];
}

//获取账号关系 (可用)
- (void) requestAccountRelationByAddressTrust:(NSString *)address{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    [options setObject:@"trust" forKey:@"type"];
    accountRelationsTrustId = _remote->req_id;
    if(!isCurrent){
        if (!accountRelationsTrustIds){
            accountRelationsTrustIds = [NSMutableArray new];
        }
        [accountRelationsTrustIds addObject:[NSNumber numberWithInt:_remote->req_id]];
    }
    [_remote requestAccountRelations:options];
}

-(void) getAccountRelationsTrust:(NSNotification *) notification {
    _trustlines = [notification.object objectForKey:@"lines"];
    [self getBalance];
}

//获取账号关系 (冻结)
- (void) requestAccountRelationByAddressFreeze:(NSString *)address{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    [options setObject:@"freeze" forKey:@"type"];
    accountRelationsFreezeId = _remote->req_id;
    if(!isCurrent){
        if (!accountRelationsFreezeIds){
            accountRelationsFreezeIds = [NSMutableArray new];
        }
        [accountRelationsFreezeIds addObject:[NSNumber numberWithInt:_remote->req_id]];
    }
    [_remote requestAccountRelations:options];
}

-(void) getAccountRelationsFreeze:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the Relations2 from server is: %@", message);
    _freezeLines = [notification.object objectForKey:@"lines"];
    [self getBalance];
}

//获取交易记录
- (void) requestAcountTX:(NSString *)address :(NSString *) limit {
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    [options setObject:address forKey:@"account"];
    [options setObject:limit forKey:@"limit"];
    accountTXId = _remote->req_id;
    [_remote requestAccountTx:options];
}

//获取具体交易信息
- (void) getTransactionDetail:(NSString *)hash :(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure {
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@?h=%@",JC_SCAN_SERVER,HASH_ROUTER,[[NSUUID UUID] UUIDString],hash];
    [[TPOSApiClient sharedInstance]getFromUrl:requestUrl parameter:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([[responseObject objectForKey:@"code"] isEqualToString:REQUEST_JC_SUCCESS_CODE]) {
                if (success) {
                    NSMutableDictionary *data = [responseObject objectForKey:@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        success(data);
                    }
                }
            } else {
                if (failure) {
                    NSLog(@"f%@",failure);
                    failure([responseObject objectForKey:@"message"]);
                }
            }
        } else {
            if (failure) {
                failure([responseObject objectForKey:@"message"]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

//获取交易历史记录
- (void) getTransactionHistory:(NSString *)address page:(int)page :(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure {
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@?p=%d&s=10&w=%@",JC_SCAN_SERVER,TX_ROUTER,[[NSUUID UUID] UUIDString],page,address];
    __weak typeof(self) weakSelf = self;
    [[TPOSApiClient sharedInstance]getFromUrl:requestUrl parameter:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([[responseObject objectForKey:@"code"] isEqualToString:REQUEST_JC_SUCCESS_CODE]) {
                if (success) {
                    NSMutableDictionary *data = [responseObject objectForKey:@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                           success(data);
                    }
                }
            } else {
                if (failure) {
                    NSLog(@"f%@",failure);
                    failure([weakSelf errorDomain:requestUrl reason:@"code != 0"]);
                }
            }
        } else {
            if (failure) {
                failure([weakSelf errorDomain:requestUrl reason:@"responseObject is not Dictionary"]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
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
                            NSArray<NSString *> *str = [data allValues][0];
                            for (int i=0; i <str.count;i++ ) {
                                [arr addObject:str[i]];
                            }
                        }
                    }
                    NSDictionary *result = [arr valueForKeyPath:@"@distinctUnionOfObjects.self"];
                    success(result);
                }
            } else {
                if (failure) {
                    NSLog(@"f%@",failure);
                    failure([weakSelf errorDomain:requsetUrl reason:@"code != 0"]);
                }
            }
        } else {
            if (failure) {
                failure([weakSelf errorDomain:requsetUrl reason:@"responseObject is not Dictionary"]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void) requestBalanceByAddress:(NSString *)address current:(BOOL)curr {
    isCurrent = curr;
    [self requestAccountRelationByAddressTrust:address];
    [self requestAccountRelationByAddressFreeze:address];
    [self requestAccountOffersByAddress:address];
    [self requestAccountInfoByAddress:address];
}

-(void) getBalance{
    NSMutableArray<NSMutableDictionary *> *data;
    if ([self arrIsNil:_trustlines]&&[self arrIsNil:_freezeLines]&&[self arrIsNil:_offerlist]&&_accountInfo){
         data = [NSKeyedUnarchiver unarchiveObjectWithData:
                                      [NSKeyedArchiver archivedDataWithRootObject:_trustlines]];
        // 计算swt冻结数量
        long freezed = (data.count + _offerlist.count) * FREEZED + RESERVED;
        NSMutableDictionary *swtLine = [NSMutableDictionary new];
        NSString *valid = [caclUtil sub:_accountInfo.Balance :[NSString stringWithFormat:@"%ld",freezed] :SCALE];
        [swtLine setValue:valid forKey:@"balance"];
        [swtLine setValue:CURRENCY_SWTC forKey:@"currency"];
        [swtLine setValue:[NSString stringWithFormat:@"%ld",freezed] forKey:@"limit"];
        [swtLine setValue:@"" forKey:@"account"];
        [data addObject:swtLine];
        // trust limit 置零
        for (int j = 0; j < data.count; j++) {
            NSString *currency = [data[j] valueForKey:@"currency"];
            if (![currency isEqualToString:CURRENCY_SWTC]) {
                [data[j] setValue:@"0" forKey:@"limit"];
            }
        }
        
        // 根据挂单计算冻结数量
        for (int i = 0; i <_offerlist.count; i++) {
            NSString *getsCurrency = [[_offerlist[i] objectForKey:@"taker_gets"] valueForKey:@"currency"];
            for (int j = 0; j < data.count; j++) {
                NSMutableDictionary *line = data[j];
                NSString *currency = [line valueForKey:@"currency"];
                if ([getsCurrency isEqualToString:currency]) {
                    NSString *offerValue = [[_offerlist[i] objectForKey:@"taker_gets"] valueForKey:@"value"];
                    NSString *tokenFreeze = [caclUtil add:[line valueForKey:@"limit"] :offerValue :SCALE];
                    NSString *balance = [caclUtil sub:[line valueForKey:@"balance"] :offerValue :SCALE];
                    [line setValue:balance forKey:@"balance"];
                    [line setValue:tokenFreeze forKey:@"limit"];
                    break;
                }
            }
        }
        // 根据冻结关系类型计算冻结数量
        for (int i = 0; i < _freezeLines.count; i++) {
            NSString *FCurrency = [_freezeLines[i] valueForKey:@"currency"];
            for (int j = 0; j < data.count; j++) {
                NSMutableDictionary *line = data[j];
                NSString *currency = [line valueForKey:@"currency"];
                if ([FCurrency isEqualToString:currency]) {
                    NSString *freeze = [_freezeLines[i] valueForKey:@"limit"];
                    NSString *tokenFreeze = [caclUtil add:[line valueForKey:@"limit"] :freeze :SCALE];
                    NSString *balance = [caclUtil sub:[line valueForKey:@"balance"] :freeze :SCALE];
                    [line setValue:balance forKey:@"balance"];
                    [line setValue:tokenFreeze forKey:@"limit"];
                    break;
                }
            }
        }
        if (isCurrent){
            [[NSNotificationCenter defaultCenter] postNotificationName:getCurrentWalletBalance object:data];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:_accountInfo.Account object:data];
        }
        _trustlines = nil;
        _freezeLines = nil;
        _offerlist = nil;
        _accountInfo = nil;
    } else if (![self arrIsNil:_trustlines]&&![self arrIsNil:_freezeLines]&&![self arrIsNil:_offerlist]&&_accountInfo){
        data = [NSMutableArray new];
        if (isCurrent){
            [[NSNotificationCenter defaultCenter] postNotificationName:getCurrentWalletBalance object:data];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:_accountInfo.Account object:data];
        }
        _accountInfo = nil;
    }
    
}

-(void)getTokenPrice:(NSString *)token :(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure {
    [jccdexConfig initConfigNodes:@[CONFIG_HOST]];
    [jccdexConfig requestConfig:^(NSDictionary *response) {
        NSArray *infohosts = [response valueForKey:@"infoHosts"];
        NSString *host = [NSString stringWithFormat:@"%@%@",@"https://",infohosts[arc4random() % infohosts.count]];
        [jccdexInfo initInfoNodes:@[host]];
        [jccdexInfo requestTicker:token counter:COUNTER onResponse:^(NSDictionary *inforesponse) {
            if([inforesponse valueForKey:@"success"]){
                success([inforesponse valueForKey:@"data"][1]);
            }else{
                failure([inforesponse valueForKey:@"msg"]);
            }
        } onFail:^(NSError *error) {
            failure(error);
        }];
    } onFail:^(NSError *error) {
        failure(error);
    }];
}

-(void)getAllTokenPrice:(void(^)(NSArray *))success failure:(void(^)(NSError *error))failure {
    [jccdexConfig initConfigNodes:@[CONFIG_HOST]];
    [jccdexConfig requestConfig:^(NSDictionary *response) {
        NSArray *infohosts = [response valueForKey:@"infoHosts"];
        NSString *host = [NSString stringWithFormat:@"%@%@",@"https://",infohosts[arc4random() % infohosts.count]];
        [jccdexInfo initInfoNodes:@[host]];
        [jccdexInfo requestAllTickers:^(NSDictionary *inforesponse) {
            if([inforesponse valueForKey:@"success"]){
                success([inforesponse valueForKey:@"data"]);
            }else{
                failure([inforesponse valueForKey:@"msg"]);
            }
        } onFail:^(NSError *error) {
           failure(error);
        }];
    } onFail:^(NSError *error) {
        failure(error);
    }];
    
}

-(BOOL)arrIsNil:(NSMutableArray *)array{
    if ([array isKindOfClass:[NSNull class]]) {
        return NO;
    }else if (array==nil || array==NULL){
        return NO;
    }
    return YES;
}

- (NSError *)errorDomain:(NSString *)domain reason:(NSString *)reason {
    NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:reason}];
    return error;
}

@end
