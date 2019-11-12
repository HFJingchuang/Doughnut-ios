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


@interface TPOSWalletManagerCell()

@property (weak, nonatomic) IBOutlet UIButton *backupView;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLbael;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletType;
@property (weak, nonatomic) IBOutlet UILabel *createTime;


@property (nonatomic, strong) WalletManage *walletManage;
@property (nonatomic, strong) CaclUtil *caclUtil;

@end

@implementation TPOSWalletManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _backupView.layer.cornerRadius = 10;
    _walletType.layer.cornerRadius = 4;
    _walletType.layer.masksToBounds = YES;
    
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
    self.walletNameLbael.text = walletModel.walletName;
    self.addressLabel.text = walletModel.address;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [_QRCodeImage addGestureRecognizer:tapGesture];
    _QRCodeImage.userInteractionEnabled = YES;
    _backupView.hidden = walletModel.isBackup;
    _createTime.text = [NSString stringWithFormat:@"%@:%@", [[TPOSLocalizedHelper standardHelper]stringWithKey:@"export_time"],walletModel.createTime?walletModel.createTime:@"---"];
    _walletManage = [[WalletManage alloc]init];
    _caclUtil = [[CaclUtil alloc]init];
    [_walletManage createRemote];
    [_walletManage requestBalanceByAddress:@"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceListAction:) name:@"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6" object:nil];
}

-(void) getBalanceListAction:(NSNotification *) notification {
    NSMutableArray<NSMutableDictionary *> *data = notification.object;
    [_walletManage getAllTokenPrice:^(NSArray *priceData) {
        // 钱包总价值
        NSString *values = @"0.00";
        // 钱包折换总SWT
        NSString *number = @"0.00";
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
                values = [_caclUtil add:value :values];
            }
            number = [_caclUtil formatAmount:[_caclUtil div:values :swtPrice :2] :2:YES:NO];

            values = [_caclUtil formatAmount:values :2:YES:NO];
        }else{
            values = @"---";
            number = @"---";
        }
        NSArray *result = [NSArray arrayWithObjects:number,values, nil];
        [self performSelectorOnMainThread:@selector(updateLabels:) withObject:result waitUntilDone:YES];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

-(void)updateLabels:(NSArray *)data{
    _walletBalanceLabel.text = data[0];
    _balanceCNYLabel.text = [NSString stringWithFormat:@"≈￥%@",data[1]];
}

@end
