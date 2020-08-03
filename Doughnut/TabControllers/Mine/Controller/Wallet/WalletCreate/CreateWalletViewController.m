//
//  CreateWalletViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/14.
//  Copyright © 2019 jch. All rights reserved.
//


#import "CreateSuccessViewController.h"
#import "CreateWalletViewController.h"
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
#import "SVProgressHUD.h"
#import "IQKeyboardManager.h"
#import "PasswordEyeController.h"
#import "WalletManage.h"
#import "NAChloride.h"
#import "JTSeed.h"

@interface CreateWalletViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTF;
@property (weak, nonatomic) IBOutlet UITextField *walletPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *comfirmButton;
@property (weak, nonatomic) IBOutlet UILabel *passwordTip;
@property (weak, nonatomic) IBOutlet UILabel *confiremTip;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *termButton;
@property (assign, nonatomic) BOOL creating;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@end

@implementation CreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"";
}

- (void)responseLeftButton {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self addLeftBarButtonImage:[UIImage imageNamed:@"icon_navi_back"] action:@selector(responseLeftButton)];
}

- (void)changeLanguage {
    self.titleLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_wallet"];
    self.walletNameTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"];
    self.walletPasswordTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_pwd"];
    self.confirmPasswordTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"repeat_pwd"];
    [self.comfirmButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_wallet"] forState:UIControlStateNormal]; ;
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
    [self.walletNameTF addTarget:self action:@selector(textFieldEndEditing:) forControlEvents:UIControlEventEditingChanged];
    [self.walletPasswordTF addTarget:self action:@selector(textFieldEndEditing:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmPasswordTF addTarget:self action:@selector(textFieldEndEditing:) forControlEvents:UIControlEventEditingChanged];
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
    NSDictionary *wallet = [[WalletManage shareWalletManage]createWallet];
    if (wallet){
        NSString *address = [wallet valueForKey:@"address"];
        NSString *secret = [wallet valueForKey:@"secret"];
        [self createWalletToServerWithAddress:address toLocalWithPrivateKey:secret mnemonic:nil];
    }else{
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_fail"]];
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
    JTSeed * seed = [JTSeed alloc];
    Keypairs *keypairs = [seed deriveKeyPair:privateKey];
    Wallet *wallet = [[Wallet alloc]initWithKeypairs:keypairs private:privateKey];
    KeyStoreFileModel *keyStoreFile = [KeyStore createLight:password wallet:wallet];
    walletModel.keyStore = [keyStoreFile toJSONString];
    walletModel.privateKey = privateKey;
    walletModel.walletId = walletId;
    walletModel.dbVersion = kDBVersion;
    //存到本地
    [weakSelf.walletDao addWalletWithWalletModel:walletModel complement:^(BOOL success) {
        if (success) {
            [TPOSThreadUtils runOnMainThread:^{
                [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_succ"]];
                weakSelf.creating = NO;
//                [[NSNotificationCenter defaultCenter] postNotificationName:kCreateWalletNotification object:walletModel];
                [weakSelf pushToBackupWalletWithWalletModel:walletModel];
            }];
        }else {
            [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_fail"]];
            weakSelf.creating = NO;
            [weakSelf checkCreateButtonStatus];
        }
    }];
}

- (void)pushToBackupWalletWithWalletModel:(TPOSWalletModel *)walletModel {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCreateWalletNotification object:walletModel];
    CreateSuccessViewController *vc = [[CreateSuccessViewController alloc]init];
    vc.walletModel = walletModel;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)checkCreateButtonStatus {
    BOOL enable = YES;
    if (_walletNameTF.text.length == 0) {
        enable = NO;
    }
    if (_walletPasswordTF.text.length == 0 || _confirmPasswordTF.text.length == 0 ||![self.walletPasswordTF.text checkPassword]||![_confirmPasswordTF.text isEqualToString:_walletPasswordTF.text]) {
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

- (void)textFieldEndEditing:(UITextField *)textfield {
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
    }else {
        [self checkCreateButtonStatus];
    }
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

@end
