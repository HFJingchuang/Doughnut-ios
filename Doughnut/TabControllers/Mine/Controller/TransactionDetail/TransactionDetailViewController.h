//
//  TransactionDetailViewController.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/28.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"
#import "WalletManage.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransactionDetailViewController : TPOSBaseViewController

@property (nonatomic, strong) NSString *currentTransactionHash;

@property (nonatomic, strong) NSString *currentWalletAddress;

@end

NS_ASSUME_NONNULL_END
