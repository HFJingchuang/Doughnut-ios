//
//  TPOSMineHeader.m
//  TokenBank
//
//  Created by MarcusWoo on 06/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import "TPOSMineHeader.h"
#import "TPOSLocalizedHelper.h"

@interface TPOSMineHeader()
@property (weak, nonatomic) IBOutlet UIButton *walletButton;
@property (weak, nonatomic) IBOutlet UIButton *transButton;

@property (weak, nonatomic) IBOutlet UILabel *manageLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;

@end

@implementation TPOSMineHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    [self changeLanguage];
}

- (void)changeLanguage {
    self.manageLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_manage"];
    self.recordLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_record"];
}
- (IBAction)onTransactionButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(TPOSMineHeaderDidTapTransactionButton)]) {
        [self.delegate TPOSMineHeaderDidTapTransactionButton];
    }
}
- (IBAction)onReceiverButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(TPOSMineHeaderDidTapReceiverButton)]) {
        [self.delegate TPOSMineHeaderDidTapReceiverButton];
    }
}



@end
