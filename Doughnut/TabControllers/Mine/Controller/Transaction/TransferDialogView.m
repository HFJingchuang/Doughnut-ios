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
#import "KeyStoreFile.h"
#import "KeyStore.h"
#import "Wallet.h"
#import "CaclUtil.h"

static long FIFTEEN = 15 * 60 * 1000;
@interface TransferDialogView()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *noPwdBtn;


@end

@implementation TransferDialogView
+ (TransferDialogView *)transactionDialogView{
    TransferDialogView *transferDialogView = [[NSBundle mainBundle] loadNibNamed:@"TransferDialogView" owner:nil options:nil].firstObject;
    transferDialogView.frame = CGRectMake(40, 0, kScreenWidth - 80, 210);
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
    self.passwordTF.delegate = self;
    [self.passwordTF addTarget:self action:@selector(clearTip) forControlEvents:UIControlEventEditingChanged];
}

- (void)clearTip {
    if(_passwordTF.text.length != 0){
        if(!_tipLabel.hidden){
            _tipLabel.hidden = YES;
        }
    }
    
}

- (IBAction)noPwdBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if (sender.selected){
        [defaults setObject:[NSString stringWithFormat:@"%.f",([[NSDate date] timeIntervalSince1970]*1000)] forKey:@"setTime"];
        [defaults synchronize];
    }else{
        [defaults setObject:@"0" forKey:@"setTime"];
        [defaults synchronize];
    }
       
}

- (IBAction)closeAction {
    [self hide];
}

- (IBAction)confirmAction:(id)sender {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSError* err = nil;
    KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.wallet.keyStore error:&err];
    Wallet *decryptEthECKeyPair = [KeyStore decrypt:_passwordTF.text wallerFile:keystore];
    if (decryptEthECKeyPair) {
        _wallet.password = _passwordTF.text;
        _wallet.privateKey = [decryptEthECKeyPair secret];
        if (_noPwdBtn.selected){
            [defaults setObject:_passwordTF.text forKey:@"setPassword"];
            [defaults synchronize];
        }
        _confirmAction([decryptEthECKeyPair secret]);
        _tipLabel.hidden = YES;
        [self hide];
    }else {
        _passwordTF.text = @"";
        _tipLabel.hidden = NO;
    }
}

@end
