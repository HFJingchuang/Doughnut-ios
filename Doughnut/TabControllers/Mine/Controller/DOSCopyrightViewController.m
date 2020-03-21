//
//  DOSCopyrightViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/8/13.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//

#import "DOSCopyrightViewController.h"
#import "UIColor+Hex.h"
#import "Masonry.h"

@interface DOSCopyrightViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UILabel *copyright;

@end

@implementation DOSCopyrightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"copyright_info"];
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    self.icon.image = [UIImage imageNamed:@"company_icon"];
    self.info.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"about_us_desc"];
    [self.info sizeToFit];
    self.copyright.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"copyright"];
}

@end
