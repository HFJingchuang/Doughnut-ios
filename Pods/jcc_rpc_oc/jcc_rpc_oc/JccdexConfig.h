//
//  JccdexConfig.h
//  jcc_rpc_oc
//
//  Created by xumingyang on 2019/8/23.
//  Copyright © 2019 JCCDex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JccdexConfig : NSObject


+ (instancetype)shareInstance;

- (void)initConfigNodes:(NSArray *)nodes;

-(void) requestConfig:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail;

@end

