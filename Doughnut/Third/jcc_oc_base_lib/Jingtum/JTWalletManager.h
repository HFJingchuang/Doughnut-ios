//
//  JingtumManager.h
//  jcc_oc_base_lib
//
//  Created by 沐生 on 2019/1/2.
//  Copyright © 2019 JCCDex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JingtumWallet;

@interface JTWalletManager : NSObject

+ (instancetype)shareInstance;

- (void)createWallet:(NSString *)chain completion:(void(^)(NSError *error, JingtumWallet *wallet))completion;

- (void)importSecret:(NSString *)secret chain:(NSString *)chain completion:(void(^)(NSError *error, JingtumWallet *wallet))completion;

- (void)isValidAddress:(NSString *)address chain:(NSString *)chain completion:(void(^)(BOOL isValid))completion;

- (void)isValidSecret:(NSString *)secret chain:(NSString *)chain completion:(void(^)(BOOL isValid))completion;

- (void)sign:(NSDictionary *)transaction secret:(NSString *)secret chain:(NSString *)chain completion:(void(^)(NSError *error, NSString *signature))completion;

@end
