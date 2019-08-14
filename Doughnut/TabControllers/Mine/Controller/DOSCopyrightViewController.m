//
//  DOSCopyrightViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/8/13.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//

#import "DOSCopyrightViewController.h"

@interface DOSCopyrightViewController ()

@end

@implementation DOSCopyrightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"copyright_info"];
    // Do any additional setup after loading the view from its nib.
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
