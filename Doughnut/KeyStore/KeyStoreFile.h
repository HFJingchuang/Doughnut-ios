//
//  KeyStore.h
//  WebSocketClient
//
//  Created by jch01 on 2019/8/12.
//  Copyright © 2019 tongmuxu. All rights reserved.
//

#ifndef KeyStoreFile_h
#define KeyStoreFile_h

#import "JSONModel.h"

@interface CipherparamsModel : JSONModel
@property (strong, nonatomic) NSString* iv;
@end


@interface KdfparamsModel : JSONModel

@property (assign, nonatomic) int dklen;
@property (assign, nonatomic) NSNumber <Optional> *n;
@property (assign, nonatomic) NSNumber <Optional> *p;
@property (assign, nonatomic) NSNumber <Optional> *r;
@property (assign, nonatomic) NSNumber <Optional> *c;
@property (strong, nonatomic) NSString* salt;
@property (strong, nonatomic) NSString<Optional>* prf;

@end


@interface CryptoModel : JSONModel

@property (strong, nonatomic) NSString* cipher;
@property (strong, nonatomic) NSString* ciphertext;
@property (strong, nonatomic) CipherparamsModel* cipherparams;
@property (strong, nonatomic) NSString* kdf;
@property (strong, nonatomic) KdfparamsModel* kdfparams;
@property (strong, nonatomic) NSString* mac;

@end

@interface KeyStoreFileModel : JSONModel

@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* id;
@property (assign, nonatomic) int version;
@property (strong, nonatomic) CryptoModel* crypto;

@end

#endif
