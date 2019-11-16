//
//  BaseWallet.h
//  jcc_oc_base_lib
//
//  Created by 沐生 on 2019/1/2.
//  Copyright © 2019 JCCDex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension/NSObject+MJKeyValue.h>
@interface BaseWallet : NSObject

@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *address;

@end
