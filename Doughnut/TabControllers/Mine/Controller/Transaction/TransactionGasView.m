//
//  TPOSTransactionGasView.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/2/3.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//
#import "UIColor+Hex.h"
#import "TransactionGasView.h"
#import "TPOSMacro.h"
#import "TPOSLocalizedHelper.h"
#import "TPOSWeb3Handler.h"

@interface TransactionGasView()

@property (weak, nonatomic) IBOutlet UILabel *gasValieLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasUnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UISlider *gasSlider;

@property (nonatomic, assign) long long gasLimite;

//guojihua
@property (weak, nonatomic) IBOutlet UILabel *feeSettingLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastLabel;

@property (weak, nonatomic) IBOutlet UIButton *commonValue1;
@property (weak, nonatomic) IBOutlet UIButton *commonValue2;
@property (weak, nonatomic) IBOutlet UIButton *commonValue3;


@end

@implementation TransactionGasView

+ (TransactionGasView *)transactionViewWithMinFee:(CGFloat)min maxFee:(CGFloat)max recommentFee:(CGFloat)recomment {
    TransactionGasView *transactionGasView = [[NSBundle mainBundle] loadNibNamed:@"TransactionGasView" owner:nil options:nil].firstObject;
    transactionGasView.frame = CGRectMake(0, 0, kScreenWidth, 330);
    //transactionGasView.bottomOffset = 15;
    transactionGasView.layer.cornerRadius = 10;
    transactionGasView.layer.masksToBounds = YES;
    transactionGasView.gasSlider.minimumValue = min;
    transactionGasView.gasSlider.maximumValue = max;
    transactionGasView.gasSlider.value = recomment;
    transactionGasView.gasUnitLabel.text = @"SWT";
    transactionGasView.commonValue1.layer.cornerRadius = 10;
    transactionGasView.commonValue2.layer.cornerRadius = 10;
    transactionGasView.commonValue3.layer.cornerRadius = 10;
    transactionGasView.gasValieLabel.text = @"0.00001 SWTC";
    [transactionGasView.gasSlider setNeedsDisplay];
    [transactionGasView updateFee];
    return transactionGasView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _confirmButton.layer.cornerRadius = 4;
    _gasValieLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:18];
    [self changeLanguage];
}

- (void)changeLanguage {
    self.feeSettingLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"gas_setting"];
    self.slowLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"gas_slow"];
    self.fastLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"gas_fast"];
    [self.confirmButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"done"] forState:UIControlStateNormal];
}

- (IBAction)closeAction {
    [self hide];
}

- (IBAction)commonValueAction1:(id)sender {
    //_commonValue1.backgroundColor = [UIColor colorWithHex:0x32CD32];
    _gasSlider.value = 0.00001;
    [self updateFee];
}

- (IBAction)commonValueAction2:(id)sender {
    _gasSlider.value = 0.001;
    [self updateFee];
}

- (IBAction)commonValueAction3:(id)sender {
    _gasSlider.value = 0.01;
    [self updateFee];
}

- (IBAction)valueChange:(UISlider *)sender {
    [self updateFee];
}

- (void)updateFee {
    _gasValieLabel.text = [NSString stringWithFormat:@"%f SWTC",_gasSlider.value];
}

- (IBAction)confirmAction {
    _getGasPrice(_gasSlider.value);
    [self hide];
}

@end
