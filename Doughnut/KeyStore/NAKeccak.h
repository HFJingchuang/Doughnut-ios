//
//  NAKeccak.h
//
//  Created by ZDC on 2019/8/8.
//  Copyright © 2019 tongmuxu. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NAKeccak : NSObject

+ (NSData *)SHA3ForData:(NSData *)data digestBitLength:(NSUInteger)digestBitLength;

+ (NSData *)SHA3ForDatas:(NSArray *)datas digestBitLength:(NSUInteger)digestBitLength;

@end
