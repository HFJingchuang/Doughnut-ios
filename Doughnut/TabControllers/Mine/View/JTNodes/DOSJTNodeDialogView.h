//
//  DOSJTNodeDialogView.h
//  Doughnut
//
//  Created by jch01 on 2019/12/18.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSAlertView.h"


@interface DOSJTNodeDialogView : TPOSAlertView

@property (nonatomic, copy) void (^confirmBack)(NSString *nodeAddr);

+ (DOSJTNodeDialogView *)DOSJTNodeDialogView;

@end

