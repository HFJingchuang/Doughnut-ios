//
//  TPOSEditWalletViewController.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/9.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSEditWalletViewController.h"
#import "UIColor+Hex.h"
#import "TPOSEditPasswordViewController.h"
#import "TPOSExportPrivateKeyNoteView.h"
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import "TPOSMacro.h"
#import "WalletManage.h"
#import "TPOSThreadUtils.h"
#import "NSString+TPOS.h"
#import "ExportWalletViewController.h"
#import "TPOSNavigationController.h"
#import "TPOSQRCodeReceiveViewController.h"
#import "TPOSBlockChainModel.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Toast/Toast.h>

@interface TPOSEditWalletViewController ()


@property (weak, nonatomic) IBOutlet UIScrollView *mainView;

@property (weak, nonatomic) IBOutlet UILabel *walletBalanceSWTCLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletBalanceCNYLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UILabel *cahngePwdLabel;
@property (weak, nonatomic) IBOutlet UIButton *renameBtn;
@property (weak, nonatomic) IBOutlet UIButton *addrCopyBtn;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@end

@implementation TPOSEditWalletViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editWallet:) name:kEditWalletNotification object:nil];
//    self.deleteTopConstraint.constant = kIphone5?56:86;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self addLeftBarButtonImage:[UIImage imageNamed:@"icon_back_withe"] action:@selector(responseLeftButton)];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xffffff]}];
    self.view.backgroundColor = [UIColor whiteColor];
    self.mainView.scrollEnabled = YES;
    self.mainView.bounces = NO;
    self.deleteButton.layer.cornerRadius = 10;
    _deleteButton.layer.borderWidth = 1.0;
    _deleteButton.layer.borderColor = [UIColor colorWithHex:0xEEEEF2].CGColor;
}

- (void)responseLeftButton {
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeLanguage {
    self.nameLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_name"];
    self.addrLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_addr"];
    self.cahngePwdLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"change_pwd"];
    [self.exportButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_export"] forState:UIControlStateNormal];
    [self.deleteButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_delete"] forState:UIControlStateNormal];
}

- (void)viewDidReceiveLocalizedNotification {
    [super viewDidReceiveLocalizedNotification];
}

#pragma mark - private method

- (void)loadData {
    self.title = _currentWallet.walletName;
    _walletNameLabel.text = _currentWallet.walletName;
    _addressLabel.text = _currentWallet.address;
    _walletBalanceSWTCLabel.text = _currentWallet.balanceSWTC?_currentWallet.balanceSWTC:@"---";
    _walletBalanceCNYLabel.text = [NSString stringWithFormat:@"%@%@",@"≈￥",_currentWallet.balanceCNY?_currentWallet.balanceCNY:@"---"];
}

- (void)setupViews {
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRename)];
    [_renameBtn addGestureRecognizer:tapGesture1];
    _renameBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCopyBtn)];
    [_addrCopyBtn addGestureRecognizer:tapGesture2];
    _addrCopyBtn.userInteractionEnabled = YES;
}

- (void) clickRename {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    __weak typeof(alertController) weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = weakAlertController.textFields.firstObject.text;
        if (name && name.length > 0) {
            self.currentWallet.walletName = name;
            [self.walletDao updateWalletWithWalletModel:self.currentWallet complement:^(BOOL success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEditWalletNotification object:self.currentWallet];
            }];
        }else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_name_null"] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

-(void)clickCopyBtn{
    if (_addressLabel.text &&_addressLabel.text.length >0){
        [[UIPasteboard generalPasteboard] setString:_addressLabel.text];
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"copy_to_board"]];
    }
}

- (void)editWallet:(NSNotification *)note {
    TPOSWalletModel *n = (TPOSWalletModel *)note.object;
    if ([_currentWallet.walletId isEqualToString:n.walletId]) {
        _currentWallet = n;
        [self loadData];
    }
}

- (IBAction)deleteAction {
    __weak typeof(self) weakSelf = self;
    [self alertRequiredPasswordWithSubTilte:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"delete_caution"] action:^{
        weakSelf.deleteButton.userInteractionEnabled = NO;
        [SVProgressHUD showWithStatus:nil];
        [weakSelf.walletDao deleteWalletWithAddress:weakSelf.currentWallet.address complement:^(BOOL success) {
            if (success) {
                [TPOSThreadUtils runOnMainThread:^{
                    [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"delete_succ"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteWalletNotification object:weakSelf.currentWallet];
                    [weakSelf responseLeftButton];
                }];
            } else {
                weakSelf.deleteButton.userInteractionEnabled = YES;
                [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"delete_fail"]];
            }
        }];
    }];
}

- (void)alertRequiredPasswordWithSubTilte:(NSString *)subTitle action:(void (^)(void))actionBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"input_pwd"] message:subTitle preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"input_pwd"];
        textField.secureTextEntry = YES;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    __weak typeof(alertController) weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSError* err = nil;
        KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.currentWallet.keyStore error:&err];
        Wallet *decryptEthECKeyPair = [KeyStore decrypt:weakAlertController.textFields.firstObject.text wallerFile:keystore];
        if (decryptEthECKeyPair) {
            _currentWallet.password = weakAlertController.textFields.firstObject.text;
            _currentWallet.privateKey = [decryptEthECKeyPair secret];
            actionBlock();
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"pwd_error"] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)exportAction {
    __weak typeof(self) weakSelf = self;
    [self alertRequiredPasswordWithSubTilte:nil action:^{
        ExportWalletViewController *vc = [[ExportWalletViewController alloc] init];
        vc.walletModel = _currentWallet;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (IBAction)editPasswordAction {
    __weak typeof(self) weakSelf = self;
    TPOSEditPasswordViewController *vc = [[TPOSEditPasswordViewController alloc] init];
    vc.walletModel = _currentWallet;
    [weakSelf.navigationController pushViewController:vc animated:YES];
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

@end
