//
//  JccdexExchange.h
//  jcc_rpc_oc
//
//  Created by 沐生 on 2018/12/26.
//  Copyright © 2018 JCCDex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JccdexExchange : NSObject

+ (instancetype)shareInstance;

- (void)initExchangeNodes:(NSArray *)nodes;

- (void)requestBalance:(NSString *)address onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)createOrder:(NSString *)signature onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)requestSequence:(NSString *)address onResponse:(void (^)(NSInteger sequence))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)cancelOrder:(NSString *)signature onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)transferToken:(NSString *)signature onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)requestOrders:(NSString *)address page:(NSInteger)page onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)requestHistoricTransactions:(NSString *)address ledger:(NSInteger)ledger seq:(NSInteger)seq onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void)requestHistoricTransactions:(NSString *)address onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

@end
