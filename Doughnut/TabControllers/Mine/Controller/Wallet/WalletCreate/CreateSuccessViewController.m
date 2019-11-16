//
//  CreateSuccessViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/14.
//  Copyright © 2019 jch. All rights reserved.
//
#import "TPOSBackupAlert.h"
#import "CreateSuccessViewController.h"

@interface CreateSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *backupButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation CreateSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_title"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xffffff]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (UIButton *)backStyleButton {
    return nil;
}

- (void)changeLanguage {
    self.titleLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_success"];
    self.tipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"tip_label"];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[[NSString stringWithFormat:@"%@%@%@",[[TPOSLocalizedHelper standardHelper] stringWithKey:@"content_warn"],@"<br><br>",[[TPOSLocalizedHelper standardHelper] stringWithKey:@"content_tip"]] dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.contentLabel.attributedText = attrStr;
    self.contentLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    [self.backupButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"backup_now"] forState:UIControlStateNormal];
    [self.skipButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"skip_now"] forState:UIControlStateNormal];
}

- (IBAction)backupNowAction:(id)sender {
    [TPOSBackupAlert showWithWalletModel:_walletModel inView:self.view.window.rootViewController.view navigation:(id)self.view.window.rootViewController];
}

- (IBAction)skipAction:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
