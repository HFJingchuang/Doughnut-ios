//
//  TumAmount.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/8/17.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBitcoin/CoreBitcoin.h>

@interface TumAmount : NSObject

@property(nonatomic) long value;
@property(nonatomic) int offset;
@property(nonatomic) BOOL is_native;
@property(nonatomic) BOOL is_negative;
@property(nonatomic, copy) NSString* currency;
@property(nonatomic, copy) NSString* issuer;

-(void)parse_json:(id)in_json;
-(void)parseJson:(NSDictionary*)dic;
-(BOOL)is_zero;
-(BOOL)is_negative;
-(NSData*)tum_to_bytes;

@end
