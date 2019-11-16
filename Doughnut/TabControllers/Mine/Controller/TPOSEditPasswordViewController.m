//
//  TPOSEditPasswordViewController.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/9.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSEditPasswordViewController.h"
#import "UIColor+Hex.h"
#import "TPOSNavigationController.h"
#import "TPOSWalletDao.h"
#import "TPOSWalletModel.h"
#import "TPOSMacro.h"
#import "NSString+TPOS.h"
#import "TPOSSelectChainTypeViewController.h"
#import "NJOPasswordStrengthEvaluator.h"
#import "TPOSPasswordView.h"
#import "PasswordEyeController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Toast/Toast.h>

typedef NS_ENUM(NSUInteger, TPOSEditPasswordResult) {
    TPOSEditPasswordResultSuccess = 1,
    TPOSEditPasswordResultOldPasswordShort,
    TPOSEditPasswordResultNewsPasswordShort,
    TPOSEditPasswordResultNewsPasswordDiff,
};

@interface TPOSEditPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *newsPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *renewsPasswordField;

@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, assign) BOOL canCreate;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

//localized
@property (weak, nonatomic) IBOutlet UILabel *forgetTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UILabel *pwdTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;


@end

@implementation TPOSEditPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD setContainerView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    [self.view setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.forgetTipsLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD setContainerView:self.view];
}

- (void)viewDidReceiveLocalizedNotification {
    [super viewDidReceiveLocalizedNotification];
}

- (void)changeLanguage {
    self.titleLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"change_pwd"];
    self.forgetTipsLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_forget"];
    [self.importButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_imid"] forState:UIControlStateNormal];
    self.oldPasswordField.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pla_pwd_curr"];
    self.newsPasswordField.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pla_pwd_new"];
    self.renewsPasswordField.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pla_pwd_repeat"];
    [self.finishButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"done"] forState:UIControlStateNormal];
    
}

- (void)responseRightButton {
    __weak typeof(self) weakSelf = self;
    NSString *oldPassword = [self.oldPasswordField.text tb_md5];
    NSString *newPassword = [self.newsPasswordField.text tb_md5];
    
    if (![self.newsPasswordField.text isEqualToString:self.renewsPasswordField.text]) {
        [self.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_not_match"] duration:1.0 position:CSToastPositionCenter];
    } else if ([self.walletModel.password isEqualToString:oldPassword]) {
        [SVProgressHUD showWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"saving"]];
        //用新密码替换旧密码并且用新密码重写加密私钥
        NSString *pk = self.walletModel.privateKey;
        NSString *opk = [pk tb_encodeStringWithKey:self.walletModel.password];
        self.walletModel.password = newPassword;
        self.walletModel.privateKey = [opk tb_encodeStringWithKey:newPassword];
        [self.walletDao updateWalletWithWalletModel:self.walletModel complement:^(BOOL success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEditWalletNotification object:weakSelf.walletModel];
            [SVProgressHUD showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"modify_succ"]];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_error"] duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark - private method

- (void)setupSubviews {
    self.finishButton.layer.cornerRadius = 10;
    self.finishButton.layer.masksToBounds = YES;
    [self.newsPasswordField addTarget:self action:@selector(textfieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.newsPasswordField.delegate = self;
    PasswordEyeController *eyeBtn1 = [[PasswordEyeController alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    PasswordEyeController *eyeBtn2 = [[PasswordEyeController alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    PasswordEyeController *eyeBtn3 = [[PasswordEyeController alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [eyeBtn1 addTarget:self action:@selector(clickEyeBtn1) forControlEvents:UIControlEventTouchUpInside];
    [eyeBtn2 addTarget:self action:@selector(clickEyeBtn2) forControlEvents:UIControlEventTouchUpInside];
    [eyeBtn3 addTarget:self action:@selector(clickEyeBtn3) forControlEvents:UIControlEventTouchUpInside];
    self.oldPasswordField.rightViewMode = UITextFieldViewModeAlways;
    self.newsPasswordField.rightViewMode = UITextFieldViewModeAlways;
    self.renewsPasswordField.rightViewMode = UITextFieldViewModeAlways;
    self.oldPasswordField.rightView = eyeBtn1;
    self.newsPasswordField.rightView = eyeBtn2;
    self.renewsPasswordField.rightView = eyeBtn3;
}

-(void)clickEyeBtn1 {
    _oldPasswordField.secureTextEntry = !_oldPasswordField.secureTextEntry;
    
}

-(void)clickEyeBtn2 {
    _newsPasswordField.secureTextEntry = !_oldPasswordField.secureTextEntry;
}

-(void)clickEyeBtn3 {
    _renewsPasswordField.secureTextEntry = !_oldPasswordField.secureTextEntry;
}

- (IBAction)onFinishButtonTapped:(id)sender {
    [self responseRightButton];
}

- (TPOSEditPasswordResult)canCreateAble {
    NSString *oldPassword = self.oldPasswordField.text;
    NSString *password = self.newsPasswordField.text;
    NSString *repassword = self.renewsPasswordField.text;
    if (oldPassword.length < 8) {
        return TPOSEditPasswordResultOldPasswordShort;
    } else if (password.length < 8) {
        return TPOSEditPasswordResultNewsPasswordShort;
    } else if (![password isEqualToString:repassword]) {
        return TPOSEditPasswordResultNewsPasswordDiff;
    }
    return TPOSEditPasswordResultSuccess;
}

- (void)textDidChange:(NSNotification *)note {
    self.canCreate = [self canCreateAble] == TPOSEditPasswordResultSuccess;
}

- (void)textfieldDidChange:(UITextField *)textfield {
    [self showPasswordTipLabelWithField:textfield];
}

- (void)showPasswordTipLabelWithField:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.pwdTipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_length_tip"];
    } else {
        if ([self judgePasswordStrength:textField.text] == eWeakPassword) {
            self.pwdTipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_length_weak"];
        } else {
            self.pwdTipLabel.text = @"";
        }
    }
}

- (IBAction)importAction {
    TPOSSelectChainTypeViewController *vc = [[TPOSSelectChainTypeViewController alloc] init];
    [self presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)setCanCreate:(BOOL)canCreate {
    _canCreate = canCreate;
    if (_canCreate) {
        if (!self.rightButton.userInteractionEnabled) {
            [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.rightButton.userInteractionEnabled = YES;
        }
    } else {
        if (self.rightButton.userInteractionEnabled) {
            [self.rightButton setTitleColor:[UIColor colorWithHex:0xE8E8E8] forState:UIControlStateNormal];
            self.rightButton.userInteractionEnabled = NO;
        }
    }
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

#pragma mark - TODO
- (PasswordEnum)judgePasswordStrength:(NSString*)password {
    
    if (password.length == 0) {
        return eEmptyPassword;
    }
    
    NJOPasswordStrength strength = [NJOPasswordStrengthEvaluator strengthOfPassword:password];
    
    PasswordEnum pwdStrong = eWeakPassword;
    switch (strength) {
        case NJOVeryWeakPasswordStrength:
        case NJOWeakPasswordStrength:
            pwdStrong = eWeakPassword;
            break;
        case NJOReasonablePasswordStrength:
            pwdStrong = eSosoPassword;
            break;
        case NJOStrongPasswordStrength:
            pwdStrong = eGoodPassword;
            break;
        case NJOVeryStrongPasswordStrength:
            pwdStrong = eSafePassword;
            break;
        default:
            break;
    }
    
    return pwdStrong;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showPasswordTipLabelWithField:textField];
}

@end
