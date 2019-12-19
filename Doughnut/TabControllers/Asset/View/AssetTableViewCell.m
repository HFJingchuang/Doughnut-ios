//
//  AssetTableViewCell.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/11.
//  Copyright © 2019 jch. All rights reserved.
//

#import "AssetTableViewCell.h"
#import "UIColor+Hex.h"
#import "TPOSLocalizedHelper.h"

@interface AssetTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *tokenCellView;
@property (weak, nonatomic) IBOutlet UILabel *tokenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tokenImg;
@property (weak, nonatomic) IBOutlet UILabel *balanceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *CNYBalance;
@property (weak, nonatomic) IBOutlet UILabel *issuerLabel;

@end

@implementation AssetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.tokenCellView.backgroundColor = [UIColor colorWithHex:0xF4F5F6];
    self.tokenCellView.layer.cornerRadius = 10;
    self.tokenCellView.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _tokenNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _issuerLabel.hidden = YES;
}

- (void)setFrame:(CGRect)frame{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)updateWithModel:(NSString *)tokenName :(NSString *)balance :(NSString *)cny :(NSString *)issuer{
    self.tokenNameLabel.text = tokenName;
    self.issuerLabel.text = issuer;
    UIImage *img = [UIImage imageNamed:tokenName];
    if ([tokenName isEqualToString:@"CNT"]){
        img = [UIImage imageNamed:@"CNY"];
    }
    if (img)
    {
       self.tokenImg.image = img;
    }else {
        self.tokenImg.image = [UIImage imageNamed:@"icon_default"];
    }
    self.balanceValueLabel.text = balance;
    self.CNYBalance.text = [NSString stringWithFormat:@"￥ %@",cny];
}

@end

