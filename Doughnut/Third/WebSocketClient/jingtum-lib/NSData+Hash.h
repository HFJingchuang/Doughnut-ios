//
//  NSData+Hash.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/30.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (Hash)

- (NSData *)SHA1;
- (NSData *)SHA256;
- (NSData *)SHA256_2;
- (NSData *)RMD160;
- (NSData *)hash160;
- (NSData *)reverse;

@end
