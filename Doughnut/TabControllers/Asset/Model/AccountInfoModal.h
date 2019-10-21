//
//  AccountInfoModal.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/15.
//  Copyright © 2019 jch. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MJExtension.h>//;

NS_ASSUME_NONNULL_BEGIN

@interface AccountInfoModal : NSObject

@property (strong,nonatomic) NSNumber *Flags;
@property (copy,nonatomic)   NSString *Balance;
@property (strong,nonatomic) NSNumber *OwnerCount;
@property (copy,nonatomic)   NSString *Account;
@property (copy,nonatomic)   NSString *PreviousTxnID;
@property (strong,nonatomic) NSNumber *PreviousTxnLgrSeq;
@property (strong,nonatomic) NSNumber *Sequence;
@property (copy,nonatomic)   NSString *LedgerEntryType;
@property (copy,nonatomic)   NSString *index;
@end

NS_ASSUME_NONNULL_END
