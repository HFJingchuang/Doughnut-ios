//
//  TPOSMineViewController.m
//  TokenBank
//
//  Created by MarcusWoo on 06/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import "TPOSMineViewController.h"
#import "TPOSTransactionViewController.h"
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
#import "TPOSQRCodeReceiveViewController.h"
#import "TPOSNavigationController.h"
#import "TPOSLanguageViewController.h"

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

//localized
@property (weak, nonatomic) IBOutlet UILabel *walletManageLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferLogLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentVersion;


@property (nonatomic, strong) TPOSWalletModel *currentWallet;
@end

@implementation TPOSMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarColor];
}

- (void)changeLanguage {
    self.walletManageLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_manage"];
    self.transferLogLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_record"];
    self.pointLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"point_settings"];
    self.versionLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"version"];
    self.copyrightLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"copyright_info"];
    self.languageLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"lang_setting"];
    [self.reciverButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"receive_action"] forState:UIControlStateNormal];
    [self.transferButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"transfer_action"]  forState:UIControlStateNormal];
    
}

- (void)viewDidReceiveLocalizedNotification {
    [super viewDidReceiveLocalizedNotification];
}

#pragma mark - Private

//- (void)setupData {
//    self.tableSources = @[@[],
//                          @[@{@"icon":@"icon_mine_wallet",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_manage"],@"action":@"pushToWalletManager"},
//                            @{@"icon":@"icon_mine_transaction",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_record"],@"action":@"pushToTransactionRecoder"}],
//                          @[
//                            @{@"icon":@"icon_mine_help",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"help"],@"action":@"pushToHelp"},
//                            @{@"icon":@"icon_mine_about",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"about"],@"action":@"pushToAboutUs"},
//                            @{@"icon":@"icon_mine_setting",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"settings"],@"action":@"pushToSetting"},
//                            @{@"icon":@"icon_mine_point",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"point_settings"],@"action":@"pushToPointSetting"},
//                            @{@"icon":@"icon_mine_copyright",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"copyright_info"],@"action":@"pushToCopyright"},
//                            @{@"icon":@"icon_mine_version",@"title":[[TPOSLocalizedHelper standardHelper] stringWithKey:@"version"]}],
//                          @[]
//                          ];
//}

- (void)setupSubviews {
    [self.view sendSubviewToBack:_mineHeaderView];
}

- (void)setNavigationBarColor {
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
//    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_actionView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(20,20)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _actionView.bounds;
    maskLayer.path = maskPath.CGPath;
    _actionView.layer.mask = maskLayer;
    _walletAddr.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _current.layer.masksToBounds = YES;
    _current.layer.cornerRadius = 4;
}

- (IBAction)walletManageAction:(id)sender {
    [self pushToWalletManager];
}

- (IBAction)transferLogAction:(id)sender {
    [self pushToTransactionRecoder];
}

- (IBAction)versionAction:(id)sender {
}
- (IBAction)languageAction:(id)sender {
    [self pushToLanguageViewController];
}

- (IBAction)copyrightAction:(id)sender {
    [self pushToCopyright];
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
    [self pushToWalletManager];
}

#pragma mark - push
- (void)pushToTransaction {
    TPOSTransactionViewController *transactionViewController = [[TPOSTransactionViewController alloc] init];
    
//    [_tokenModels enumerateObjectsUsingBlock:^(TPOSTokenModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.token_type == 0) {
//            transactionViewController.currentTokenModel = obj;
//            *stop = YES;
//        }
//    }];
    [self.navigationController pushViewController:transactionViewController animated:YES];
}

- (void)showQRCodeReceiver {
    TPOSQRCodeReceiveViewController *qrVC = [[TPOSQRCodeReceiveViewController alloc] init];
    
//    if (_currentWallet) {
//        qrVC.address = _currentWallet.address;
//        qrVC.tokenType = [_currentWallet.blockChainId isEqualToString:ethChain] ? @"ETH" : @"SWT" ;
//        qrVC.tokenAmount = 0;
//        qrVC.basicType = [_currentWallet.blockChainId isEqualToString:ethChain] ? TPOSBasicTokenTypeEtheruem : TPOSBasicTokenTypeJingTum;
        TPOSNavigationController *navi = [[TPOSNavigationController alloc] initWithRootViewController:qrVC];
        [self presentViewController:navi animated:YES completion:nil];
    //}
//    else {
//
//        __weak typeof(self) weakSelf = self;
//
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_wallet_tips"] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf pushToCreateWallet];
//        }];
//        [alert addAction:confirmAction];
//
//        [self presentViewController:alert animated:YES completion:nil];
//    }
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

- (void)pushToCopyright {
    DOSCopyrightViewController *copyrightViewController = [[DOSCopyrightViewController alloc]init];
    [self.navigationController pushViewController:copyrightViewController animated:YES];
}

@end
