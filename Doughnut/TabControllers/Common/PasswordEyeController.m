//
//  PasswordEyeController.m
//  Doughnut
//
//  Created by xumingyang on 2019/9/18.
//  Copyright © 2019 jch. All rights reserved.
//

#import "PasswordEyeController.h"

@implementation PasswordEyeController
-(instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame: frame]) {
        [self setImage:[UIImage imageNamed:@"icon_navi_nosee"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"icon_navi_see"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(selectedChanged) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}
-(void)selectedChanged{
    self.selected = !self.selected;
}

@end
