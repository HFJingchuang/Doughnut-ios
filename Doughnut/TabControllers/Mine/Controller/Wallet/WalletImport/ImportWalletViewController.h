//
//  TPOSImportWalletViewController.h
//  TokenBank
//
//  Created by MarcusWoo on 11/02/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import "TPOSBaseViewController.h"

@interface ImportWalletViewController : TPOSBaseViewController

@property (nonatomic, assign) NSInteger *importFlag;

@property (nonatomic, copy) NSString *privateKey;
@property (nonatomic, copy) NSString *keyStore;
@end
