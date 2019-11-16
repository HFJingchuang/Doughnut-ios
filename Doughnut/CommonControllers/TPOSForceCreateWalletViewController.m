//
//  TPOSForceCreateWalletViewController.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/17.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSForceCreateWalletViewController.h"
#import "TPOSCreateWalletViewController.h"
#import "TPOSNavigationController.h"
#import "TPOSMacro.h"
#import "UIColor+Hex.h"
#import "TPOSSelectChainTypeViewController.h"
#import "TPOSH5ViewController.h"
#import "CreateWalletViewController.h"
#import "ImportWalletViewController.h"
//#import "TPOSConfirmMemonicViewController.h"
#import "TPOSCameraUtils.h"
#import "TPOSQRResultHandler.h"
#import "TPOSQRCodeResult.h"

@interface TPOSForceCreateWalletViewController ()
@property (weak, nonatomic) IBOutlet UIButton *createWalletButton;
@property (weak, nonatomic) IBOutlet UIButton *importWalletButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noWalletTip;
@property (weak, nonatomic) IBOutlet UILabel *tip;
@property (weak, nonatomic) IBOutlet UIImageView *scanView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation TPOSForceCreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.createWalletButton.layer.cornerRadius = 8;
    self.createWalletButton.layer.masksToBounds = YES;
    self.importWalletButton.layer.cornerRadius = 8;
    self.importWalletButton.layer.masksToBounds = YES;
}

- (void)changeLanguage {
    self.titleLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"title_label"];
    self.subTitleLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"sub_title"];
    self.noWalletTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_wallet"];
    self.tip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_tip"];
    [self.createWalletButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_wallet"] forState:UIControlStateNormal];
    [self.importWalletButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_wallet"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self animation];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToScan)];
    [self.scanView addGestureRecognizer:tapGesture];
    self.scanView.userInteractionEnabled = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)pushToScan {
    __weak typeof(self) weakSelf = self;
    [[TPOSCameraUtils sharedInstance] startScanCameraWithVC:self completion:^(NSString *result) {
        TPOSQRCodeResult *qrResult = [[TPOSQRResultHandler sharedInstance] codeResultWithScannedString:result];
        
    }];
}

- (void)animation {
//    self.titleLabel.alpha = 0;
//    self.titleLabel.transform = CGAffineTransformMakeTranslation(0, 100);
//    self.subTitleLabel.alpha = 0;
//    self.subTitleLabel.transform = CGAffineTransformMakeTranslation(0, 100);
    self.createWalletButton.alpha = 0;
    self.createWalletButton.transform = CGAffineTransformMakeTranslation(0, 100);
    self.importWalletButton.alpha = 0;
    self.importWalletButton.transform = CGAffineTransformMakeTranslation(0, 100);
    
    [UIView animateWithDuration:1 animations:^{
//        self.titleLabel.alpha = 1;
//        self.subTitleLabel.alpha = 1;
//        self.titleLabel.transform = CGAffineTransformIdentity;
//        self.subTitleLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.createWalletButton.alpha = 1;
            self.importWalletButton.alpha = 1;
            self.createWalletButton.transform = CGAffineTransformIdentity;
            self.importWalletButton.transform = CGAffineTransformIdentity;
        }];
    }];
    
}

- (IBAction)createAction {
    CreateWalletViewController *createWalletViewController = [[CreateWalletViewController alloc] init];
    createWalletViewController.ignoreBackup = NO;
    [self presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:createWalletViewController] animated:YES completion:nil];
}

- (IBAction)importAction {
    ImportWalletViewController *injectWalletViewController = [[ImportWalletViewController alloc] init];
    [self presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:injectWalletViewController] animated:YES completion:nil];
}

@end
