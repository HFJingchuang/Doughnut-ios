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
@property (weak, nonatomic) IBOutlet UIImageView *clickImage;


@end

@implementation TokenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.cellView.backgroundColor = [UIColor colorWithHex:0xF4F5F6];
    self.cellView.layer.cornerRadius = 11;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setFrame:(CGRect)frame{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
