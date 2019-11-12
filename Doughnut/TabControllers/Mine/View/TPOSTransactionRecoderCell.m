//
//  TPOSTransactionRecoderCell.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/9.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSTransactionRecoderCell.h"
#import "TPOSTransactionRecoderModel.h"
#import "TPOSContext.h"
#import "TPOSWalletModel.h"
#import "TPOSWeb3Handler.h"
#import "TPOSTokenModel.h"
#import "NSDate+TPOS.h"
#import "NSString+TPOS.h"
#import "TPOSJTPaymentInfo.h"
#import "TPOSLocalizedHelper.h"
#import "TPOSMacro.h"
#import "UIColor+Hex.h"
#import "NSDate+TPOS.h"
#import "CaclUtil.h"

@interface TPOSTransactionRecoderCell()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@end

@implementation TPOSTransactionRecoderCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateWithData:(NSMutableDictionary *) cellData {
    CaclUtil *cacl = [[CaclUtil alloc]init];
    NSString *type = [cellData valueForKey:@"type"];
    NSString *v1 = @"";
    NSString *c1 = @"";
    NSString *v2 = @"";
    NSString *c2 = @"";
    if([[cellData allKeys]containsObject:@"amount"]){
        v1 = [[cellData valueForKey:@"amount"]valueForKey:@"value"];
        c1 = [[cellData valueForKey:@"amount"]valueForKey:@"currency"];
    }else if([[cellData allKeys]containsObject:@"takerGets"]&&[[cellData allKeys]containsObject:@"takerPays"]){
        v1 = [cacl formatAmount:[[cellData valueForKey:@"takerGets"]valueForKey:@"value"] :2 :NO :NO];
        c1 = [[cellData valueForKey:@"takerGets"]valueForKey:@"currency"];
        v2 = [cacl formatAmount:[[cellData valueForKey:@"takerPays"]valueForKey:@"value"] :2 :NO :NO];
        c2 = [[cellData valueForKey:@"takerPays"]valueForKey:@"currency"];
    }
    self.typeImageView.image = [UIImage imageNamed:type];
    NSString *account = [cellData valueForKey:@"account"]?[cellData valueForKey:@"account"]:@"---";
    if([type isEqualToString:@"Send"]){
        self.addressLabel.text = account;
        self.moneyLabel.attributedText = [@"" getAttrStringWithV1:[NSString stringWithFormat:@"-%@",v1] C1:c1 V2:nil C2:nil TYPE:@"send"];
        self.moneyLabel.font = [UIFont fontWithName:@"DIN Alternate Bold" size:16];
        self.moneyLabel.textAlignment = NSTextAlignmentRight;
    }else if ([type isEqualToString:@"Receive"]){
        self.addressLabel.text = account;
        self.moneyLabel.attributedText = [@"" getAttrStringWithV1:[NSString stringWithFormat:@"+%@",v1] C1:c1 V2:nil C2:nil TYPE:@"receive"];
        self.moneyLabel.font = [UIFont fontWithName:@"DIN Alternate Bold" size:16];
        self.moneyLabel.textAlignment = NSTextAlignmentRight;
    }else if ([type isEqualToString:@"OfferCreate"]){
        self.addressLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_create"];
        self.moneyLabel.textColor = [UIColor colorWithHex:0x3B6CA6];
        self.moneyLabel.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
        self.moneyLabel.font = [UIFont fontWithName:@"DIN Alternate Bold" size:16];
        self.moneyLabel.textAlignment = NSTextAlignmentRight;
    }else if ([type isEqualToString:@"OfferAffect"]){
        v1 = [cacl formatAmount:[[cellData valueForKey:@"takerGetsMatch"]valueForKey:@"value"] :2 :NO :NO];
        c1 = [[cellData valueForKey:@"takerGets"]valueForKey:@"currency"];
        v2 = [cacl formatAmount:[[cellData valueForKey:@"takerPaysMatch"]valueForKey:@"value"] :2 :NO :NO];
        c2 = [[cellData valueForKey:@"takerPays"]valueForKey:@"currency"];
        self.addressLabel.text = account;
        self.moneyLabel.textColor = [UIColor colorWithHex:0x3B6CA6];
        self.moneyLabel.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
        self.moneyLabel.font = [UIFont fontWithName:@"DIN Alternate Bold" size:16];
        self.moneyLabel.textAlignment = NSTextAlignmentRight;
    }else if ([type isEqualToString:@"OfferCancel"]){
        self.addressLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_cancel"];
        self.moneyLabel.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
        self.moneyLabel.font = [UIFont fontWithName:@"DIN Alternate Bold" size:16];
        self.moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    NSNumber *timestamp = [cellData valueForKey:@"time"];
    self.dateLabel.text = [@"" getDate:timestamp year:NO];
    
}

@end
