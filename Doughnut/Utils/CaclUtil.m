//
//  CaclUnit.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/17.
//  Copyright © 2019 jch. All rights reserved.
//

#import "CaclUtil.h"
#import "NSString+TPOS.h"

@implementation CaclUtil

- (NSString *)add:(NSString *)v1 :(NSString *)v2 {
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberByAdding:b2] stringValue];
        } else if (![v1 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v1] stringValue];
        } else if (![v2 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v2] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)add:(NSString *)v1 :(NSString *)v2 :(int) scale {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberByAdding:b2 withBehavior:roundPlain] stringValue];
        } else if (![v1 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v1] stringValue];
        } else if (![v2 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v2] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)sub:(NSString *)v1 :(NSString *)v2 {
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberBySubtracting:b2] stringValue];
        } else if (![v1 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v1] stringValue];
        } else if (![v2 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v2] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)sub:(NSString *)v1 :(NSString *)v2 :(int) scale {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberBySubtracting:b2 withBehavior:roundPlain] stringValue];
        } else if (![v1 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v1] stringValue];
        } else if (![v2 tb_isEmpty]) {
            return [[NSDecimalNumber decimalNumberWithString:v2] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)mul:(NSString *)v1 :(NSString *)v2{
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberByMultiplyingBy:b2] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)mul:(NSString *)v1 :(NSString *)v2 :(int) scale {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberByMultiplyingBy:b2 withBehavior:roundPlain] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)div:(NSString *)v1 :(NSString *)v2{
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberByDividingBy:b2] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSString *)div:(NSString *)v1 :(NSString *)v2 :(int) scale {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            return [[b1 decimalNumberByDividingBy:b2 withBehavior:roundPlain] stringValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return @"0.00";
}

- (NSComparisonResult)compare:(NSString *)v1 :(NSString *)v2 {
    @try {
        if (![v1 tb_isEmpty] && ![v2 tb_isEmpty]) {
            NSDecimalNumber *b1 = [NSDecimalNumber decimalNumberWithString:v1];
            NSDecimalNumber *b2 = [NSDecimalNumber decimalNumberWithString:v2];
            NSComparisonResult result = [b1 compare:b2];
            return result;
        } else if (![v1 tb_isEmpty]) {
            return NSOrderedDescending;
        } else if (![v2 tb_isEmpty]) {
            return NSOrderedAscending;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return NSOrderedAscending;
}

- (NSString *)formatAmount:(NSString *)amount: (int)scale :(BOOL)decimal :(BOOL)digits{
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    @try {
        if(![amount tb_isEmpty]){
            NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:amount];
            NSDecimalNumber *result =[num decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"1"] withBehavior:roundPlain];
            NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
            format.minimumIntegerDigits = 1;
            if (decimal) {
                format.numberStyle = NSNumberFormatterDecimalStyle;
            }else {
                format.numberStyle = NSNumberFormatterNoStyle;
            }
            if (digits) {
                format.minimumFractionDigits = scale;
            }else {
                format.maximumFractionDigits = scale;
            }
            NSString *numStr =[format stringFromNumber:result];
            return numStr;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return amount;
}

@end
