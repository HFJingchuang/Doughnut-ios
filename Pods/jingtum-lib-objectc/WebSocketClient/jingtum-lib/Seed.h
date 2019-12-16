//
//  Seed.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/8/8.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Keypairs.h"

@interface Seed : NSObject
{
    BTCKey *btckey;
}

@property(nonatomic, strong)NSData *seedBytes;
@property(nonatomic) int version;

+(NSDictionary*)random;
+(NSDictionary*)fromBase58:(NSData*)secret; // decode the secret
-(id)initWithSeedBytes:(NSData*)seedBytes version:(int)version;
-(Keypairs*)keyPair;
-(Keypairs*)keyPair:(int)account;
-(Keypairs*)createKeyPair:(NSData*)seedBytes account:(int)accountNumber;
-(NSData*)signTx:(NSData*)hash;
-(Keypairs*)deriveKeyPair:(NSString *)secret;

@end
