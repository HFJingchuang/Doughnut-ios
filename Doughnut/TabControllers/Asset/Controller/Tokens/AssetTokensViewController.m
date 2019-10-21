//
//  AssetTokensViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/10.
//  Copyright © 2019 jch. All rights reserved.
//

#import "AssetTokensViewController.h"
#import "UIColor+Hex.h"

@interface AssetTokensViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *tokenSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tokensTable;

@end

@implementation AssetTokensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"add_tokens"];
    self.navigationController.navigationBarHidden = NO;
}

- (void)changeLanguage {
}

- (void)setupSubviews {
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
