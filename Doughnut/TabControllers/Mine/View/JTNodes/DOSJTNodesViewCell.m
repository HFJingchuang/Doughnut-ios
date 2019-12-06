//
//  DOSJTNodesViewCell.m
//  Doughnut
//
//  Created by xumingyang on 2019/9/5.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DOSJTNodesViewCell.h"
#import "UIColor+Hex.h"
#import "NENPingManager.h"
#import "WalletManage.h"

@interface DOSJTNodesViewCell()

@property (weak, nonatomic) IBOutlet UIView *nodeView;
@property (weak, nonatomic) IBOutlet UILabel *nodeName;
@property (weak, nonatomic) IBOutlet UILabel *nodeAddr;
@property (weak, nonatomic) IBOutlet UILabel *pingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *clickImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@property (nonatomic, strong) NENPingManager* pingManager;

@end

@implementation DOSJTNodesViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.nodeView.layer.cornerRadius = 10;
    _nodeView.layer.borderColor = [UIColor colorWithHex:0xEEEEF2].CGColor;
    _nodeView.layer.borderWidth = 1;
    self.loading.hidesWhenStopped = YES;
    [self.loading startAnimating];
    self.pingLabel.hidden = YES;
}


- (void)setFrame:(CGRect)frame{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

- (void)updateWithData:(NSDictionary *)data {
    self.nodeName.text = [data valueForKey:@"name"];
    self.nodeAddr.text = [data valueForKey:@"node"];
    if ([[data valueForKey:@"node"] isEqualToString:[WalletManage shareWalletManage].currentNode]){
        _nodeView.layer.borderColor = [UIColor colorWithHex:0x27B498].CGColor;
        _clickImage.highlighted = YES;
    }else {
        _nodeView.layer.borderColor = [UIColor colorWithHex:0xEEEEF2].CGColor;
        _clickImage.highlighted = NO;
    }
    NSArray *node = [[[[data valueForKey:@"node"] stringByReplacingOccurrencesOfString:@"ws://" withString:@""] stringByReplacingOccurrencesOfString:@"wss://" withString:@""] componentsSeparatedByString:@":"];
    if (node.count != 2) {
        return;
    }
    NSArray *hostNameArray = @[node[0]];
    self.pingManager = [[NENPingManager alloc] init];
    [self.pingManager getFatestAddress:hostNameArray completionHandler:^(NSString *hostName, double ping) {
        if (ping != 0 && ping!=1000){
            self.pingLabel.text = [NSString stringWithFormat:@"%.2f ms",ping];
            if (ping < 60){
                self.pingLabel.textColor = [UIColor colorWithHex:0x04E00C];
            } else if(ping < 100 && ping >60){
                self.pingLabel.textColor = [UIColor colorWithHex:0xFF9800];
            }else {
                self.pingLabel.textColor = [UIColor redColor];
            }
        }else {
            self.pingLabel.text = @"---";
            self.pingLabel.textColor = [UIColor redColor];
        }
        self.pingLabel.hidden = NO;
        [self.loading stopAnimating];
    }];
    
}

@end
