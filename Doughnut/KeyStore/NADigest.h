//
//  NADigest.h
//
//  Created by ZDC on 2019/8/8.
//  Copyright © 2019 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, NADigestAlgorithm) {
    //NADigestAlgorithmSHA1 = 1, // SHA1 might not be secure enough
    NADigestAlgorithmSHA2_224 = 2,
    NADigestAlgorithmSHA2_256,
    NADigestAlgorithmSHA2_384,
    NADigestAlgorithmSHA2_512,
    
    // Keccak (used to be SHA3)
    NADigestAlgorithmKeccak_256,
    NADigestAlgorithmKeccak_384,
    NADigestAlgorithmKeccak_512,
    
    // SHA3 (finalized)
    NADigestAlgorithmSHA3F_256,
    NADigestAlgorithmSHA3F_384,
    NADigestAlgorithmSHA3F_512,
};

@interface NADigest : NSObject

@property NADigestAlgorithm algorithm;

- (instancetype)initWithAlgorithm:(NADigestAlgorithm)algorithm;

- (NSData *)digestForData:(NSData *)data;

+ (NSData *)digestForData:(NSData *)data algorithm:(NADigestAlgorithm)algorithm;

@end
