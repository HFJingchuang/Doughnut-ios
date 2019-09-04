//
//  DOSPointSettingViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/8/13.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//

#import "DOSPointSettingViewController.h"

@interface DOSPointSettingViewController ()

@end

@implementation DOSPointSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"point_settings"];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
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
