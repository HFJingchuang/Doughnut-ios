//
//  TPOSWalletManagerCell.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/8.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//
#import "TPOSWalletManagerViewController.h"
#import "TPOSWalletManagerCell.h"
#import "UIColor+Hex.h"
#import "TPOSWalletModel.h"
#import "TPOSLocalizedHelper.h"
#import "WalletManage.h"
#import "TPOSMacro.h"
#import "CaclUtil.h"
#import "NSString+TPOS.h"
#import "QRCodeViewController.h"
#import "TPOSContext.h"

@interface TPOSWalletManagerCell()

@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLbael;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentFlag;
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *balanceLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cnyLoading;

@property (nonatomic, strong) CaclUtil *caclUtil;

@property (nonatomic, assign) NSString *values;
@property (nonatomic, assign) NSString *number;

@end

@implementation TPOSWalletManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _currentFlag.layer.cornerRadius = 6;
    _currentFlag.layer.masksToBounds = YES;
    _currentFlag.hidden = YES;
    _currentFlag.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"current"];
    [self.balanceLoading startAnimating];
    [self.cnyLoading startAnimating];
    self.balanceLoading.hidesWhenStopped = YES;
    self.cnyLoading.hidesWhenStopped = YES;
}

- (UIViewController *)viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)clickImage {
    QRCodeViewController *vc = [[QRCodeViewController alloc]init];
    vc.walletName = self.walletNameLbael.text;
    vc.walletAddr = self.addressLabel.text;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (void)updateWithModel:(TPOSWalletModel *)walletModel {
    if ([walletModel.walletId isEqualToString:[TPOSContext shareInstance].currentWallet.walletId]){
        _currentFlag.hidden = NO;
    }
    self.walletNameLbael.text = walletModel.walletName;
    self.addressLabel.text = walletModel.address;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [_QRCodeImage addGestureRecognizer:tapGesture];
    _QRCodeImage.userInteractionEnabled = YES;
    _createTime.text = [NSString stringWithFormat:@"%@:%@", [[TPOSLocalizedHelper standardHelper]stringWithKey:@"export_time"],walletModel.createTime?walletModel.createTime:@"---"];
    _caclUtil = [[CaclUtil alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCellBalanceListAction:) name:walletModel.address object:nil];
    [[WalletManage shareWalletManage] requestBalanceByAddress:walletModel.address current:NO];
}

-(void) getCellBalanceListAction:(NSNotification *) notification {
    NSMutableArray<NSMutableDictionary *> *data = notification.object;
    //钱包总价值
    _values = @"0.00";
    // 钱包折换总SWT
    _number = @"0.00";
    if (data && data.count > 0){
        [[WalletManage shareWalletManage] getAllTokenPrice:^(NSArray *priceData) {
            NSString *swtPrice = @"0.00";
            if(priceData.count != 0){
                NSArray<NSString *> *arr = [priceData valueForKey:@"SWT-CNY"];
                swtPrice = arr[1];
                for (int i=0;i< data.count;i++){
                    NSMutableDictionary *cell = data[i];
                    NSString *balance = [cell valueForKey:@"balance"];
                    if([balance tb_isEmpty]){
                        balance = @"0";
                    }
                    NSString *currency = [cell valueForKey:@"currency"];
                    NSString *freeze = [cell valueForKey:@"limit"];
                    if([freeze tb_isEmpty]){
                        freeze = @"0";
                    }
                    NSString *sum = [_caclUtil add:balance :freeze];
                    NSString *price = @"0";
                    if ([currency isEqualToString:CURRENCY_CNY]) {
                        price = @"1";
                    } else if([currency isEqualToString:CURRENCY_SWTC]) {
                        price = swtPrice;
                    }else{
                        NSString *currency_cny = [NSString stringWithFormat:@"%@%@",currency,@"-CNY"];
                        NSArray<NSString *> *currencyLst = [priceData valueForKey:currency_cny];
                        if (currencyLst != nil) {
                            price = currencyLst[1]?currencyLst[1]:@"0";
                        }
                    }
                    NSString *value = [_caclUtil mul:sum :price];
                    _values = [_caclUtil add:value :_values];
                }
                _number = [_caclUtil formatAmount:[_caclUtil div:_values :swtPrice :2] :2:YES:NO];
                _values = [_caclUtil formatAmount:_values :2:YES:NO];
            }
            [self performSelectorOnMainThread:@selector(updateLabels) withObject:nil waitUntilDone:YES];
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }else {
        [self updateLabels];
    }
}

-(void)updateLabels{
    _walletBalanceLabel.text = _number;
    _balanceCNYLabel.text = [NSString stringWithFormat:@"≈￥%@",_values];
    [self.balanceLoading stopAnimating];
    [self.cnyLoading stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
