//
//  DappTransferDetailDialog.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/12.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DappTransferDetailDialog.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"

@interface DappTransferDetailDialog ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferFrom;
@property (weak, nonatomic) IBOutlet UILabel *transferContent;
@property (weak, nonatomic) IBOutlet UILabel *transferTo;
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *feeValueLabel;
@property (weak, nonatomic) IBOutlet UITextView *memoTV;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation DappTransferDetailDialog


+ (DappTransferDetailDialog *)DappTransferDetailDialogInit {
    DappTransferDetailDialog *dappTransferDetailDialog = [[NSBundle mainBundle] loadNibNamed:@"DappTransferDetailDialog" owner:nil options:nil].firstObject;
    dappTransferDetailDialog.frame = CGRectMake(40, 0, kScreenWidth - 80, 420);
    dappTransferDetailDialog.layer.cornerRadius = 10;
    dappTransferDetailDialog.layer.masksToBounds = YES;
    dappTransferDetailDialog.bottomOffset = kScreenHeight/2;
    return dappTransferDetailDialog;
}

- (IBAction)closeAction:(id)sender {
    [self hide];
}

- (IBAction)comfirmAction:(id)sender {
    _confirmBack(0);
    [self hide];
}


@end
