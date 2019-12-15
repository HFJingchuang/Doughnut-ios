//
//  DappMainViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/6.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DappMainViewController.h"
#import "TransferDialogView.h"

@interface DappMainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITextField *linkTF;

@end

@implementation DappMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavigationBarColor];
    _searchBtn.layer.cornerRadius = 10;
    _searchBtn.layer.masksToBounds = YES;
}

- (void)changeLanguage {
    _linkTF.placeholder = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"dapp_link"];
    [_searchBtn setTitle:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"search_btn"] forState:UIControlStateNormal];
}

- (void)setNavigationBarColor {
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"";
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (IBAction)searchAction:(id)sender {
    TransferDialogView *transferDialogView = [TransferDialogView transactionDialogView];
    [transferDialogView showWithAnimate:TPOSAlertViewAnimateCenterPop inView:self.view.window];
}


@end
