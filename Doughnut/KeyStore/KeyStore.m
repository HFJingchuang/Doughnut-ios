//
//  KeyStore.m
//  WebSocketClient
//
//  Created by jch01 on 2019/8/12.
//  Copyright © 2019 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyStore.h"
#import "NAChloride.h"
#import "Wallet.h"
#import "Seed.h"

#import "NSString+Base58.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonKeyDerivation.h>

#import "NASHA3.h"
#import "NAKeccak.h"

static int N_LIGHT = 1<<12;
static int P_LIGHT = 6;
static int N_STANDARD = 1<<18;
static int P_STANDARD = 1;
static int R = 8;
static int DKLEN = 32;
static int CURRTENT_VERSION = 3;

static NSString* CIPHER = @"aes-128-ctr";
static NSString* AES_128_CTR = @"pbkdf2";
static NSString* SCRYPT = @"scrypt";


@implementation KeyStore

+(KeyStoreFileModel*)createStandard:(NSString*)password wallet:(Wallet*)wallet
{
    return [self create:password wallet:wallet n:N_STANDARD p:P_STANDARD];
}
+(KeyStoreFileModel*)createLight:(NSString*)password wallet:(Wallet*)wallet
{
    return [self create:password wallet:wallet n:N_LIGHT p:P_LIGHT];
}
+(KeyStoreFileModel*)create:(NSString*)password wallet:(Wallet*)wallet n:(int)n p:(int)p
{
    NAChlorideInit();
    
    //NSData *salt =[self convertBytesStringToData:@"51fb4a537aa86674e3cf2141801d1dcaaddaa0ddfd3bbe423f6794767ddb4838"];
    NSData *salt = [NARandom randomData:32];
    NSData *passwordByte = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSData *derivedKey = [NAScrypt scrypt:passwordByte salt:salt N:n r:R p:p length:DKLEN error:&error];
    NSLog(@"derivedKey:%@", [self convertDataToHexStr:derivedKey]);
    
    NSData *encryoptKey =[derivedKey subdataWithRange:NSMakeRange(0, 16)];
    NSLog(@"encryoptKey:%@", [self convertDataToHexStr:encryoptKey]);
    
    //NSData *iv =[self convertBytesStringToData:@"dcbf307ddac9036c0adbca8f2bbdf37a"];
    NSData *iv = [NARandom randomData:16];
    NSLog(@"iv:%@", [self convertDataToHexStr:iv]);
    
    NSData *privateKeyBytes = [[wallet secret] dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"privateKeyBytes:%@", [self convertDataToHexStr:privateKeyBytes]);
    
    NSData *cipherText = [self cryptData:privateKeyBytes
                               operation:kCCEncrypt
                               mode:kCCModeCTR
                               algorithm:kCCAlgorithmAES
                               padding:ccNoPadding
                               keyLength:kCCKeySizeAES128
                               iv:iv
                               key:encryoptKey
                               error:&error];
    NSLog(@"cipherText:%@", [self convertDataToHexStr:cipherText]);
    
    NSData *mac = [self generateMac:derivedKey cipherText:cipherText];
    NSLog(@"mac:%@", [self convertDataToHexStr:mac]);
    
    return [self createWalletFile:wallet cipherText:cipherText iv:iv salt:salt mac:mac n:n p:p];
    
}

+(KeyStoreFileModel*)createWalletFile:(Wallet*)wallet cipherText:(NSData*)cipherText iv:(NSData*)iv salt:(NSData*)salt mac:(NSData*)mac n:(int)n p:(int)p
{
    KeyStoreFileModel* keyStoreFile = [[KeyStoreFileModel alloc]init];
    NSData *bytes = [[[wallet keypairs] getPublicKey] BTCHash160];
    BTCAddress *btcAddress = [BTCPublicKeyAddress addressWithData:bytes];
    NSString *address = btcAddress.base58String;
    
    [keyStoreFile setAddress:address];
    
    CryptoModel *crypto = [[CryptoModel alloc]init];
    [crypto setCipher:CIPHER];
    [crypto setCiphertext:[self convertDataToHexStr:cipherText]];
    
    CipherparamsModel *cipherParams = [[CipherparamsModel alloc]init];
    [cipherParams setIv:[self convertDataToHexStr:iv]];
    [crypto setCipherparams:cipherParams];
    [crypto setKdf:SCRYPT];
    
    KdfparamsModel *kdfParams = [[KdfparamsModel alloc]init];
    [kdfParams setN:[NSNumber numberWithInt:n]];
    [kdfParams setP:[NSNumber numberWithInt:p]];
    [kdfParams setR:[NSNumber numberWithInt:R]];
    [kdfParams setDklen:DKLEN];
    [kdfParams setSalt:[self convertDataToHexStr:salt]];
    [crypto setKdfparams:kdfParams];
    
    [crypto setMac:[self convertDataToHexStr:mac]];
    
    [keyStoreFile setCrypto:crypto];
    [keyStoreFile setId:[self getUUID]];
    
    [keyStoreFile setVersion:CURRTENT_VERSION];

    return keyStoreFile;
}

+(Wallet*) decrypt:(NSString*)password wallerFile:(KeyStoreFileModel*) walletFile
{
    //yanzheng
    
    CryptoModel *crypto = [walletFile crypto];
    
    NSData* mac = [self convertBytesStringToData:[crypto mac]];
    NSData* iv = [self convertBytesStringToData:[[crypto cipherparams]iv]];
    NSData* cipherText = [self convertBytesStringToData:[crypto ciphertext]];
    
    NSData* derivedKey;
    KdfparamsModel *kdfparams = [crypto kdfparams];
    if([kdfparams prf] == nil)
    {
        int dklen = [kdfparams dklen];
        int n = [[kdfparams n]intValue];
        int p = [[kdfparams p]intValue];
        int r = [[kdfparams r]intValue];
        NSData *salt = [self convertBytesStringToData:[kdfparams salt]];
        NSError *error = nil;
        NSData *passwordByte = [password dataUsingEncoding:NSUTF8StringEncoding];
        derivedKey = [NAScrypt scrypt:passwordByte salt:salt N:n r:r p:p length:dklen error:&error];
    }
    else if([kdfparams prf] != nil && [kdfparams c]!=0)
    {
        //未与安卓同步测试
        int dklen = [kdfparams dklen];
        int c = [[kdfparams n]intValue];
        NSData *salt = [self convertBytesStringToData:[kdfparams salt]];
        NSString *prf = [kdfparams prf];
        if([prf isEqualToString: @"hmac-sha256"])
        {
            NSLog(@"Unsupported prf:%@",prf);
            return nil;
        }
        else
        {
            NSData *passwordByte = [password dataUsingEncoding:NSUTF8StringEncoding];
            derivedKey = [self generateAes128CtrDerivedKey:passwordByte salt:salt c:c];
        }
    }
    NSData *derivedMac = [self generateMac:derivedKey cipherText:cipherText];
    if(![derivedMac isEqual:mac])
    {
        NSLog(@"Invaild password provided");
        return nil;
    }
    NSData *encryoptKey = [derivedKey subdataWithRange:NSMakeRange(0, 16)];
    NSError *error = nil;
    NSData *privateKey = [self cryptData:cipherText
                               operation:kCCDecrypt
                                    mode:kCCModeCTR
                               algorithm:kCCAlgorithmAES
                                 padding:ccNoPadding
                               keyLength:kCCKeySizeAES128
                                      iv:iv
                                     key:encryoptKey
                                   error:&error];
    //NSData *privateKey = [self aesDecryptData:cipherText key:encryoptKey iv:iv];
    NSString *privateKeyUTF8 = [[NSString alloc] initWithData:privateKey encoding:NSUTF8StringEncoding];

    Seed *seed = [[Seed alloc] init];
    Keypairs *keypairs = [seed deriveKeyPair:privateKeyUTF8];
    Wallet *wallet = [[Wallet alloc] initWithKeypairs:keypairs private:privateKeyUTF8];
    return wallet;
}

+(NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

+(NSData*) convertBytesStringToData:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= [str length]; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+(NSString *)getUUID
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    
    return result;
}
+ (NSData *)generateAes128CtrDerivedKey:(NSData *)password salt:(NSData *)salt c:(int)c
{
    NSMutableData *hashKeyData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    //success = 0 其他状态看kCCParamError
    int result = CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, c, hashKeyData.mutableBytes, hashKeyData.length);
    NSMutableData *temp = [[NSMutableData alloc] init];
    [temp appendData:salt];
    [temp appendData:hashKeyData];
    return temp;
}

+(NSData*) generateMac:(NSData*)derivedKey cipherText:(NSData*)cipherText
{
    NSMutableData *result = [[NSMutableData alloc]init];
    [result appendData:[derivedKey subdataWithRange:NSMakeRange(16, 16)]];
    [result appendData:cipherText];
    return [NASHA3 SHA3ForData:result algorithm:NASHA3Algorithm_Keccak_256];
}

+ (NSData *)cryptData:(NSData *)dataIn
            operation:(CCOperation)operation  // kCC Encrypt, Decrypt
                 mode:(CCMode)mode            // kCCMode ECB, CBC, CFB, CTR, OFB, RC4, CFB8
            algorithm:(CCAlgorithm)algorithm  // CCAlgorithm AES DES, 3DES, CAST, RC4, RC2, Blowfish
              padding:(CCPadding)padding      // cc NoPadding, PKCS7Padding
            keyLength:(size_t)keyLength       // kCCKeySizeAES 128, 192, 256
                   iv:(NSData *)iv            // CBC, CFB, CFB8, OFB, CTR
                  key:(NSData *)key
                error:(NSError **)error
{
    if (key.length != keyLength) {
        NSLog(@"CCCryptorArgument key.length: %lu != keyLength: %zu", (unsigned long)key.length, keyLength);
        if (error) {
            *error = [NSError errorWithDomain:@"kArgumentError key length" code:key.length userInfo:nil];
        }
        return nil;
    }
    
    size_t dataOutMoved = 0;
    size_t dataOutMovedTotal = 0;
    CCCryptorStatus ccStatus = 0;
    CCCryptorRef cryptor = NULL;
    
    ccStatus = CCCryptorCreateWithMode(operation, mode, algorithm,
                                       padding,
                                       iv.bytes, key.bytes,
                                       keyLength,
                                       NULL, 0, 0, // tweak XTS mode, numRounds
                                       kCCModeOptionCTR_BE, // CCModeOptions
                                       &cryptor);
    
    if (cryptor == 0 || ccStatus != kCCSuccess) {
        NSLog(@"CCCryptorCreate status: %d", ccStatus);
        if (error) {
            *error = [NSError errorWithDomain:@"kCreateError" code:ccStatus userInfo:nil];
        }
        CCCryptorRelease(cryptor);
        return nil;
    }
    
    size_t dataOutLength = CCCryptorGetOutputLength(cryptor, dataIn.length, true);
    NSMutableData *dataOut = [NSMutableData dataWithLength:dataOutLength];
    char *dataOutPointer = (char *)dataOut.mutableBytes;
    
    ccStatus = CCCryptorUpdate(cryptor,
                               dataIn.bytes, dataIn.length,
                               dataOutPointer, dataOutLength,
                               &dataOutMoved);
    dataOutMovedTotal += dataOutMoved;
    
    if (ccStatus != kCCSuccess) {
        NSLog(@"CCCryptorUpdate status: %d", ccStatus);
        if (error) {
            *error = [NSError errorWithDomain:@"kUpdateError" code:ccStatus userInfo:nil];
        }
        CCCryptorRelease(cryptor);
        return nil;
    }
    
    ccStatus = CCCryptorFinal(cryptor,
                              dataOutPointer + dataOutMoved, dataOutLength - dataOutMoved,
                              &dataOutMoved);
    if (ccStatus != kCCSuccess) {
        NSLog(@"CCCryptorFinal status: %d", ccStatus);
        if (error) {
            *error = [NSError errorWithDomain:@"kFinalError" code:ccStatus userInfo:nil];
        }
        CCCryptorRelease(cryptor);
        return nil;
    }
    
    CCCryptorRelease(cryptor);
    
    dataOutMovedTotal += dataOutMoved;
    dataOut.length = dataOutMovedTotal;
    
    return dataOut;
}
@end

