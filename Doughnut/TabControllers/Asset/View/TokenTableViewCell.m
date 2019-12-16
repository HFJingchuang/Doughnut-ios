//
//  TokenTableViewCell.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/11.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TokenTableViewCell.h"
#import "UIColor+Hex.h"

@interface TokenTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenIssuerLabel;


@end

@implementation TokenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.cellView.backgroundColor = [UIColor colorWithHex:0xF4F5F6];
    self.cellView.layer.borderWidth = 1;
    self.cellView.layer.borderColor = [UIColor colorWithHex:0xEEEEF2].CGColor;
    self.cellView.layer.cornerRadius = 10;
    self.cellView.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _cellNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _tokenIssuerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

- (void)setFrame:(CGRect)frame{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
    self.cellView.layer.cornerRadius = 10;
    self.cellView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)updateWithModel:(NSString *)tokenName :(NSString *)issuer {
    self.cellNameLabel.text = tokenName;
    self.tokenIssuerLabel.text = issuer;
    UIImage *img = [UIImage imageNamed:tokenName];
    if ([tokenName isEqualToString:@"CNT"]){
        img = [UIImage imageNamed:@"CNY"];
    }
    if (img)
    {
        self.cellImage.image = img;
    }else {
        self.cellImage.image = [UIImage imageNamed:@"icon_default"];
    }
}

-(void)setSelected:(BOOL)status {
    _clickImage.highlighted = status;
}

@end
