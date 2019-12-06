//
//  NASHA3.h
//
//  Created by ZDC on 2019/8/8.
//  Copyright © 2019 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, NASHA3Algorithm) {
    NASHA3Algorithm_256 = 2,
    NASHA3Algorithm_384 = 3,
    NASHA3Algorithm_512 = 4,
    
    NASHA3Algorithm_Keccak_256 = 10,
    NASHA3Algorithm_Keccak_384 = 11,
    NASHA3Algorithm_Keccak_512 = 12,
};

@interface NASHA3 : NSObject

+ (NSData *)SHA3ForData:(NSData *)data algorithm:(NASHA3Algorithm)algorithm;

+ (NSData *)SHA3ForDatas:(NSArray *)datas algorithm:(NASHA3Algorithm)algorithm;

@end
