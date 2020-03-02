//
//  DappTransferDetailDialog.h
//  Doughnut
//
//  Created by xumingyang on 2019/12/12.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPOSAlertView.h"

@interface DappTransferDetailDialog : TPOSAlertView

@property (nonatomic, copy) void (^confirmBack)(int);

+ (DappTransferDetailDialog *)DappTransferDetailDialogInit;

-(void)setValues:(NSMutableDictionary *)data;

@end

