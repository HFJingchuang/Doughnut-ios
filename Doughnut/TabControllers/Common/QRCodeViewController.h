//
//  QRCodeViewController.h
//  Doughnut
//
//  Created by xumingyang on 2019/11/7.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeViewController : TPOSBaseViewController
@property (strong, nonatomic) NSString *walletName;
@property (strong, nonatomic) NSString *walletAddr;

@end

NS_ASSUME_NONNULL_END
