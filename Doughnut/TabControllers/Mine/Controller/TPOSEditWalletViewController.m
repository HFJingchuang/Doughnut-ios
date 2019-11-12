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
#import "TPOSCreateMemonicViewController.h"
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleConstraint;

@property (weak, nonatomic) IBOutlet UILabel *cahngePwdLabel;
@property (weak, nonatomic) IBOutlet UIButton *copyyBtn;

@property (nonatomic, strong) TPOSWalletDao *walletDao;
@property (nonatomic, strong) WalletManage *walletManage;

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

- (void)responseRightButton {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"saving"]];
    weakSelf.currentWallet.walletName = weakSelf.walletNameLabel.text;
    [weakSelf.walletDao updateWalletWithWalletModel:weakSelf.currentWallet complement:^(BOOL success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditWalletNotification object:weakSelf.currentWallet];
        [SVProgressHUD showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"save_succ"]];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
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
    [_walletBalanceSWTCLabel sizeToFit];
    _titleConstraint.constant = _walletBalanceSWTCLabel.frame.origin.x + _walletBalanceSWTCLabel.frame.size.width + 10;
    _walletBalanceCNYLabel.text = [NSString stringWithFormat:@"%@%@",@"≈￥",_currentWallet.balanceCNY?_currentWallet.balanceCNY:@"---"];
}

- (void)setupViews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)editWallet:(NSNotification *)note {
    TPOSWalletModel *n = (TPOSWalletModel *)note.object;
    if ([_currentWallet.walletId isEqualToString:n.walletId]) {
        _currentWallet = n;
    }
}

- (IBAction)copyAddressAction {
    [[UIPasteboard generalPasteboard] setString:_addressLabel.text];
    [self.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"copy_to_board"]];
}

- (IBAction)editPasswordAction {
    TPOSEditPasswordViewController *editPasswordViewController = [[TPOSEditPasswordViewController alloc] init];
    editPasswordViewController.walletModel = self.currentWallet;
    [self.navigationController pushViewController:editPasswordViewController animated:YES];  
}

- (IBAction)deleteAction {
    __weak typeof(self) weakSelf = self;
    [self alertRequiredPasswordWithSubTilte:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"delete_caution"] action:^{
        weakSelf.deleteButton.userInteractionEnabled = NO;
        [SVProgressHUD showWithStatus:nil];
        [weakSelf.walletDao deleteWalletWithAddress:weakSelf.currentWallet.address complement:^(BOOL success) {
            if (success) {
                [TPOSThreadUtils runOnMainThread:^{
                    [SVProgressHUD showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"delete_succ"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteWalletNotification object:weakSelf.currentWallet];
                    [weakSelf responseLeftButton];
                }];
            } else {
                weakSelf.deleteButton.userInteractionEnabled = YES;
                [SVProgressHUD showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"delete_fail"]];
            }
        }];
    }];
}

- (void)alertRequiredPasswordWithSubTilte:(NSString *)subTitle action:(void (^)(void))actionBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"input_pwd"] message:subTitle preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"password";
        textField.secureTextEntry = YES;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    __weak typeof(alertController) weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if ([[weakAlertController.textFields.firstObject.text tb_md5] isEqualToString:self.currentWallet.password]) {
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
        TPOSCreateMemonicViewController *createPrivateKeyViewController = [[TPOSCreateMemonicViewController alloc] init];
        createPrivateKeyViewController.walletModel = _currentWallet;
        createPrivateKeyViewController.privateWords = [[_currentWallet.mnemonic tb_encodeStringWithKey:_currentWallet.password] componentsSeparatedByString:@" "];
        [weakSelf.navigationController presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:createPrivateKeyViewController] animated:YES completion:nil];
    }];
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

- (WalletManage *)walletManage {
    if (!_walletManage) {
        _walletManage = [[WalletManage alloc]init];
    }
    return _walletManage;
}

@end
