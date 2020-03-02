//
//  DOSJTNodeDialogView.m
//  Doughnut
//
//  Created by jch01 on 2019/12/18.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DOSJTNodeDialogView.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"

@interface DOSJTNodeDialogView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UITextField *nodeAddrTF;

@end

@implementation DOSJTNodeDialogView

+ (DOSJTNodeDialogView *)DOSJTNodeDialogView{
    DOSJTNodeDialogView *dialogView = [[NSBundle mainBundle] loadNibNamed:@"DOSJTNodeDialogView" owner:nil options:nil].firstObject;
    dialogView.frame = CGRectMake(40, 0, kScreenWidth - 80, 207);
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
    self.titileLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"add_custom_node"];
    self.tipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"node_warn"];
    [self.cancelBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"cancel"] forState:UIControlStateNormal];
    self.nodeAddrTF.placeholder = @"ws://";
    [self.confirmBtn setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"confirm"] forState:UIControlStateNormal];
    self.nodeAddrTF.delegate = self;
    [self.nodeAddrTF addTarget:self action:@selector(clearTip) forControlEvents:UIControlEventEditingDidBegin];
}

- (IBAction)closeAction {
    [self hide];
}

- (IBAction)confirmAction:(id)sender {
    if(_nodeAddrTF.text.length != 0){
        if ([self isNodeUrl:_nodeAddrTF.text]){
            _confirmBack(_nodeAddrTF.text);
            _tipLabel.hidden = YES;
            [self hide];
        }else {
            _nodeAddrTF.text = @"";
            _tipLabel.hidden = NO;
        }
    }
}

- (void)clearTip {
    if(!_tipLabel.hidden){
        _tipLabel.hidden = NO;
    }
    _nodeAddrTF.text = @"";
}

- (BOOL)isNodeUrl:(NSString *)node{
    if([node hasPrefix:@"ws://"]||[node hasPrefix:@"wss://"]){
        NSArray *arr = [[[node stringByReplacingOccurrencesOfString:@"ws://" withString:@""] stringByReplacingOccurrencesOfString:@"wss://" withString:@""] componentsSeparatedByString:@":"];
        if (arr.count == 2) {
            return YES;
        }
    }
    return NO;
}

@end
