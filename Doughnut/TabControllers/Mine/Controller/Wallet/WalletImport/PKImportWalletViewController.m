//
//  PKImportWalletViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/15.
//  Copyright © 2019 jch. All rights reserved.
//

#import "PKImportWalletViewController.h"
#import "UIColor+Hex.h"
#import "TPOSH5ViewController.h"
#import "NSString+TPOS.h"
#import "TPOSWalletDao.h"
#import "TPOSWalletModel.h"
#import "TPOSMacro.h"
#import "TPOSThreadUtils.h"
#import "TPOSContext.h"
#import "UIImage+TPOS.h"
#import "TPOSBackupAlert.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "PasswordEyeController.h"
#import "WalletManage.h"
#import "NAChloride.h"
#import "TPOSTabBarController.h"


@interface PKImportWalletViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *privateKeyTF;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTF;
@property (weak, nonatomic) IBOutlet UITextField *walletPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;
@property (weak, nonatomic) IBOutlet UILabel *privateKeyTip;
@property (weak, nonatomic) IBOutlet UIButton *comfirmButton;
@property (weak, nonatomic) IBOutlet UILabel *passwordTip;
@property (weak, nonatomic) IBOutlet UILabel *confiremTip;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *termButton;
@property (assign, nonatomic) BOOL creating;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@end

@implementation PKImportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"";
}

- (void)responseLeftButton {
    [(UINavigationController *)self.view.window.rootViewController setViewControllers:@[[[TPOSTabBarController alloc] init]] animated:NO];
    [self.navigationController pushViewController:[[TPOSTabBarController alloc] init] animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.bounces = NO;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self addLeftBarButtonImage:[UIImage imageNamed:@"icon_navi_back"] action:@selector(responseLeftButton)];
}

- (void)changeLanguage {
    self.privateKeyTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"enter_privatekey"];
    self.walletNameTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"];
    self.walletPasswordTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_pwd"];
    self.confirmPasswordTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"repeat_pwd"];
    [self.comfirmButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_wallet"] forState:UIControlStateNormal];
    self.privateKeyTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"error_privateKey"];
    self.privateKeyTip.hidden = YES;
    self.passwordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_tip"];
    self.confiremTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_not_match"];
    self.confiremTip.hidden = YES;
    [self.termButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"service_privacy"] forState:UIControlStateNormal];
    [self.agreeButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"read_agree"] forState:UIControlStateNormal];
}

- (void)setupView {
    self.walletNameTF.delegate = self;
    self.walletPasswordTF.delegate = self;
    self.confirmPasswordTF.delegate = self;
    [self.walletNameTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.privateKeyTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.walletPasswordTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmPasswordTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    PasswordEyeController *eyeBtn1 = [[PasswordEyeController alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    PasswordEyeController *eyeBtn2 = [[PasswordEyeController alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [eyeBtn1 addTarget:self action:@selector(clickEyeBtn1) forControlEvents:UIControlEventTouchUpInside];
    [eyeBtn2 addTarget:self action:@selector(clickEyeBtn2) forControlEvents:UIControlEventTouchUpInside];
    self.walletPasswordTF.rightViewMode = UITextFieldViewModeAlways;
    self.confirmPasswordTF.rightViewMode = UITextFieldViewModeAlways;
    self.walletPasswordTF.rightView = eyeBtn1;
    self.confirmPasswordTF.rightView = eyeBtn2;
    self.comfirmButton.enabled = NO;
    [self.comfirmButton setBackgroundColor:self.comfirmButton.enabled?[UIColor colorWithHex:0x383B3E alpha:1]:[UIColor colorWithHex:0x383B3E alpha:0.5]];
    if (self.scanResult&&self.scanResult.length != 0){
        self.privateKeyTF.text = self.scanResult;
    }
}

-(void)clickEyeBtn1 {
    _walletPasswordTF.secureTextEntry = !_walletPasswordTF.secureTextEntry;
}

-(void)clickEyeBtn2 {
    _confirmPasswordTF.secureTextEntry = !_confirmPasswordTF.secureTextEntry;
}

- (IBAction)clickProtocolButton:(id)sender {
    TPOSH5ViewController *h5VC = [[TPOSH5ViewController alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"service" ofType:@"html" inDirectory:@""];
    h5VC.urlString = [[NSURL fileURLWithPath:filePath] absoluteString];
    h5VC.viewType = kH5ViewTypeTerms;
    h5VC.titleString = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"term_service"];
    [self.navigationController pushViewController:h5VC animated:YES];
}

- (IBAction)clickAgreenBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self checkCreateButtonStatus];
}

- (IBAction)createWalletConfirmAction:(id)sender {
    [SVProgressHUD showWithStatus:nil];
    self.creating = YES;
    NSDictionary *wallet = [[WalletManage shareWalletManage]createWalletWithSecret:self.privateKeyTF.text];
    if (wallet){
        NSString *address = [wallet valueForKey:@"address"];
        NSString *secret = [wallet valueForKey:@"secret"];
        [self createWalletToServerWithAddress:address toLocalWithPrivateKey:secret mnemonic:nil];
    }else{
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
        self.creating = NO;
        [self checkCreateButtonStatus];
    }
    
}

- (void)createWalletToServerWithAddress:(NSString *)address toLocalWithPrivateKey:(NSString *)privateKey mnemonic:(NSString *)mnemonic {
    __weak typeof(self) weakSelf = self;
    NSString *walletName = self.walletNameTF.text;
    NSString *password = self.walletPasswordTF.text;
    NSTimeInterval milisecondedDate = ([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *walletId = [NSString stringWithFormat:@"%.0f", milisecondedDate];
    TPOSWalletModel *walletModel = [TPOSWalletModel new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    walletModel.createTime = [formatter stringFromDate:[NSDate date]];
    walletModel.walletName = walletName;
    walletModel.address = address;
    NAChlorideInit();
    Seed * seed = [Seed alloc];
    Keypairs *keypairs = [seed deriveKeyPair:privateKey];
    Wallet *wallet = [[Wallet alloc]initWithKeypairs:keypairs private:privateKey];
    KeyStoreFileModel *keyStoreFile = [KeyStore createLight:password wallet:wallet];
    walletModel.keyStore = [keyStoreFile toJSONString];
    walletModel.walletId = walletId;
    walletModel.dbVersion = kDBVersion;
    //存到本地
    [weakSelf.walletDao addWalletWithWalletModel:walletModel complement:^(BOOL success) {
        if (success) {
            [TPOSThreadUtils runOnMainThread:^{
                [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_succ"]];
                weakSelf.creating = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kCreateWalletNotification object:walletModel];
                [weakSelf responseLeftButton];
            }];
        }else {
            [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
            weakSelf.creating = NO;
            [weakSelf checkCreateButtonStatus];
        }
    }];
}

- (void)checkCreateButtonStatus {
    BOOL enable = YES;
    if (_privateKeyTF.text.length == 0||![Wallet isValidSecret:_privateKeyTF.text]) {
        enable = NO;
    }
    if (_walletNameTF.text.length == 0) {
        enable = NO;
    }
    if (_walletPasswordTF.text.length == 0 || _confirmPasswordTF.text.length == 0 ||![self.confirmPasswordTF.text isEqualToString:self.walletPasswordTF.text]) {
        enable = NO;
    }
    if (!_agreeButton.selected){
        enable = NO;
    }
    if (_creating) {
        enable = NO;
    }
    self.comfirmButton.enabled = enable;
    [self.comfirmButton setBackgroundColor:enable?[UIColor colorWithHex:0x383B3E alpha:1]:[UIColor colorWithHex:0x383B3E alpha:0.5]];
}

- (void)textFieldDidChanged:(UITextField *)textfield {
    if ([textfield isEqual:self.walletPasswordTF]){
        if (self.walletPasswordTF.text.length != 0 && ![self.walletPasswordTF.text checkPassword]){
            self.passwordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wrong_fotmat_password"];
        }else{
            [self checkCreateButtonStatus];
            self.passwordTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_tip"];
        }
    }else if ([textfield isEqual:self.confirmPasswordTF]){
        if (self.confirmPasswordTF.text.length != 0 && ![self.confirmPasswordTF.text isEqualToString:self.walletPasswordTF.text]){
            self.confiremTip.hidden = NO;
        }else {
            [self checkCreateButtonStatus];
            self.confiremTip.hidden = YES;
        }
    }else if ([textfield isEqual:self.privateKeyTF]){
        if ([Wallet isValidSecret:self.privateKeyTF.text]){
            [self checkCreateButtonStatus];
            self.privateKeyTip.hidden = YES;
        }else{
            self.privateKeyTip.hidden = NO;
        }
        
    }
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

@end
