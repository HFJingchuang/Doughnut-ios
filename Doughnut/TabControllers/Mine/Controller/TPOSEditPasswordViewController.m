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
#import "ImportWalletViewController.h"
#import "NJOPasswordStrengthEvaluator.h"
#import "TPOSPasswordView.h"
#import "PasswordEyeController.h"
#import "NAChloride.h"
#import "Seed.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Toast/Toast.h>

@interface TPOSEditPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *newsPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *renewsPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *oldPasswordTip;
@property (weak, nonatomic) IBOutlet UILabel *passwordTip;
@property (weak, nonatomic) IBOutlet UILabel *confirmTip;

@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, assign) BOOL canCreate;
@property (nonatomic, assign) BOOL rightPassword;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

//localized
@property (weak, nonatomic) IBOutlet UILabel *forgetTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
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
    self.finishButton.enabled = NO;
    [self checkFinishButtonStatus];
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
    self.oldPasswordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_error"];
    self.oldPasswordTip.hidden = YES;
    self.passwordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_tip"];
    self.confirmTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_not_match"];
    self.confirmTip.hidden = YES;
}

#pragma mark - private method

- (void)setupSubviews {
    self.finishButton.layer.cornerRadius = 10;
    self.finishButton.layer.masksToBounds = YES;
    self.newsPasswordField.delegate = self;
    self.oldPasswordField.delegate = self;
    self.renewsPasswordField.delegate = self;
    [self.oldPasswordField addTarget:self action:@selector(textFieldEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [self.newsPasswordField addTarget:self action:@selector(textFieldEndEditing:) forControlEvents:UIControlEventEditingChanged];
    [self.renewsPasswordField addTarget:self action:@selector(textFieldEndEditing:) forControlEvents:UIControlEventEditingChanged];
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
    _newsPasswordField.secureTextEntry = !_newsPasswordField.secureTextEntry;
}

-(void)clickEyeBtn3 {
    _renewsPasswordField.secureTextEntry = !_renewsPasswordField.secureTextEntry;
}

- (IBAction)onFinishButtonTapped:(id)sender {
    NSError* err = nil;
    KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.walletModel.keyStore error:&err];
    Wallet *decryptEthECKeyPair = [KeyStore decrypt:self.oldPasswordField.text wallerFile:keystore];
    NAChlorideInit();
    KeyStoreFileModel *keyStoreFile = [KeyStore createLight:self.newsPasswordField.text wallet:decryptEthECKeyPair];
    self.walletModel.keyStore = [keyStoreFile toJSONString];
    [self.walletDao updateWalletWithWalletModel:self.walletModel complement:^(BOOL success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditWalletNotification object:self.walletModel];
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"save_succ"]];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)checkFinishButtonStatus {
    BOOL enable = YES;
    if (_oldPasswordField.text.length == 0) {
        enable = NO;
    }
    if (!_rightPassword) {
        enable = NO;
    }
    if (_newsPasswordField.text.length == 0 || _renewsPasswordField.text.length == 0||![_newsPasswordField.text checkPassword]||![_renewsPasswordField.text isEqualToString:_newsPasswordField.text]) {
        enable = NO;
    }
    self.finishButton.enabled = enable;
    [self.finishButton setBackgroundColor:enable?[UIColor colorWithHex:0x383B3E alpha:1]:[UIColor colorWithHex:0x383B3E alpha:0.5]];
}

- (IBAction)importAction {
    ImportWalletViewController *vc = [[ImportWalletViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.oldPasswordField]){
        NSError* err = nil;
        KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.walletModel.keyStore error:&err];
        Wallet *decryptEthECKeyPair = [KeyStore decrypt:self.oldPasswordField.text wallerFile:keystore];
        if (decryptEthECKeyPair) {
            _rightPassword = YES;
            self.oldPasswordTip.hidden = YES;
            [self checkFinishButtonStatus];
        }else {
            _rightPassword = NO;
            self.oldPasswordTip.hidden = NO;
            [self checkFinishButtonStatus];
        }
    }else if ([textField isEqual:self.newsPasswordField]){
        if ([self.newsPasswordField.text checkPassword]){
            [self checkFinishButtonStatus];
            self.passwordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_tip"];
        }else {
             self.passwordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wrong_fotmat_password"];
        }
    }else if ([textField isEqual:self.renewsPasswordField]){
        if (self.renewsPasswordField.text.length != 0 && ![self.renewsPasswordField.text isEqualToString:self.newsPasswordField.text]){
            self.confirmTip.hidden = NO;
        }else {
            [self checkFinishButtonStatus];
            self.confirmTip.hidden = YES;
        }
    }
}

@end
