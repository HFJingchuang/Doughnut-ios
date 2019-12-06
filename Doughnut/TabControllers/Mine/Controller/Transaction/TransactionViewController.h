//
//  TransactionViewController.h
//  Doughnut
//
//  Created by xumingyang on 2019/11/8.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransactionViewController : TPOSBaseViewController

@property (nonatomic, copy) NSString *tokenName;
@property (nonatomic, strong) NSString *tokenIssuer;
@property (nonatomic, strong) NSString *tokenBalance;
@property (nonatomic, strong) NSString *gasValue;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *amount;

@end

NS_ASSUME_NONNULL_END
