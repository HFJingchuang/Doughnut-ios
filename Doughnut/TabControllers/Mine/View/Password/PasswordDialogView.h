//
//  PasswordDialogView.h
//  Doughnut
//
//  Created by jch01 on 2019/12/19.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSAlertView.h"
#import <UIKit/UIKit.h>
#import "TPOSWalletModel.h"


@interface PasswordDialogView : TPOSAlertView

@property (nonatomic, strong) TPOSWalletModel *wallet;

@property (nonatomic, copy) void (^confirmAction)(BOOL *back);

+(PasswordDialogView *)passwordDialogViewWithTip:(NSString *)tip;

@end

