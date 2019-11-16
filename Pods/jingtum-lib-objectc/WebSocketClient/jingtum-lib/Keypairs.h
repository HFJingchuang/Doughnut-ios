//
//  keypairs.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/7/1.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBitcoin/CoreBitcoin.h>

@interface Keypairs : NSObject

@property(nonatomic, copy) BTCBigNumber *secret;
@property(nonatomic, copy) NSData *pub;
@property(nonatomic, copy) BTCBigNumber *pri;

-(id)initWithSecret:(BTCBigNumber*)secret pub:(NSData*)pub pri:(BTCBigNumber*)pri;

-(NSString*)generateSeed;
-(NSData*)getPublicKey;
-(NSData*)convertAddressToBytes:(NSString*)address;

@end
