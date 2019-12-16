//
//  KeyStore.h
//  WebSocketClient
//
//  Created by jch01 on 2019/8/12.
//  Copyright © 2019 tongmuxu. All rights reserved.
//

#ifndef KeyStore_h
#define KeyStore_h

#import "KeyStoreFile.h"
#import "Wallet.h"

@interface KeyStore : NSObject

+(KeyStoreFileModel*)createStandard:(NSString*)password wallet:(Wallet*)wallet;
+(KeyStoreFileModel*)createLight:(NSString*)password wallet:(Wallet*)wallet;
+(KeyStoreFileModel*)create:(NSString*)password wallet:(Wallet*)wallet n:(int)n p:(int)p;
+(KeyStoreFileModel*)createWalletFile:(Wallet*)wallet cipherText:(NSData*)cipherText iv:(NSData*)iv salt:(NSData*)salt mac:(NSData*)mac n:(int)n p:(int)p;
+(Wallet*) decrypt:(NSString*)password wallerFile:(KeyStoreFileModel*) walletFile;

//NSData to Hex
+(NSString *)convertDataToHexStr:(NSData *)data;
+(NSData*) convertBytesStringToData:(NSString *)str;

//获取设备UUID
+(NSString *)getUUID;

//AES加密解密部分
+(NSData *)cryptData:(NSData *)dataIn  operation:(CCOperation)operation mode:(CCMode)mode algorithm:(CCAlgorithm)algorithm padding:(CCPadding)padding keyLength:(size_t)keyLength iv:(NSData *)iv key:(NSData *)key error:(NSError **)error;

//KECCAK256 MAC加密部分
+(NSData*) generateMac:(NSData*)derivedKey cipherText:(NSData*)cipherText;
@end

#endif /* KeyStore_h */
