//
//  TPOSAssetViewController.h
//  TokenBank
//
//  Created by MarcusWoo on 07/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPOSBaseViewController.h"
#import "WalletManage.h"

@interface TPOSAssetViewController : TPOSBaseViewController
{
    WalletManage *walletManage;
}

- (void)autoRefreshData;

- (void)loadBalance;

- (void)loadCurrentWallet;

@end
