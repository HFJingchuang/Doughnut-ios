//
//  NSData+Hash.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/30.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "NSData+Hash.h"

#import <CommonCrypto/CommonDigest.h>
#import <openssl/ripemd.h>

@implementation NSData (Hash)

- (NSData *)SHA1
{
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(self.bytes, (CC_LONG)self.length, d.mutableBytes);
    
    return d;
}

- (NSData *)SHA256
{
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(self.bytes, (CC_LONG)self.length, d.mutableBytes);
    
    return d;
}

- (NSData *)SHA256_2
{
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(self.bytes, (CC_LONG)self.length, d.mutableBytes);
    CC_SHA256(d.bytes, (CC_LONG)d.length, d.mutableBytes);
    
    return d;
}

- (NSData *)RMD160
{
    NSMutableData *d = [NSMutableData dataWithLength:RIPEMD160_DIGEST_LENGTH];
    
    RIPEMD160(self.bytes, self.length, d.mutableBytes);
    
    return d;
}

- (NSData *)hash160
{
    return self.SHA256.RMD160;
}

- (NSData *)reverse
{
    NSUInteger l = self.length;
    NSMutableData *d = [NSMutableData dataWithLength:l];
    uint8_t *b1 = d.mutableBytes;
    const uint8_t *b2 = self.bytes;
    
    for (NSUInteger i = 0; i < l; i++) {
        b1[i] = b2[l - i - 1];
    }
    
    return d;
}

@end
