//
//  wallet.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/7/1.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Keypairs.h"

@interface Wallet : NSObject

@property(nonatomic, copy) Keypairs *keypairs;
@property(nonatomic, copy) NSString *secret;

-(id)initWithKeypairs:(Keypairs*)keypairs private:(NSString*)secret;

+(NSDictionary*)generate;
+(NSDictionary*)fromSecret:(NSString*)secret;
+(BOOL)isValidSecret:(NSString*)secret;

@end
