//
//  PasswordDialogView.m
//  Doughnut
//
//  Created by jch01 on 2019/12/19.
//  Copyright © 2019 jch. All rights reserved.
//

#import "PasswordDialogView.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"
#import "KeyStoreFile.h"
#import "KeyStore.h"
#import "Wallet.h"


@interface PasswordDialogView()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UILabel *warnLabel;

@end

@implementation PasswordDialogView

+ (PasswordDialogView *)passwordDialogViewWithTip:(NSString *)tip {
    PasswordDialogView *dialogView = [[NSBundle mainBundle] loadNibNamed:@"PasswordDialogView" owner:nil options:nil].firstObject;
    dialogView.frame = CGRectMake(40, 0, kScreenWidth - 80, 210);
    dialogView.layer.cornerRadius = 10;
    dialogView.layer.masksToBounds = YES;
    dialogView.bottomOffset = kScreenHeight/2;
    dialogView.tipLabel.hidden = YES;
    dialogView.warnLabel.text = tip;
    return dialogView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self changeLanguage];
}

- (void)changeLanguage {
    self.titileLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"auth_pwd"];
    self.tipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_error"];
    [self.cancelBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] forState:UIControlStateNormal];
    [self.confirmBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] forState:UIControlStateNormal];
    self.passwordTF.delegate = self;
    self.passwordTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"input_pwd"];
    [self.passwordTF addTarget:self action:@selector(clearTip) forControlEvents:UIControlEventEditingChanged];
}

- (void)clearTip {
    if(_passwordTF.text.length != 0){
        if(!_tipLabel.hidden){
            _tipLabel.hidden = YES;
        }
    }
    
}

- (IBAction)closeAction {
    [self hide];
}

- (IBAction)confirmAction:(id)sender {
    NSError* err = nil;
    KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.wallet.keyStore error:&err];
    Wallet *decryptEthECKeyPair = [KeyStore decrypt:_passwordTF.text wallerFile:keystore];
    if (decryptEthECKeyPair) {
        _wallet.password = _passwordTF.text;
        _wallet.privateKey = [decryptEthECKeyPair secret];
        _confirmAction(YES);
        _tipLabel.hidden = YES;
        [self hide];
    }else {
        _passwordTF.text = @"";
        _tipLabel.hidden = NO;
    }
}

@end
