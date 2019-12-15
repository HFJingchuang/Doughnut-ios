//
//  TransferDialogView.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/13.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TransferDialogView.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"

@interface TransferDialogView()
@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *noPwdBtn;


@end

@implementation TransferDialogView
+ (TransferDialogView *)transactionDialogView{
    TransferDialogView *transferDialogView = [[NSBundle mainBundle] loadNibNamed:@"TransferDialogView" owner:nil options:nil].firstObject;
    transferDialogView.frame = CGRectMake(40, 0, kScreenWidth - 80, 227);
    transferDialogView.layer.cornerRadius = 10;
    transferDialogView.layer.masksToBounds = YES;
    transferDialogView.bottomOffset = kScreenHeight/2;
    return transferDialogView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self changeLanguage];
}

- (void)changeLanguage {
    self.titileLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"auth_pwd"];
    self.tipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_error"];
    [self.noPwdBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_pwd_transfer"] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] forState:UIControlStateNormal];
    [self.confirmBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] forState:UIControlStateNormal];
}

- (IBAction)closeAction {
    [self hide];
}

- (IBAction)confirmAction {
    [self hide];
}



@end
