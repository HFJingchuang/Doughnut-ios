//
//  WalletManage.h
//  Doughnut
//
//  Created by xumingyang on 2019/8/7.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SocketRocketUtility.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"
#import <Wallet.h>
#import <Remote.h>
#import <Seed.h>

@interface WalletManage : NSObject

@property (nonatomic, strong) Remote *remote;
@property (nonatomic, strong) NSString *currentNode;

//初始化
+ (instancetype) shareWalletManage;
//创建连接
- (Remote *) createRemote;
//切换节点
- (Remote *) changeNodeAddress:(NSString *) url;
//创建钱包（不传私钥）
- (NSDictionary *) createWallet;
//创建钱包（传私钥）
- (NSDictionary *) createWalletWithSecret:(NSString *) secret;
//转账
- (void) transactionWithData:(NSMutableDictionary *)txData;
//签名
- (void) signWithData:(NSMutableDictionary *)txData;
////获取账号信息
//- (void) getAccountInfoByAddress:(NSString *)address;
////获取账号关系(可用)
//- (void) getAccountRelationByAddressTrust:(NSString *)address;
////获取账号关系(冻结)
//- (void) getAccountRelationByAddressFreeze:(NSString *)address;
//查询全部币种
- (void) getAllTokens:(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure;
//获取交易记录
- (void) requestAcountTX:(NSString *) address :(NSString *) limit;
//获取交易记录
- (void) getTransactionHistory:(NSString *)address page:(int)page :(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure;
//获取具体交易信息
- (void) getTransactionDetail:(NSString *)hash :(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure;
//获取余额数据
-(void) requestBalanceByAddress:(NSString *)address current:(BOOL)curr;
//获取单一币价
-(void) getTokenPrice:(NSString *)token :(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure;
//获取所有币价
- (void) getAllTokenPrice:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end

