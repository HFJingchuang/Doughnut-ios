//
//  TableViewCell.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/20.
//  Copyright © 2019 jch. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ContactTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateWithData:(NSMutableDictionary *)data {
    self.addressLabel.text = [data valueForKey:@"address"];
    self.dateLabel.text = [data valueForKey:@"date"];
    self.contentLabel.text = [data valueForKey:@"content"];
}
@end
