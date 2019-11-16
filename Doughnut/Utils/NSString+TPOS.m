//
//  NSString+TPOS.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/13.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "NSString+TPOS.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

static inline NSString * NSStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    
    for (int i = 0; i < digestLength; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@implementation NSString (TPOS)

+ (NSString *)guid {
    return [NSUUID UUID].UUIDString;
}

- (BOOL)tb_isEmpty {
    return self.length == 0;
}

- (NSString *)tb_md5 {
    return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, self);
}

- (NSString*)tb_encodeStringWithKey:(NSString*)key {
    NSString *result = self;
    return result;
}
//交易历史显示专用
- (NSAttributedString *)getAttrStringWithV1:(NSString *)v1 C1:(NSString *)c1 V2:(NSString *)v2 C2:(NSString *)c2 TYPE:(NSString *)type {
    NSString *str = @"";
    if ([c1 isEqualToString:@"CNY"]){
        c1 = @"CNT";
    }
    if ([c2 isEqualToString:@"CNY"]){
        c2 = @"CNT";
    }
    if ([type isEqualToString:@"offer"]){
        str = [NSString stringWithFormat:@"<right><font color=\"#3B6CA6\">%@<font color=\"#021E38\">%@ <font color=\"#A6A9AD\">→ <font color=\"#3B6CA6\">%@<font color=\"#021E38\">%@</right>",v1,c1,v2,c2];
    }else if([type isEqualToString:@"send"]){
        str = [NSString stringWithFormat:@"<right><font color=\"#F55758\" size=>%@<font color=\"#021E38\"> %@<right>",v1,c1];
    }else if([type isEqualToString:@"receive"]){
        str = [NSString stringWithFormat:@"<right><font color=\"#27B498\" size=>%@<font color=\"#021E38\"> %@<right>",v1,c1];
    }else{
        str = [NSString stringWithFormat:@"<right><font color=\"#4682B4\" size=>%@<font color=\"#021E38\"> %@<right>",v1,c1];
    }
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    return attrStr;
}

//获取字符串日期
- (NSString *)getDate:(NSNumber *)date year:(BOOL)year {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (!year) {
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *cDate = [[NSDate alloc] initWithTimeIntervalSince1970:([date longValue] + 946684800)];
    NSString *currentDateString = [formatter stringFromDate:cDate];
    return currentDateString;
}

- (BOOL)checkPassword{
    NSString *pattern =@"^(?![0-9]+$)(?![0-9A-Z]+$)(?![0-9a-z]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,64}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

@end
