//
//  TableViewCell.h
//  Doughnut
//
//  Created by xumingyang on 2019/11/20.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell

- (void)updateWithData:(NSMutableDictionary *)data;

@end

NS_ASSUME_NONNULL_END
