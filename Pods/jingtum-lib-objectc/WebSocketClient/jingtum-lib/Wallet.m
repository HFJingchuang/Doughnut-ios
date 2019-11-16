//
//  wallet.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/7/1.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Wallet.h"

#import <CoreBitcoin/CoreBitcoin.h>
#import "Seed.h"
#import "Keypairs.h"

@implementation Wallet

-(id)initWithKeypairs:(Keypairs *)keypairs private:(NSString*)secret
{
    if (self = [super init]) {
        _keypairs = [keypairs copy];
        _secret = [secret copy];
    }
    
    return self;
}

+(NSDictionary*)generate
{
    NSDictionary *secretDic = [Seed random];
//    NSLog(@"the secretDic is %@", secretDic);
    
    NSData *seedBytes = [secretDic objectForKey:@"seed"];
    NSString *secret = [secretDic objectForKey:@"secret"];
    
    Seed *seed = [[Seed alloc] initWithSeedBytes:seedBytes version:0];
    
    Keypairs *keypairs = [seed keyPair];
    
    NSData *bytes = [keypairs.pub BTCHash160];
    BTCAddress *btcAddress = [BTCPublicKeyAddress addressWithData:bytes];
    NSString *address = btcAddress.base58String;
    NSLog(@"the address is %@", address);
    
//    Wallet *wallet = [[Wallet alloc] initWithKeypairs:keypairs private:secret];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:secret forKey:@"secret"];
    [dic setObject:address forKey:@"address"];
    
    return dic;
}

+(NSDictionary*)fromSecret:(NSString*)secret
{
    if (secret == nil || secret.length < 2) {
        NSLog(@"the secret is invalid");
        return nil;
    }
    Seed *seed = [[Seed alloc] init];
    
    Keypairs *keypairs = [seed deriveKeyPair:secret];
    
    if (keypairs != nil) {
        NSData *bytes = [keypairs.pub BTCHash160];
        BTCAddress *btcAddress = [BTCPublicKeyAddress addressWithData:bytes];
        NSString *address = btcAddress.base58String;
        NSLog(@"the address is %@", address);
        
        //    Wallet *wallet = [[Wallet alloc] initWithKeypairs:keypairs private:secret];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:secret forKey:@"secret"];
        [dic setObject:address forKey:@"address"];
        
        return dic;
    }
    
    return nil;
}

+(BOOL)isValidSecret:(NSString*)secret
{
    if (secret == nil || secret.length < 2) {
        NSLog(@"the secret is invalid");
        return nil;
    }
    Seed *seed = [[Seed alloc] init];
    
    Keypairs *keypairs = [seed deriveKeyPair:secret];
    
    if (keypairs != nil) {
        return true;
    }
    
    return false;
}

@end
