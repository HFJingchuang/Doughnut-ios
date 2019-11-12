//
//  DOSJTNodesViewCell.m
//  Doughnut
//
//  Created by xumingyang on 2019/9/5.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DOSJTNodesViewCell.h"
#import "UIColor+Hex.h"

@interface DOSJTNodesViewCell()

@property (weak, nonatomic) IBOutlet UIView *nodeView;
@property (weak, nonatomic) IBOutlet UILabel *nodeName;
@property (weak, nonatomic) IBOutlet UILabel *nodeAddr;
@property (weak, nonatomic) IBOutlet UILabel *pingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *clickImage;

@end

@implementation DOSJTNodesViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.nodeView.layer.cornerRadius = 10;
    _nodeView.layer.borderWidth = 1;
}


- (void)setFrame:(CGRect)frame{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        _nodeView.layer.borderColor = [UIColor colorWithHex:0x27B498].CGColor;
        _clickImage.highlighted = selected;
    }else {
        _nodeView.layer.borderColor = [UIColor colorWithHex:0xEEEEF2].CGColor;
        _clickImage.highlighted = selected;
    }
    
}

- (void)updateWithData:(NSDictionary *)data {
    self.nodeName.text = [data valueForKey:@"name"];
    self.nodeAddr.text = [data valueForKey:@"node"];
    self.pingLabel.text = [NSString stringWithFormat:@"%@ ms",[data valueForKey:@"ping"]?[data valueForKey:@"ping"]:@"--" ];
    if ([self.pingLabel.text isEqualToString:@"-- ms"]){
        self.pingLabel.textColor = [UIColor redColor];
    }
}

@end
