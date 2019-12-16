//
//  PKExportViewController.h
//  Doughnut
//
//  Created by xumingyang on 2019/11/19.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface PKExportViewController : TPOSBaseViewController

@property (nonatomic, assign) float height;
@property (nonatomic, assign) float width;
@property (nonatomic, copy) NSString *walletName;
@property (nonatomic, copy) NSString *privateKey;

@end

NS_ASSUME_NONNULL_END
