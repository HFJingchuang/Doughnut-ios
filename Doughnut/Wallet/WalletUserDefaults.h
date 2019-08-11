//
//  WalletUserDefaults.h
//  Doughnut
//
//  Created by xumingyang on 2019/8/10.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletUserDefaults : NSObject

- (void) insertAddress:(NSString *) address AndSecret:(NSString *) secret;

- (NSString *) getAddress;

- (NSString *) getSecret;

@end

