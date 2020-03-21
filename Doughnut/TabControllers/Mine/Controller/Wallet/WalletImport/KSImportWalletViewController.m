//
//  TPOSKeystoreImportWalletViewController.m
//  Doughnut
//
//  Created by ZDC on 2019/9/3.
//  Copyright © 2019 jch. All rights reserved.
//

#import "KSImportWalletViewController.h"
#import "TPOSRetrivePathCell.h"
#import "TPOSH5ViewController.h"
#import "UIImage+TPOS.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"
#import "TPOSBlockChainModel.h"
#import "TPOSThreadUtils.h"
#import "NSString+TPOS.h"
#import "TPOSContext.h"
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import "TPOSWalletModel.h"
#import "NJOPasswordStrengthEvaluator.h"
#import "TPOSPasswordView.h"
#import "TPOSBackupAlert.h"
#import "WalletManage.h"
#import "PasswordEyeController.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "KeyStoreFile.h"
#import "KeyStore.h"
#import "TPOSTabBarController.h"

@interface KSImportWalletViewController ()<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *keystoreHint;
@property (weak, nonatomic) IBOutlet UITextView *keystoreTV;
@property (weak, nonatomic) IBOutlet UILabel *keystorePlaceholder;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *comfirmButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *termButton;
@property (nonatomic, assign) BOOL importing;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@end

@implementation KSImportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}
- (void)changeLanguage {
    self.walletNameTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"];
    self.confirmPasswordTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"repeat_pwd"];
    self.keystoreHint.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"keystore_hint"];
    self.keystorePlaceholder.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"keystore_placeholder"];
    [self.comfirmButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_wallet"] forState:UIControlStateNormal];
    [self.termButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"service_privacy"] forState:UIControlStateNormal];
    [self.agreeButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"read_agree"] forState:UIControlStateNormal];
}

- (void)setupSubviews{
    self.scrollView.bounces = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.keystoreTV.delegate = self;
    self.walletNameTF.delegate = self;
    [self.walletNameTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    self.confirmPasswordTF.delegate = self;
    [self.confirmPasswordTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    PasswordEyeController *eyeBtn = [[PasswordEyeController alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [eyeBtn addTarget:self action:@selector(clickEyeBtn) forControlEvents:UIControlEventTouchUpInside];
    self.confirmPasswordTF.rightViewMode = UITextFieldViewModeAlways;
    self.confirmPasswordTF.rightView = eyeBtn;
    self.comfirmButton.enabled = NO;
    [self.comfirmButton setBackgroundColor:self.comfirmButton.enabled?[UIColor colorWithHex:0x383B3E alpha:1]:[UIColor colorWithHex:0x383B3E alpha:0.5]];
    [self setScanResult:self.scanResult];
}

- (void)responseLeftButton{
    [(UINavigationController *)self.view.window.rootViewController setViewControllers:@[[[TPOSTabBarController alloc] init]] animated:NO];
    [self.navigationController pushViewController:[[TPOSTabBarController alloc] init] animated:NO];
}

-(void)clickEyeBtn {
    _confirmPasswordTF.secureTextEntry = !_confirmPasswordTF.secureTextEntry;
}

- (void)checkImportButtonStatus {
    BOOL enable = YES;
    if (_walletNameTF.text.length == 0) {
        enable = NO;
    }
    if (_confirmPasswordTF.text.length == 0) {
        enable = NO;
    }
    if (!_agreeButton.selected){
        enable = NO;
    }
    if (_importing) {
        enable = NO;
    }
    self.comfirmButton.enabled = enable;
    [self.comfirmButton setBackgroundColor:enable?[UIColor colorWithHex:0x383B3E alpha:1]:[UIColor colorWithHex:0x383B3E alpha:0.5]];
}

#pragma mark - ButtonEvents

- (IBAction)onConfirmProtocolButtonTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    [self checkImportButtonStatus];
}

- (IBAction)onProtocolButtonTapped:(id)sender {
    TPOSH5ViewController *h5VC = [[TPOSH5ViewController alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"service" ofType:@"html" inDirectory:@""];
    h5VC.urlString = [[NSURL fileURLWithPath:filePath] absoluteString];
    h5VC.viewType = kH5ViewTypeTerms;
    h5VC.titleString = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"term_service"];
    [self.navigationController pushViewController:h5VC animated:YES];
}

- (IBAction)onStartImportButtonTapped:(id)sender  {
    [SVProgressHUD showWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"importing"]];
    NSString *keyStoreString = self.keystoreTV.text;
    NSString *password  = self.confirmPasswordTF.text;
    NSLog(@"%@",keyStoreString);
    NSError* err = nil;
    KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:keyStoreString error:&err];
    Wallet *decryptEthECKeyPair = [KeyStore decrypt:password wallerFile:keystore];
    if (!decryptEthECKeyPair){
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"error_keystore"]];
        return;
    }
    Keypairs *temp = [decryptEthECKeyPair keypairs] ;
    NSData *bytes = [[temp pub] BTCHash160];
    BTCAddress *btcAddress = [BTCPublicKeyAddress addressWithData:bytes];
    NSString *address = btcAddress.base58String;
    NSString *privateKey = [decryptEthECKeyPair secret];
    NSLog(@"address: %@", address);
    NSLog(@"PrivateKey:%@",privateKey);
    NSLog(@"%@", err.localizedDescription);
    __block BOOL exist = NO;
    [self.walletDao findAllWithComplement:^(NSArray<TPOSWalletModel *> *walletModels) {
        [walletModels enumerateObjectsUsingBlock:^(TPOSWalletModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.address isEqualToString:address]) {
                exist = YES;
                *stop = YES;
            }
        }];
    }];
    if (exist) {
        [self.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_exist"]];
        return;
    }
    NSString *pkString = privateKey;
    _importing = YES;
    [self checkImportButtonStatus];
    [SVProgressHUD showWithStatus:nil];
    self.importing = YES;
    NSDictionary *wallet = [[WalletManage shareWalletManage]createWalletWithSecret:pkString];
    if (wallet){
        NSString *address = [wallet valueForKey:@"address"];
        NSString *secret = [wallet valueForKey:@"secret"];
        [self createWalletToServerWithAddress:address toLocalWithPrivateKey:secret mnemonic:nil];
    }else{
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
        self.importing = NO;
    }
    
}

- (void)createWalletToServerWithAddress:(NSString *)address toLocalWithPrivateKey:(NSString *)privateKey mnemonic:(NSString *)mnemonic {
    NSLog(@"start Import");
    NSString *walletName = self.walletNameTF.text;
    __weak typeof(self) weakSelf = self;
    weakSelf.importing = NO;
    NSTimeInterval milisecondedDate = ([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *walletId = [NSString stringWithFormat:@"%.0f", milisecondedDate];
    TPOSWalletModel *walletModel = [TPOSWalletModel new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    walletModel.createTime = [formatter stringFromDate:[NSDate date]];
    walletModel.walletName = walletName;
    walletModel.address = address;
    walletModel.keyStore = self.keystoreTV.text;
    walletModel.walletId = walletId;
    walletModel.mnemonic = mnemonic;
    walletModel.dbVersion = kDBVersion;
    walletModel.backup = YES;
    uint32_t index = arc4random()%5+1;
    walletModel.walletIcon = [NSString stringWithFormat:@"icon_wallet_avatar_%u",index];
    //存到本地
    [weakSelf.walletDao addWalletWithWalletModel:walletModel complement:^(BOOL success) {
        if (success) {
            [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_succ"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCreateWalletNotification object:walletModel];
            [weakSelf responseLeftButton];
        } else {
            [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
            weakSelf.importing = NO;
            [weakSelf checkImportButtonStatus];
        }
    }];
    NSLog(@"Import Ok");
}

#pragma mark - UITextViewDelegate

- (void)textFieldDidChanged:(UITextField *)textfield
{
    [self checkImportButtonStatus];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.keystorePlaceholder.hidden = textView.text.length > 0;
    [self checkImportButtonStatus];
}

#pragma mark - Setter
- (void)setScanResult:(NSString *)scanResult
{
    _scanResult = scanResult;
    self.keystoreTV.text = scanResult;
    if (scanResult.length > 0)
    {
        self.keystorePlaceholder.hidden = YES;
    }
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}
@end
