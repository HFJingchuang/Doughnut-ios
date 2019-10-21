//
//  AssetTableViewCell.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/11.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AssetTableViewCell : UITableViewCell

-(void)updateWithModel:(NSString *)tokenName :(NSString *)balance :(NSString *)cny;

@end

NS_ASSUME_NONNULL_END
