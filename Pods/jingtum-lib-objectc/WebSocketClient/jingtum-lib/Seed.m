//
//  Seed.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/8/8.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Seed.h"
#import <CoreBitcoin/CoreBitcoin.h>

@implementation Seed

+(NSDictionary*)random {
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    
    char rawbytes[16];
    memset(rawbytes, 0, 16);
    for (int x = 0; x < 16; rawbytes[x++] = (char)('0' + (arc4random_uniform(10))));
    //    for (int x = 0; x < 16; rawbytes[x++] = (char)('1'));
    NSData *seed = [NSData dataWithBytes:rawbytes length:16];
    
    char bytes[17];
    int SEED_PREFIX = 33;
    bytes[0] = (char)SEED_PREFIX;
    for (int x = 1; x < 17; x++) {
        bytes[x] = rawbytes[x-1];
    }
    
    NSMutableData *retdata = [NSMutableData dataWithBytes:bytes length:17];
    NSData *data1 = [retdata SHA256]; // 0x0000600000440e40 <435cd747 69f0b100 6c326a4c be9858b4 5b758250 77d7935a b10632a1 0df5d984>
    NSData *data2 = [data1 SHA256]; // <81a8856c e9d550ec cde94b2b ad489577 585509e4 11cfb96b c54fa02f 571604bf>
    
    char checksum[5];
    char *cstr = [data2 bytes];
    strlcpy(checksum, cstr, 5);
    
    //    char ret[22];
    //    sprintf(ret, "%s%s", bytes, checksum);
    [retdata appendBytes:checksum length:5];
    
    //    NSData *retdata = [NSData dataWithBytes:ret length:strlen(ret)];
    NSString *secret = [retdata base58String];
    
    [retDic setObject:seed forKey:@"seed"];
    [retDic setObject:secret forKey:@"secret"];
    
//    ////////////
//    NSData *newdata = [secret dataFromBase58]; // 这个是不是 base58 的 decode呢？没错的，就是base58 的decode 哈哈哈
    
    return retDic;
}

+(id)fromBase58:(NSData *)secret
{
    // 这边创建 seed，并返回
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    
    return retDic;
}

-(Keypairs*)deriveKeyPair:(NSString *)secret
{
    NSData *data = [secret dataFromBase58];
    
    char *bytes = [data bytes];
    if (data == nil || data.length < 5 || bytes[0] != 33) {
        NSLog(@"invalid input size");
        return nil;
    }
    NSData *checksum = [data subdataWithRange:NSMakeRange(data.length-4, 4)];
    
    NSData *seedBytes = [data subdataWithRange:NSMakeRange(0, data.length-4)];
    NSData *computed = [[[seedBytes SHA256] SHA256] subdataWithRange:NSMakeRange(0, 4)];
    
    if (![checksum isEqualToData:computed]) {
        NSLog(@"invalid checksum");
        return nil;
    }
    
    seedBytes = [data subdataWithRange:NSMakeRange(1, data.length-5)];
    [self setSeedBytes:seedBytes];
    _version = 0;
    
    Keypairs *keypairs = [self keyPair];
    
    return keypairs;
}

-(id)initWithSeedBytes:(NSData *)seedBytes version:(int)version
{
    if (self = [super init]) {
        [self setSeedBytes:seedBytes];
        _version = version;
    }
    
    return self;
}

-(void)setSeedBytes:(NSData *)seedBytes
{
    if (seedBytes.length <= 0) return;
    _seedBytes = [NSData dataWithData:seedBytes];
}

-(Keypairs*)keyPair
{
    Keypairs *keypairs = [self keyPair:0];
    
    return keypairs;
}

-(Keypairs*)keyPair:(int)account
{
    Keypairs *keypairs = [self createKeyPair:_seedBytes account:0];
    
    return keypairs;
}

-(Keypairs*)createKeyPair:(NSData *)seedBytes account:(int)accountNumber
{
    Keypairs *keypairs = nil;
    
    NSData *privateGen = nil;
    NSData *publicGenBytes = nil;
    NSData *publicKey = nil;
    
    for (long i = 0; i <= 0xFFFFFFFFL; i++) {
        privateGen = [self BTCSHA256AndADDU32:_seedBytes disc:nil index:i];
        if (privateGen != nil) break;
    }
    
    if (privateGen != nil) {
        BTCKey *key1 = [[BTCKey alloc] initWithPrivateKey:privateGen];
        key1.publicKeyCompressed = YES;
        publicGenBytes = key1.publicKey;
        
        if (publicGenBytes != nil) {
            NSData *pubGenData = nil;
            for (long i = 0; i <= 0xFFFFFFFFL; i++) {
                NSNumber *accountNumber = [NSNumber numberWithInteger:0];
                pubGenData = [self BTCSHA256AndADDU32:publicGenBytes disc:accountNumber index:i];
                if (pubGenData != nil) break;
            }
            if (pubGenData != nil) {
                BTCMutableBigNumber *pubKeyNum = [[BTCMutableBigNumber alloc] initWithUnsignedBigEndian:pubGenData];
                BTCBigNumber *priGenValue = [[BTCBigNumber alloc] initWithUnsignedBigEndian:privateGen];
                BTCBigNumber *curveOrder = [BTCCurvePoint curveOrder];
                BTCBigNumber *secret = [pubKeyNum add:priGenValue mod:curveOrder];
                NSData *unsignedData = [secret unsignedBigEndian];
                
                btckey = [[BTCKey alloc] initWithPrivateKey:unsignedData];
                btckey.publicKeyCompressed = YES;
                publicKey = btckey.publicKey;
                
                keypairs = [[Keypairs alloc] initWithSecret:secret pub:publicKey pri:secret];
            }
        }
    }
    
    return keypairs;
}

-(NSData*)signTx:(NSData*)hash
{
    NSData *data = [btckey signatureForHash:hash];
    
    return data;
}

-(NSMutableData*) BTCSHA256AndADDU32:(NSData*)data disc:(NSNumber *)discriminator index:(int)i {
    
    if (!data) return nil;
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
    unsigned char digest2[CC_SHA256_DIGEST_LENGTH];
    
    __block CC_SHA512_CTX ctx;
    CC_SHA512_Init(&ctx);
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
    }];
    
    // sha512.addU32(discriminator);
    if (discriminator != nil) {
        int value = [discriminator integerValue];
        char b1[1];
        char b2[1];
        char b3[1];
        char b4[1];
        b1[0] = ((unsigned int)i >> 24 ) & 0xff;
        b2[0] = ((unsigned int)i >> 16 ) & 0xff;
        b3[0] = ((unsigned int)i >> 8 ) & 0xff;
        b4[0] = i & 0xff;
        
        NSData *datab1 = [[NSData alloc] initWithBytes:b1 length:1];
        NSData *datab2 = [[NSData alloc] initWithBytes:b2 length:1];
        NSData *datab3 = [[NSData alloc] initWithBytes:b3 length:1];
        NSData *datab4 = [[NSData alloc] initWithBytes:b4 length:1];
        
        [datab1 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
        [datab2 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
        [datab3 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
        [datab4 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
    }
    
    // sha512.addU32((int) i);
    {
        char b1[1];
        char b2[1];
        char b3[1];
        char b4[1];
        b1[0] = (i >> 24 ) & 0xff;
        b2[0] = (i >> 16 ) & 0xff;
        b3[0] = (i >> 8 ) & 0xff;
        b4[0] = i & 0xff;
        
        NSData *datab1 = [[NSData alloc] initWithBytes:b1 length:1];
        NSData *datab2 = [[NSData alloc] initWithBytes:b2 length:1];
        NSData *datab3 = [[NSData alloc] initWithBytes:b3 length:1];
        NSData *datab4 = [[NSData alloc] initWithBytes:b4 length:1];
        
        [datab1 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
        [datab2 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
        [datab3 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
        [datab4 enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            CC_SHA512_Update(&ctx, bytes, (CC_LONG)byteRange.length);
        }];
    }
    
    CC_SHA512_Final(digest, &ctx);
    
    memcpy(digest2, digest, CC_SHA256_DIGEST_LENGTH);
    NSMutableData* result = [NSMutableData dataWithBytes:digest2 length:CC_SHA256_DIGEST_LENGTH];
    BTCSecureMemset(digest, 0, CC_SHA512_DIGEST_LENGTH);
    
    BTCBigNumber* bn = [[BTCBigNumber alloc] initWithUnsignedBigEndian:result];
    // 参考文件 BTCBlindSignature.m
    BTCBigNumber* curveOrder = [BTCCurvePoint curveOrder];
    if ([bn greater:[BTCBigNumber zero]] && [bn less:curveOrder]) {
        return result;
    }
    
    return nil;
}

@end
