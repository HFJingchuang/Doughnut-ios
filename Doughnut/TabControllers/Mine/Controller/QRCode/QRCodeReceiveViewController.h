//
//  QRCodeReceiveViewController.h
//  Doughnut
//
//  Created by xumingyang on 2019/11/8.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"

@interface QRCodeReceiveViewController : TPOSBaseViewController

@property (nonatomic, copy) NSString *walletName;
@property (nonatomic, copy) NSString *walletAddress;

@property (nonatomic, strong) NSString *tokenName;
@property (nonatomic, strong) NSString *tokenIssuer;

@end

