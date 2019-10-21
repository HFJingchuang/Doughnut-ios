//
//  AccountInfoModal.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/15.
//  Copyright © 2019 jch. All rights reserved.
//

#import "AccountInfoModal.h"

@implementation AccountInfoModal

-(id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
     if ([property.name isEqualToString:@"Balance"]) {
         CGFloat value = [oldValue integerValue]/1000000.0;
         NSString *balance = [NSString stringWithFormat:@"%.6f",value];
         return balance;
     }
    return oldValue;
}

@end
