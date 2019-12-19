//
//  DappMainViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/6.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DappMainViewController.h"
#import "TransferDialogView.h"
#import "NSString+TPOS.h"
#import "DappWKWebViewController.h"

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
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"DAPP" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateSelected];
}

- (IBAction)searchAction:(id)sender {
    NSString *searchUrl = _linkTF.text;
           if (![searchUrl tb_isEmpty]) {
               if ([searchUrl hasPrefix:@"http://"] || [searchUrl hasPrefix:@"https://"]) {
                   DappWKWebViewController *vc = [[DappWKWebViewController alloc]init];
                   vc.htmlUrl = searchUrl;
                   [self.navigationController pushViewController:vc animated:YES];
               } else {
                   [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"err_link"]];
               }
           }
//    TransferDialogView *transferDialogView = [TransferDialogView transactionDialogView];
//    [transferDialogView showWithAnimate:TPOSAlertViewAnimateCenterPop inView:self.view.window];
}


@end
