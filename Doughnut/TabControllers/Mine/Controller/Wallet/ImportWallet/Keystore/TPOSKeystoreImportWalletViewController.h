//
//  TPOSKeystoreImportWalletViewController.h
//  Doughnut
//
//  Created by ZDC on 2019/9/3.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"

@class TPOSBlockChainModel;

@interface TPOSKeystoreImportWalletViewController : TPOSBaseViewController
@property (nonatomic, strong) TPOSBlockChainModel *blockchain;
@property (nonatomic, strong) NSString *scanResult;
@end
