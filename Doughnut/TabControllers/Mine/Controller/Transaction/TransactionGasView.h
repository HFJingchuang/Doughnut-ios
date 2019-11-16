//
//  TPOSTransactionGasView.h
//  TokenBank
//
//  Created by xiaoyuan on 2018/2/3.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSAlertView.h"

@interface TransactionGasView : TPOSAlertView

@property (nonatomic, copy) void (^getGasPrice)(CGFloat gas);

+ (TransactionGasView *)transactionViewWithMinFee:(CGFloat)min maxFee:(CGFloat)max recommentFee:(CGFloat)recomment;

@end
