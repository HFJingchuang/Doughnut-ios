//
//  DOSJTNodesViewCell.h
//  Doughnut
//
//  Created by xumingyang on 2019/9/5.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DOSJTNodesViewCell : UITableViewCell

- (void)updateWithData:(NSDictionary *)data;

- (void)updateSelectStatus:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
