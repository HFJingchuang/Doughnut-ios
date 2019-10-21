//
//  TokenModel.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/14.
//  Copyright © 2019 jch. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenModel : NSObject

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *balance;
@property (nonatomic, copy) NSString *blockchain_id;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, assign) long long decimal;
@property (nonatomic, assign) NSInteger hid;
@property (nonatomic, copy) NSString *icon_url;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
