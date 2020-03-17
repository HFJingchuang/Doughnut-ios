//
//  NSString+TPOS.h
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/13.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TPOS)

+ (NSString *)guid;

- (BOOL)tb_isEmpty;

- (NSString *)tb_md5;

//可逆加密
- (NSString*)tb_encodeStringWithKey:(NSString*)key;

- (NSAttributedString *)getAttrStringWithV1:(NSString *)v1 C1:(NSString *)c1 V2:(NSString *)v2 C2:(NSString *)c2 TYPE:(NSString *)type;

- (NSString *)getDate:(NSNumber *)date year:(BOOL)year;
//密码验证
- (BOOL)checkPassword;
//去除数字后面的0
- (NSString *)deleteFloatAllZero;

@end
