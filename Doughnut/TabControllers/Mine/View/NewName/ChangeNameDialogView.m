//
//  PasswordDialogView.m
//  Doughnut
//
//  Created by jch01 on 2019/12/19.
//  Copyright © 2019 jch. All rights reserved.
//

#import "ChangeNameDialogView.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"


@interface ChangeNameDialogView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UITextField *nameTF;

@end

@implementation ChangeNameDialogView

+ (ChangeNameDialogView *)changeNameDialogViewDialogView {
    ChangeNameDialogView *dialogView = [[NSBundle mainBundle] loadNibNamed:@"ChangeNameDialogView" owner:nil options:nil].firstObject;
    dialogView.frame = CGRectMake(40, 0, kScreenWidth - 80, 200);
    dialogView.layer.cornerRadius = 10;
    dialogView.layer.masksToBounds = YES;
    dialogView.bottomOffset = kScreenHeight/2;
    dialogView.tipLabel.hidden = YES;
    return dialogView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self changeLanguage];
}

- (void)changeLanguage {
    self.titileLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"];
    self.tipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_name_null"];
    [self.cancelBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] forState:UIControlStateNormal];
    [self.confirmBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] forState:UIControlStateNormal];
    self.nameTF.delegate = self;
    self.nameTF.placeholder = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"set_wallet_name"];
}

- (IBAction)closeAction {
    [self hide];
}

- (IBAction)confirmAction:(id)sender {
    NSString *name = [_nameTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (name.length != 0) {
        _confirmAction(name);
        _tipLabel.hidden = YES;
        [self hide];
    }else {
        _nameTF.text = @"";
        _tipLabel.hidden = NO;
    }
}

@end
