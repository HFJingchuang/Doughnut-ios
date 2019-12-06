//
//  TokenCellModel.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/17.
//  Copyright © 2019 jch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface TokenCellModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *balance;
@property (nonatomic, copy) NSString *cnyValue;
@property (nonatomic, copy) NSString *trustValue;
@property (nonatomic, copy) NSString *freezeValue;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *issuer;

@end

