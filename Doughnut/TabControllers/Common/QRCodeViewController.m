//
//  QRCodeViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/7.
//  Copyright © 2019 jch. All rights reserved.
//

#import "QRCodeViewController.h"
#import "SGQRCode.h"
#import <Masonry/Masonry.h>
#import "UIColor+Hex.h"
#import "TPOSNavigationController.h"

@interface QRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeView;

@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletAddrLabel;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.layer.cornerRadius = 10;
    self.view.backgroundColor = [UIColor colorWithHex:0x3B6CA6];
    [self updateQRCode];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self addLeftBarButtonImage:[UIImage imageNamed:@"icon_back_withe"] action:@selector(responseLeftButton)];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xffffff]}];
    
}

-(void)responseLeftButton{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateQRCode{
    self.walletNameLabel.text = _walletName;
    self.walletAddrLabel.text = _walletAddr;
    if (_walletAddrLabel.text){
        UIImage *code = [SGQRCodeGenerateManager generateWithDefaultQRCodeData:_walletAddr imageViewWidth:150];
        _QRCodeView.image = code;
        _QRCodeView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end
