//
//  TumAmount.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/8/17.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "TumAmount.h"

#define CURRENCY_NAME_LEN 3
#define CURRENCY_NAME_LEN2 6

@implementation TumAmount

@synthesize value;
@synthesize offset;
@synthesize is_native;
@synthesize is_negative;
@synthesize currency;
@synthesize issuer;

-(id)init
{
    if (self = [super init]) {
        value = 0;
        offset = 0;
        is_native = YES;
        is_negative = NO;
        currency = nil;
        issuer = nil;
    }
    
    return self;
}

-(void)parseJson:(NSDictionary*)dic
{
    currency = [dic objectForKey:@"currency"];
    is_native = NO;
    issuer = [dic objectForKey:@"issuer"];
    double vposvalue = [[dic objectForKey:@"value"] doubleValue];
    char buf[32] = {0};
    sprintf(buf, "%e", vposvalue);
    NSString *str = [[NSString alloc] initWithBytes:buf length:strlen(buf) encoding:NSUTF8StringEncoding];
    NSRange loc = [str rangeOfString:@"e"];
    NSString *substr = [str substringFromIndex:loc.location+1];
    int substrvalue = [substr intValue];
    int tmpoffset = 15 - substrvalue;
    long factor = pow(10, tmpoffset);
    long newvalue = vposvalue * factor;
    
    value = newvalue;
    offset = -1*tmpoffset;
}

-(void)parse_json:(id)in_json
{
    if ([in_json isKindOfClass:[NSNumber class]]) {
        //
    } else if ([in_json isKindOfClass:[NSString class]]) {
        //
    } else {
        
    }
}

-(BOOL)isValidAddress:(NSString*)address
{
    return true;
}

-(void)parse_swt_value:(double)value data:(NSMutableData*)so
{
    value = value * 1000000;
    long newvalue = (long)(value+0.5);
    BTCBigNumber *bn = [[BTCBigNumber alloc] initWithInt32:newvalue];
    NSData *data = [bn unsignedData];
    if (data.length >= 32) {
        NSData *subdata = [data subdataWithRange:NSMakeRange(24, 8)];
        
        char *cstr = [subdata bytes];
        int length = 8;
        char ret[8];
        memcpy(ret, cstr, 8);
        ret[0] &= 0x3f;
        ret[0] |= 0x40;
        [so appendBytes:ret length:8];
    }
}

-(BOOL)isTumCode:(NSString*)in_code
{
    BOOL ret = false;
    if ([in_code isEqualToString:@"SWT"] || [self isCurrency:in_code] || [self isCustomTum:in_code]) {
        ret = true;
    }
    
    return ret;
}

-(BOOL)isCurrency:(NSString*)in_code
{
    BOOL ret = false;
    
    int len = [in_code length];
    if (CURRENCY_NAME_LEN <= len && len <= CURRENCY_NAME_LEN2) {
        ret = true;
    }
    
    return ret;
}
// 判断是否只包含数字和字符，To be continue...
-(BOOL)isCustomTum:(NSString*)in_code
{
    BOOL ret = true;
    
    return ret;
}

-(BOOL)is_zero
{
    return false;
}

-(BOOL)is_negative
{
    return is_negative;
}

-(NSData*)tum_to_bytes
{
    NSMutableData *ret = [[NSMutableData alloc] init];
    char currencyData[20];
    memset(currencyData, 0, 20);
    
    if (CURRENCY_NAME_LEN <= [currency length] && [currency length] <= CURRENCY_NAME_LEN2) {
        char *currencyCode = [currency UTF8String];
        int end = 14;
        int len = [currency length] - 1;
        NSData *prev = [NSData dataWithBytes:currencyData length:(14-len)];
        int total = [prev length];
        [ret appendData:prev];
        
        int i = 0;
        for (int j = len; j >= 0; j--) {
            char type = currencyCode[len - j];
//            currencyData[end - j] = type;
            currencyData[i++] = type;
        }
        total += strlen(currencyData);
        [ret appendBytes:currencyData length:strlen(currencyData)];
        int taillen = 20 - total;
        memset(currencyData, 0, 20);
        NSData *tail = [NSData dataWithBytes:currencyData length:taillen];
        [ret appendData:tail];
        
    } else if ([currency length] == 40) {
        NSLog(@"Invalid currency code.");
    } else {
        NSLog(@"Incorrect currency code length.");
    }
    
    return ret;
}

@end
