//
//  UILabel+Btn.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/2.
//  Copyright © 2019 jch. All rights reserved.
//

#import "UILabel+Btn.h"
#import "SVProgressHUD.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"

@implementation UILabel (Btn)

- (void)addCopyBtnWithImg {
    NSTextAttachment *attatch = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    attatch.bounds = CGRectMake(5, 0, 16, 16);
    attatch.image = [UIImage imageNamed:@"icon_wallet_copy"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyAction)];
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES;
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attatch];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc]initWithString:self.text];
    [string1 insertAttributedString:string atIndex:string1.length];
    self.attributedText = string1;
}

- (void)addLongPressCopy {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyAction)];
    [self addGestureRecognizer:longPress];
    self.userInteractionEnabled = YES;
}

-(void)copyAction {
    [[UIPasteboard generalPasteboard] setString:self.text];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithHex:0x27B498]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithHex:0xFFFFFF]];
    [SVProgressHUD showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"copy_to_board"]];
}

@end
