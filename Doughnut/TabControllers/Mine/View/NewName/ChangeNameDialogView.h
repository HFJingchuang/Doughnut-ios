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


@interface ChangeNameDialogView : TPOSAlertView

@property (nonatomic, copy) void (^confirmAction)(NSString *newName);

+(ChangeNameDialogView *)changeNameDialogViewDialogView;

@end

