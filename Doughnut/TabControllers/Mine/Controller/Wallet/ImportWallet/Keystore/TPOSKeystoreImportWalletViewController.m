//
//  TPOSKeystoreImportWalletViewController.m
//  Doughnut
//
//  Created by ZDC on 2019/9/3.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSKeystoreImportWalletViewController.h"
#import "TPOSRetrivePathCell.h"
#import "TPOSH5ViewController.h"
#import "UIImage+TPOS.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"
#import "TPOSBlockChainModel.h"
#import "TPOSThreadUtils.h"
#import "TPOSWeb3Handler.h"
#import "NSString+TPOS.h"
#import "TPOSContext.h"
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import "TPOSWalletModel.h"
#import "NJOPasswordStrengthEvaluator.h"
#import "TPOSPasswordView.h"
#import "TPOSBackupAlert.h"
#import <jcc_oc_base_lib/JingtumWallet.h>
#import <jcc_oc_base_lib/JTWalletManager.h>
#import <jcc_oc_base_lib/JccChains.h>

#import <Toast/Toast.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "KeyStoreFile.h"
#import "KeyStore.h"

@interface TPOSKeystoreImportWalletViewController ()<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *keystoreHint;
@property (weak, nonatomic) IBOutlet UITextView *keystoreBg;
@property (weak, nonatomic) IBOutlet UILabel *keystorePlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *startImportButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmProtocolButton;
@property (weak, nonatomic) IBOutlet UIButton *protocolDetailButton;

@property (weak, nonatomic) IBOutlet UIView *walletNameView;
@property (weak, nonatomic) IBOutlet UITextField *walletNameField;
@property (weak, nonatomic) IBOutlet UITextField *setPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;

@property (nonatomic, strong) TPOSWalletDao *walletDao;
@property (assign, nonatomic) BOOL creating;

@property (nonatomic, assign) BOOL importing;

@end

@implementation TPOSKeystoreImportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
}
- (void)changeLanguage {
    self.nameLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_name"];
    
    self.pwdLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"input_pwd"];
    
    self.keystoreHint.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"keystore_hint"];
    
    self.keystorePlaceholder.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"keystore_placeholder"];
    
    [self.startImportButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_start"] forState:UIControlStateNormal];
    
    [self.confirmProtocolButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"read_agree"] forState:UIControlStateNormal];
    
    [self.protocolDetailButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"service_privacy"] forState:UIControlStateNormal];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.keystoreBg.layer.borderWidth = 0.5;
    self.keystoreBg.layer.borderColor = [UIColor colorWithHex:0xd8d8d8].CGColor;
    self.keystoreBg.layer.cornerRadius = 2;
    self.keystoreBg.layer.masksToBounds = YES;
    self.keystoreBg.delegate = self;
    
    [self.startImportButton setBackgroundImage:[UIImage tb_imageWithColor:[UIColor colorWithHex:0x2890FE] andSize:CGSizeMake(kScreenWidth, 47)] forState:UIControlStateNormal];
    self.startImportButton.layer.cornerRadius = 4;
    self.startImportButton.layer.masksToBounds = YES;
    self.startImportButton.enabled = NO;
    
    
    self.walletNameField.delegate = self;
    [self.walletNameField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    
    self.setPasswordField.delegate = self;
    [self.setPasswordField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    self.walletNameView.layer.borderColor=[UIColor colorWithHex:0xd8d8d8].CGColor;
    self.walletNameView.layer.borderWidth=0.5;
}

- (void)checkStartButtonStatus {
    BOOL enable = YES;
    if (self.keystoreBg.text.length <= 0) {
        enable = NO;
    }
    if (self.walletNameField.text.length <= 0) {
        enable = NO;
    }
    if (self.setPasswordField.text.length <= 0) {
        enable = NO;
    }
    if (!self.confirmProtocolButton.isSelected) {
        enable = NO;
    }
    self.startImportButton.enabled = enable;
}

#pragma mark - ButtonEvents

- (IBAction)onConfirmProtocolButtonTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    [self checkStartButtonStatus];
}

- (IBAction)onProtocolButtonTapped:(id)sender {
    TPOSH5ViewController *h5VC = [[TPOSH5ViewController alloc] init];
    //    h5VC.urlString = @"http://tokenpocket.skyfromwell.com/terms/index.html";
    h5VC.viewType = kH5ViewTypeTerms;
    h5VC.titleString = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"term_service"];
    [self.navigationController pushViewController:h5VC animated:YES];
}

- (IBAction)onStartImportButtonTapped:(id)sender {

    if (!self.confirmProtocolButton.isSelected)
    {
        [self.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"read_first"] duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    //TODO: - 开始导入
    [self injectAction];
}

- (void)injectAction {
    
    if (_importing) {
        return;
    }
    NSString *keyStoreString = self.keystoreBg.text;
    NSString *password  = self.setPasswordField.text;
    NSLog(keyStoreString);
    NSError* err = nil;
    KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:keyStoreString error:&err];
    Wallet *decryptEthECKeyPair = [KeyStore decrypt:password wallerFile:password];
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
            if ([obj.privateKey isEqualToString:privateKey]) {
                exist = YES;
                *stop = YES;
            }
        }];
    }];
    
    if (exist) {
        [self.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_exist"]];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [SVProgressHUD showWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"importing"]];
    
    NSString *pkString = privateKey;
    
    _importing = YES;
    [self checkStartButtonStatus];
    
    if ([ethChain isEqualToString:_blockchain.hid]) {
        if (![pkString hasPrefix:@"0x"]) {
            pkString = [NSString stringWithFormat:@"0x%@",pkString];
        }
        [[TPOSWeb3Handler sharedManager] retrieveAccoutWithPrivateKey:pkString callBack:^(id responseObject) {
            NSString *address = responseObject[@"address"];
            NSString *privateKey = responseObject[@"privateKey"];
            if (address && privateKey) {
                [weakSelf createWalletToServerWithAddress:address toLocalWithPrivateKey:privateKey mnemonic:nil blockchainId:ethChain];
            } else {
                [SVProgressHUD showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
                weakSelf.importing = NO;
                [weakSelf checkStartButtonStatus];
            }
        }];
    } else if ([swtcChain isEqualToString:_blockchain.hid]) {
        [[JTWalletManager shareInstance] importSecret:pkString chain:SWTC_CHAIN completion:^(NSError *error, JingtumWallet *wallet) {
            if (!error) {
                [weakSelf createWalletToServerWithAddress:wallet.address toLocalWithPrivateKey:wallet.secret mnemonic:nil blockchainId:swtcChain];
            } else {
                [SVProgressHUD showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
                weakSelf.importing = NO;
                [weakSelf checkStartButtonStatus];
            }
        }];
    }
}

- (void)createWalletToServerWithAddress:(NSString *)address toLocalWithPrivateKey:(NSString *)privateKey mnemonic:(NSString *)mnemonic blockchainId:(NSString *)blockchainId {
    NSLog(@"start Import");
    NSString *walletName = self.walletNameField.text;
    NSString *password = [self.setPasswordField.text tb_md5];
    NSString *enprivateKey = [privateKey tb_encodeStringWithKey:password];
    NSString *hit = @"";
    __weak typeof(self) weakSelf = self;
    weakSelf.importing = NO;
    NSTimeInterval milisecondedDate = ([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *walletId = [NSString stringWithFormat:@"%.0f", milisecondedDate];
    TPOSWalletModel *walletModel = [TPOSWalletModel new];
    walletModel.walletName = walletName;
    walletModel.address = address;
    walletModel.privateKey = enprivateKey;
    walletModel.password = password;
    walletModel.passwordTips = hit;
    walletModel.walletId = walletId;
    walletModel.mnemonic = mnemonic;
    walletModel.blockChainId = blockchainId;
    walletModel.dbVersion = kDBVersion;
    walletModel.backup = YES;
    uint32_t index = arc4random()%5+1;
    walletModel.walletIcon = [NSString stringWithFormat:@"icon_wallet_avatar_%u",index];
    //存到本地
    [weakSelf.walletDao addWalletWithWalletModel:walletModel complement:^(BOOL success) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_succ"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCreateWalletNotification object:walletModel];
            [weakSelf responseLeftButton];
        } else {
            [SVProgressHUD showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_fail"]];
            weakSelf.importing = NO;
            [weakSelf checkStartButtonStatus];
        }
    }];
    NSLog(@"Import Ok");
}

#pragma mark - UITextViewDelegate

- (void)textFieldDidChanged:(UITextField *)textfield
{
    [self checkStartButtonStatus];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.keystorePlaceholder.hidden = textView.text.length > 0;
    [self checkStartButtonStatus];
}

#pragma mark - Setter
- (void)setScanResult:(NSString *)scanResult
{
    _scanResult = scanResult;
    self.keystoreBg.text = scanResult;
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
