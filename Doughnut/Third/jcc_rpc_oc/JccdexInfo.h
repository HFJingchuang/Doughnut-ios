//
//  JccdexInfo.h
//  jcc_rpc_oc
//
//  Created by xumingyang on 2019/8/21.
//  Copyright © 2019 JCCDex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JccdexInfo : NSObject

+ (instancetype)shareInstance;

- (void)initInfoNodes:(NSArray *)nodes;

- (void) requestTicker:(NSString *)base counter:(NSString *)counter onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void) requestAllTickers:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void) requestDepth:(NSString *)base counter:(NSString *)counter type:(NSString *)type onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void) requestKline:(NSString *)base counter:(NSString *)counter type:(NSString *)type onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void) requestHistory:(NSString *)base counter:(NSString *)counter type:(NSString *)type time:(NSString *)time onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

- (void) requestTickerFromCMC:(NSString *)token currency:(NSString *)currency onResponse:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

@end

