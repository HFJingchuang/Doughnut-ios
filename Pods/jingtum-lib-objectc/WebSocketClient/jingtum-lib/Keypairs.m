//
//  keypairs.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/7/1.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Keypairs.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"

@implementation Keypairs

//@synthesize pub;

-(id)initWithSecret:(BTCBigNumber *)secret pub:(NSData *)pub pri:(BTCBigNumber*)pri
{
    if (self = [super init]) {
        _secret = [secret copy];
        _pub = [pub copy];
        _pri = [pri copy];
    }
    
    return self;
}

- (Keypairs*) copy {
    Keypairs *keypairs = [[Keypairs alloc] init];
    keypairs.secret = [_secret copy];
    keypairs.pub = [_pub copy];
    
    return keypairs;
}

-(NSData*)getPublicKey
{
    return _pub;
}

-(NSString*)generateSeed
{
    char bytes[17];
    int SEED_PREFIX = 33;
    bytes[0] = (char)SEED_PREFIX;
    for (int x = 1; x < 17; bytes[x++] = (char)('0' + (arc4random_uniform(10))));
    //    for (int x = 1; x < 17; bytes[x++] = (char)('1'));
    
    NSData *data = [NSData dataWithBytes:bytes length:17];
    NSData *data1 = [data SHA256]; // 0x0000600000440e40 <435cd747 69f0b100 6c326a4c be9858b4 5b758250 77d7935a b10632a1 0df5d984>
    NSData *data2 = [data1 SHA256]; // <81a8856c e9d550ec cde94b2b ad489577 585509e4 11cfb96b c54fa02f 571604bf>
    
    char checksum[5];
    char *cstr = [data2 bytes];
    strlcpy(checksum, cstr, 5);
    
    char ret[22];
    sprintf(ret, "%s%s", bytes, checksum);
    
    NSData *retdata = [NSData dataWithBytes:ret length:22];
    NSString *secret = [NSString base58WithData:retdata];
    
    NSLog(@"the secret is %@", secret);
    
    return secret;
}

-(NSData*)convertAddressToBytes:(NSString *)address
{
    NSData *ret = nil;
    
    NSData *data = [address dataFromBase58];
    
    ret = [data subdataWithRange:NSMakeRange(1, data.length-5)];
    
    return ret;
}

@end
