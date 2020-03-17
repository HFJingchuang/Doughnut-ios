//
//  TransferDialogView.h
//  Doughnut
//
//  Created by xumingyang on 2019/12/13.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPOSAlertView.h"
#import "TPOSWalletModel.h"

@interface TransferDialogView : TPOSAlertView

@property (nonatomic, strong) TPOSWalletModel *wallet;

@property (nonatomic, copy) void (^confirmAction)(NSString *backPassword);

+ (TransferDialogView *)transactionDialogView;

@end

