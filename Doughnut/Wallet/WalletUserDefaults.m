//
//  WalletUserDefaults.m
//  Doughnut
//
//  Created by xumingyang on 2019/8/10.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//

#import "WalletUserDefaults.h"

//钱包相关信息本地保存类
@implementation WalletUserDefaults

- (void) insertAddress:(NSString *)address AndSecret:(NSString *)secret {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:address forKey:@"walletAddress"];
    [userDefault setObject:secret forKey:@"walletSecret"];
    [userDefault synchronize];
}

- (NSString *) getAddress{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *address = [userDefault objectForKey:@"walletAddress"];
    NSLog(@"add:%@",address);
    return address;
}

- (NSString *) getSecret{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *secret = [userDefault objectForKey:@"walletSecret"];
    NSLog(@"add:%@",secret);
    return secret;
}

@end
