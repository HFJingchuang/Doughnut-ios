//
//  TPOSWalletManagerCell.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/8.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSWalletManagerCell.h"
#import "UIColor+Hex.h"
#import "TPOSWalletModel.h"

@interface TPOSWalletManagerCell()

@property (weak, nonatomic) IBOutlet UIButton *backupView;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLbael;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenName;
@property (weak, nonatomic) IBOutlet UILabel *tokenValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceCNYLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletType;


@end

@implementation TPOSWalletManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _backupView.layer.cornerRadius = 10;
    self.tokenValueLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:24];
}

- (void)updateWithModel:(TPOSWalletModel *)walletModel {
    self.walletNameLbael.text = walletModel.walletName;
    self.addressLabel.text = walletModel.address;
    _backupView.hidden = walletModel.isBackup;
}

@end
