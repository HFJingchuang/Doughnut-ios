//
//  TPOSMineViewController.m
//  TokenBank
//
//  Created by MarcusWoo on 06/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import "TPOSMineViewController.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"
#import <Masonry/Masonry.h>
#import "TPOSSettingViewController.h"
#import "TPOSAboutUsViewController.h"
#import "TPOSWalletManagerViewController.h"
#import "TPOSTransactionRecoderViewController.h"
#import "DOSPointSettingViewController.h"
#import "DOSCopyrightViewController.h"
#import "TPOSH5ViewController.h"
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import "TPOSContext.h"
#import "TPOSQRCodeReceiveViewController.h"
#import "TPOSNavigationController.h"
#import "TPOSLanguageViewController.h"
#import "TPOSJTManager.h"
#import "TPOSEditWalletViewController.h"
#import "TransactionDetailViewController.h"
#import "QRCodeViewController.h"
#import "QRCodeReceiveViewController.h"
#import "TransactionViewController.h"

@interface TPOSMineViewController ()
//header
@property (weak, nonatomic) IBOutlet UIView *mineHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *walletName;
@property (weak, nonatomic) IBOutlet UILabel *current;
@property (weak, nonatomic) IBOutlet UILabel *walletAddr;
//button
@property (weak, nonatomic) IBOutlet UIButton *reciverButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentConstraint;

//localized
@property (weak, nonatomic) IBOutlet UILabel *walletManageLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferLogLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentVersion;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;

@property (nonatomic, strong) TPOSWalletDao *walletDao;
@property (nonatomic, strong) TPOSWalletModel *currentWallet;
@end

@implementation TPOSMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCurrentWallet];
    [self setupSubviews];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bottomConstraint.constant = kIphoneX?110:70;
    [self setNavigationBarColor];
}

- (void)changeLanguage {
    self.walletManageLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_manage"];
    self.transferLogLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_record"];
    self.pointLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"point_settings"];
    self.versionLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"version"];
    self.languageLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"lang_setting"];
    self.current.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"current"];
    [self.reciverButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"receive_action"] forState:UIControlStateNormal];
    [self.transferButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"transfer_action"]  forState:UIControlStateNormal];
    
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWallet:) name:kChangeWalletNotification object:nil];
}

- (void)changeWallet:(NSNotification *)noti {
    [self loadCurrentWallet];
}

#pragma mark - Private

- (void) loadCurrentWallet {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
    if(_currentWallet) {
        _walletName.text = _currentWallet.walletName;
        _walletAddr.text = _currentWallet.address;
        [_walletName sizeToFit];
        self.currentConstraint.constant = _walletName.frame.size.width + 30;
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [_QRCodeImage addGestureRecognizer:tapGesture];
    _QRCodeImage.userInteractionEnabled = YES;
}

- (void)clickImage {
    QRCodeViewController *vc = [[QRCodeViewController alloc]init];
    vc.walletName = _currentWallet.walletName;
    vc.walletAddr = _currentWallet.address;
    [self.navigationController pushViewController:vc animated:YES];
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

- (void)setupSubviews {
    [self.view sendSubviewToBack:_mineHeaderView];
    _actionView.layer.cornerRadius = 20;
    _actionView.layer.masksToBounds = YES;
    _walletAddr.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _current.layer.masksToBounds = YES;
    _current.layer.cornerRadius = 4;
}

- (void)setNavigationBarColor {
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (IBAction)walletManageAction:(id)sender {
    [self pushToWalletManager];
}

- (IBAction)transferLogAction:(id)sender {
    [self pushToTransactionRecoder];
}

- (IBAction)versionAction:(id)sender {
    [self pushToCopyRight];
}

- (IBAction)languageAction:(id)sender {
    [self pushToLanguageViewController];
}

- (IBAction)pointAction:(id)sender {
    [self pushToPointSetting];
}

- (IBAction)receiverAction:(id)sender {
     [self showQRCodeReceiver];
}

- (IBAction)transferAction:(id)sender {
     [self pushToTransaction];
}

- (IBAction)currentWalletAction:(id)sender {
    TPOSEditWalletViewController *editWalletViewController = [[TPOSEditWalletViewController alloc] init];
    editWalletViewController.currentWallet = _currentWallet;
    [self.navigationController pushViewController:editWalletViewController animated:YES];
}

#pragma mark - push
- (void)pushToTransaction {
    TransactionViewController *transactionViewController = [[TransactionViewController alloc] init];
    [self.navigationController pushViewController:transactionViewController animated:YES];
}

- (void)showQRCodeReceiver {
    QRCodeReceiveViewController *qrVC = [[QRCodeReceiveViewController alloc] init];
    if (_currentWallet) {
        qrVC.walletAddress = _currentWallet.address;
        qrVC.walletName = _currentWallet.walletName;
//      qrVC.tokenAmount = 0;
        [self.navigationController pushViewController:qrVC animated:YES];
    }
    else {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_wallet_tips"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf pushToCreateWallet];
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)pushToTransactionRecoder {
    TPOSTransactionRecoderViewController *transactionRecoderViewController = [[TPOSTransactionRecoderViewController alloc] init];
    [self.navigationController pushViewController:transactionRecoderViewController animated:YES];
}

- (void)pushToWalletManager {
    TPOSWalletManagerViewController *walletManagerViewController = [[TPOSWalletManagerViewController alloc] init];
    [self.navigationController pushViewController:walletManagerViewController animated:YES];
}

- (void)pushToLanguageViewController {
    TPOSLanguageViewController *vc = [[TPOSLanguageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToSetting {
    TPOSSettingViewController *settingViewController = [[TPOSSettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (void)pushToAboutUs {
    TPOSAboutUsViewController *aboutUsViewController = [[TPOSAboutUsViewController alloc] init];
    [self.navigationController pushViewController:aboutUsViewController animated:YES];
}

- (void)pushToHelp {
    TPOSH5ViewController *h5VC = [[TPOSH5ViewController alloc] init];
//    h5VC.urlString = @"http://tokenpocket.skyfromwell.com/help/index.html";
    h5VC.viewType = kH5ViewTypeHelp;
    h5VC.titleString = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"help"];
    [self.navigationController pushViewController:h5VC animated:YES];
}

- (void)pushToPointSetting {
    DOSPointSettingViewController *pointSettingViewController = [[DOSPointSettingViewController alloc]init];
    [self.navigationController pushViewController:pointSettingViewController animated:YES];
}

- (void)pushToCopyRight {
    DOSCopyrightViewController *copyrightViewController = [[DOSCopyrightViewController alloc]init];
    [self.navigationController pushViewController:copyrightViewController animated:YES];
}

@end
