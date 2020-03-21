//
//  NSString+Base58.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/30.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BITCOIN_PUBKEY_ADDRESS      0
#define BITCOIN_SCRIPT_ADDRESS      5
#define BITCOIN_PUBKEY_ADDRESS_TEST 111
#define BITCOIN_SCRIPT_ADDRESS_TEST 196
#define BITCOIN_PRIVKEY             128
#define BITCOIN_PRIVKEY_TEST        239

#define BIP38_NOEC_PREFIX      0x0142
#define BIP38_EC_PREFIX        0x0143
#define BIP38_NOEC_FLAG        (0x80 | 0x40)
#define BIP38_COMPRESSED_FLAG  0x20
#define BIP38_LOTSEQUENCE_FLAG 0x04
#define BIP38_INVALID_FLAG     (0x10 | 0x08 | 0x02 | 0x01)

CFAllocatorRef SecureAllocator();

@interface NSString (Base58)

+ (NSString *)base58WithData:(NSData *)d;
+ (NSString *)base58checkWithData:(NSData *)d;
+ (NSString *)hexWithData:(NSData *)d;
+ (NSString *)addressWithScript:(NSData *)script;

- (NSData *)base58ToData;
- (NSString *)hexToBase58;
- (NSString *)base58ToHex;

- (NSData *)base58checkToData;
- (NSString *)hexToBase58check;
- (NSString *)base58checkToHex;

- (NSData *)hexToData;
- (NSData *)addressToHash160;

@end
