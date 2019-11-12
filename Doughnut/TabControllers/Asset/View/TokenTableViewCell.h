//
//  TokenTableViewCell.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/11.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenTableViewCell : UITableViewCell

-(void)updateWithModel:(NSString *)tokenName :(NSString *)issuer ;

@property (weak, nonatomic) IBOutlet UIImageView *clickImage;

-(void)setSelected:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
