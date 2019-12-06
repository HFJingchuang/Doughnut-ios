//
//  ExportWalletViewController.h
//  Doughnut
//
//  Created by xumingyang on 2019/11/14.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"
#import "TPOSWalletModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExportWalletViewController : TPOSBaseViewController

@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, strong) TPOSWalletModel *walletModel;

@end

NS_ASSUME_NONNULL_END
