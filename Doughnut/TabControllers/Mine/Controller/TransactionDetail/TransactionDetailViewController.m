//
//  TransactionDetailViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/28.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "UIColor+Hex.h"
#import <Toast/Toast.h>;//
#import "NSString+TPOS.h"
#import "CaclUtil.h"
#import "XHPageControl.h"
#import "TransactionNodeView.h"

@interface TransactionDetailViewController ()<UIScrollViewDelegate ,XHPageControlDelegate>
@property (weak, nonatomic) IBOutlet UIView *transactionInfoView;
@property (weak, nonatomic) IBOutlet UIScrollView *infoScrollView;
@property (weak, nonatomic) IBOutlet UILabel *currentHashLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentHash;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel1;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel2;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel3;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel4;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel5;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel6;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel7;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel8;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel9;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel10;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel1;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel2;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel3;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel4;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel5;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel6;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel7;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel8;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel9;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel10;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label7label4Constraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label8label4Constraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label9label4Constraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label10label4Constraints;

@property(nonatomic,strong) XHPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIScrollView *effectNodesScrollView;

@property (nonatomic, strong) CaclUtil *cacl;

@end

@implementation TransactionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
//    self.bottomConstraints.constant = kIphoneX ? 105 : 90;
    _cacl = [[CaclUtil alloc]init];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_detail"];
    self.transactionInfoView.layer.shadowColor = (__bridge CGColorRef _Nullable)([UIColor colorWithHex:0x051B2A alpha:50]);
    self.transactionInfoView.layer.shadowOffset = CGSizeMake(0,5);
    self.transactionInfoView.layer.shadowOpacity = 1;
    self.transactionInfoView.layer.shadowRadius = 15;
    UIView *back = [[UIView alloc]initWithFrame:CGRectMake(_infoScrollView.frame.origin.x ,_infoScrollView.frame.origin.y - 3, _infoScrollView.frame.size.width,50)];
    back.backgroundColor = [UIColor colorWithHex:0x3B6CA6];
    back.layer.cornerRadius = 6;
    [self.view addSubview:back];
    [self.view sendSubviewToBack:back];
    self.infoScrollView.scrollEnabled = YES;
    self.infoScrollView.contentSize = CGSizeMake(self.transactionInfoView.frame.size.width,self.transactionInfoView.frame.size.height);
    self.infoScrollView.bounces = NO;
    self.navigationController.navigationBarHidden = NO;
    [self pageControl];
    _pageControl.frame=CGRectMake(10,[UIScreen mainScreen].bounds.size.height - 10, _effectNodesScrollView.frame.size.width, 30);
    _pageControl.backgroundColor = [UIColor blackColor];
    _pageControl.numberOfPages = 7;
    _pageControl.currentPage = 0;
    [self.view addSubview:_pageControl];
    [self.view bringSubviewToFront:_pageControl];
}

- (void)changeLanguage {
    _currentHashLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"current_trans_hash"];
    self.itemLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_type"];
    self.itemLabel2.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_add"];
    self.itemLabel7.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_gas"];
    self.itemLabel8.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_time"];
    self.itemLabel9.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_result"];
    self.itemLabel10.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_memo"];
}

-(void)loadData {
     __weak typeof(self) weakSelf = self;
    _currentHash.text = _currentTransactionHash;
    [[WalletManage shareInstance] getTransactionDetail:_currentTransactionHash :^(NSDictionary *response) {
        NSString *type = [response valueForKey:@"type"];
        if ([type isEqualToString:@"Payment"]){
            weakSelf.dataLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"payment"];
            weakSelf.dataLabel2.text = [response valueForKey:@"account"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"account"]]){
                weakSelf.dataLabel2.textColor = [UIColor colorWithHex:0xFFA500];
            }
            weakSelf.itemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_amount"];
            weakSelf.dataLabel3.attributedText = [@"" getAttrStringWithV1:[[response valueForKey:@"amount"] valueForKey:@"value"] C1:[[response valueForKey:@"amount"] valueForKey:@"currency"] V2:nil C2:nil TYPE:@""];
            weakSelf.dataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
            weakSelf.dataLabel3.textAlignment = NSTextAlignmentRight;
            weakSelf.itemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_to"];
            weakSelf.dataLabel4.text = [response valueForKey:@"dest"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"dest"]]){
                weakSelf.dataLabel4.textColor = [UIColor colorWithHex:0xFFA500];
            }
            [self hideLabels];
        }else if([type isEqualToString:@"OfferCreate"]){
            NSNumber *flag = [response valueForKey:@"flag"];
            if ([flag longValue] == 2 ){
                weakSelf.dataLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_create"];
                [weakSelf hideLabels];
            }else {
                if (![[response allKeys]containsObject:@"matchFlag"]){
                  weakSelf.dataLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_affect"];
                }
                NSString *v1 = @"";
                NSString *c1 = @"";
                NSString *v2 = @"";
                NSString *c2 = @"";
                if ([[response allKeys]containsObject:@"matchGets"]&&[[response allKeys]containsObject:@"matchPays"]){
                    weakSelf.itemLabel5.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"turnover_acount"];
                    weakSelf.itemLabel6.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"turnover_price"];
                    v1 = [_cacl formatAmount:[[response valueForKey:@"matchGets"]valueForKey:@"value"] :2 :NO :NO];
                    c1 = [[response valueForKey:@"matchGets"]valueForKey:@"currency"];
                    v2 = [_cacl formatAmount:[[response valueForKey:@"matchPays"]valueForKey:@"value"] :2 :NO :NO];
                    c2 = [[response valueForKey:@"matchPays"]valueForKey:@"currency"];
                    weakSelf.dataLabel5.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
                    weakSelf.dataLabel5.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                    weakSelf.dataLabel5.textAlignment = NSTextAlignmentRight;
                    NSString *price = [weakSelf getPrice:response match:YES][0];
                    NSString *cny = [weakSelf getPrice:response match:YES][1];
                    weakSelf.dataLabel6.attributedText = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
                    weakSelf.dataLabel6.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                    weakSelf.dataLabel6.textAlignment = NSTextAlignmentRight;
                    
                }
            }
            weakSelf.dataLabel2.text = [response valueForKey:@"account"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"account"]]){
                weakSelf.dataLabel2.textColor = [UIColor colorWithHex:0xFFA500];
            }
            NSString *v1 = @"";
            NSString *c1 = @"";
            NSString *v2 = @"";
            NSString *c2 = @"";
            v1 = [_cacl formatAmount:[[response valueForKey:@"takerGets"]valueForKey:@"value"] :2 :NO :NO];
            c1 = [[response valueForKey:@"takerGets"]valueForKey:@"currency"];
            v2 = [_cacl formatAmount:[[response valueForKey:@"takerPays"]valueForKey:@"value"] :2 :NO :NO];
            c2 = [[response valueForKey:@"takerPays"]valueForKey:@"currency"];
            weakSelf.itemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_amount"];
            weakSelf.dataLabel3.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
            weakSelf.dataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
            weakSelf.dataLabel3.textAlignment = NSTextAlignmentRight;
            weakSelf.itemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_price"];
            NSString *price = [weakSelf getPrice:response match:NO][0];
            NSString *cny = [weakSelf getPrice:response match:NO][1];
            weakSelf.dataLabel4.attributedText = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
            weakSelf.dataLabel4.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
            weakSelf.dataLabel4.textAlignment = NSTextAlignmentRight;
        }else if([type isEqualToString:@"OfferCancel"]){
            weakSelf.dataLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_cancel"];
            weakSelf.dataLabel2.text = [response valueForKey:@"account"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"account"]]){
                weakSelf.dataLabel2.textColor = [UIColor colorWithHex:0xFFA500];
            }
            NSString *v1 = @"";
            NSString *c1 = @"";
            NSString *v2 = @"";
            NSString *c2 = @"";
            v1 = [_cacl formatAmount:[[response valueForKey:@"takerGets"]valueForKey:@"value"] :2 :NO :NO];
            c1 = [[response valueForKey:@"takerGets"]valueForKey:@"currency"];
            v2 = [_cacl formatAmount:[[response valueForKey:@"takerPays"]valueForKey:@"value"] :2 :NO :NO];
            c2 = [[response valueForKey:@"takerPays"]valueForKey:@"currency"];
            weakSelf.itemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_amount"];
            weakSelf.dataLabel3.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
            weakSelf.dataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
            weakSelf.dataLabel3.textAlignment = NSTextAlignmentRight;
            weakSelf.itemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_price"];
            NSString *price = [weakSelf getPrice:response match:NO][0];
            NSString *cny = [weakSelf getPrice:response match:NO][1];
            weakSelf.dataLabel4.attributedText = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
            weakSelf.dataLabel4.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
            weakSelf.dataLabel4.textAlignment = NSTextAlignmentRight;
            [weakSelf hideLabels];
        }
        NSNumber *fee = [response valueForKey:@"fee"];
        weakSelf.dataLabel7.attributedText = [@"" getAttrStringWithV1:[NSString stringWithFormat:@"%f",[fee doubleValue]] C1:@"SWTC" V2:nil C2:nil TYPE:@""];
        weakSelf.dataLabel7.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        weakSelf.dataLabel7.textAlignment = NSTextAlignmentRight;
        weakSelf.dataLabel8.text = [@"" getDate:[response valueForKey:@"time"] year:YES];
        if([[response valueForKey:@"succ"] isEqualToString:@"tesSUCCESS"]) {
            weakSelf.dataLabel9.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"SUCCESS"];;
            weakSelf.dataLabel9.textColor = [UIColor colorWithHex:0x27B498];
        }
        if ([[response allKeys]containsObject:@"memos"]) {
            NSString *memo = [NSString stringWithFormat:@"%@",[[[response valueForKey:@"memos"][0]valueForKey:@"Memo"] valueForKey:@"MemoData"]];
            weakSelf.dataLabel10.text = [weakSelf stringFromHexString:memo];
        }
        [weakSelf labelToFit];
//        if([[response allKeys]containsObject:@"affectedNodes"]){
        weakSelf.effectNodesScrollView.contentSize=CGSizeMake(_effectNodesScrollView.bounds.size.width*7, 100);
            weakSelf.effectNodesScrollView.delegate=self;
            weakSelf.effectNodesScrollView.pagingEnabled = YES;
            for (int i = 0; i < 7; i++) {
                TransactionNodeView *imgV= [[[NSBundle mainBundle] loadNibNamed:@"TransactionNodeView" owner:self options:nil] firstObject];
                imgV.frame = CGRectMake(weakSelf.effectNodesScrollView.bounds.size.width * i + 5, 0, weakSelf.effectNodesScrollView.bounds.size.width - 10, weakSelf.effectNodesScrollView.bounds.size.height);
                imgV.layer.cornerRadius = 6;
                imgV.layer.masksToBounds = YES;
                imgV.contentTitleLabel.text = @"23232";
                imgV.contentDataLabel1.text = @"2323";
                [weakSelf.effectNodesScrollView addSubview:imgV];
            }
//            [weakSelf pageControl];
//            _pageControl.frame=CGRectMake(10,[UIScreen mainScreen].bounds.size.height - 10, _effectNodesScrollView.frame.size.width, 30);
//            _pageControl.backgroundColor = [UIColor blackColor];
//            _pageControl.numberOfPages = 7;
//            _pageControl.currentPage = 0;
//            CGRect rect = _pageControl.frame;
//            [self.view addSubview:_pageControl];
//            [weakSelf.view bringSubviewToFront:_pageControl];
//        }else {
//            weakSelf.effectNodesScrollView.hidden = YES;
//            weakSelf.bottomConstraints.constant = 100;
//        }
    } failure:^(NSError *error) {
        [weakSelf.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"req_exchange_list_fail"]];
    }];
}

-(void) hideLabels{
    __weak typeof(self) weakSelf = self;
    weakSelf.itemLabel5.hidden = YES;
    weakSelf.itemLabel6.hidden = YES;
    weakSelf.dataLabel5.hidden = YES;
    weakSelf.dataLabel6.hidden = YES;
    weakSelf.label7label4Constraints.constant = 10;
    weakSelf.label8label4Constraints.constant = 40;
    weakSelf.label9label4Constraints.constant = 70;
    weakSelf.label10label4Constraints.constant = 100;
}

- (BOOL) isCurrentAddress:(NSString *)address {
    return [address isEqualToString:_currentWalletAddress];
}

- (NSArray *) getPrice: (NSDictionary *)data match:(BOOL)match{
    NSString *priceC = @"";
    NSString *cny = @"";
    if(match){
        if([[[data valueForKey:@"matchPays"] valueForKey:@"currency"]isEqualToString:@"CNY"]||[[[data valueForKey:@"matchPays"] valueForKey:@"currency"]isEqualToString:@"SWTC"]){
            priceC = [_cacl formatAmount:[_cacl div:[[data valueForKey:@"matchPays"]valueForKey:@"value"] :[[data valueForKey:@"matchGets"]valueForKey:@"value"] ] :6 :NO :NO];
            cny = [[data valueForKey:@"matchPays"]valueForKey:@"currency"];
            
        }else {
            priceC = [_cacl formatAmount:[_cacl div:[[data valueForKey:@"matchGets"]valueForKey:@"value"] :[[data valueForKey:@"matchPays"]valueForKey:@"value"] ] :6 :NO :NO];
            cny = [[data valueForKey:@"matchGets"]valueForKey:@"currency"];
        }
    }else{
        if([[[data valueForKey:@"takerPays"] valueForKey:@"currency"]isEqualToString:@"CNY"]||[[[data valueForKey:@"matchPays"] valueForKey:@"currency"]isEqualToString:@"SWTC"]){
            priceC = [_cacl formatAmount:[_cacl div:[[data valueForKey:@"takerPays"]valueForKey:@"value"] :[[data valueForKey:@"takerGets"]valueForKey:@"value"] ] :6 :NO :NO];
            cny = [[data valueForKey:@"takerPays"]valueForKey:@"currency"];
        }else {
            priceC = [_cacl formatAmount:[_cacl div:[[data valueForKey:@"takerGets"]valueForKey:@"value"] :[[data valueForKey:@"takerPays"]valueForKey:@"value"] ] :6 :NO :NO];
            cny = [[data valueForKey:@"takerGets"]valueForKey:@"currency"];
        }
    }
    NSArray *arr = @[priceC, cny];
    return arr;
}

-(void)labelToFit{
    [self.itemLabel1 sizeToFit];
    [self.itemLabel2 sizeToFit];
    [self.itemLabel3 sizeToFit];
    [self.itemLabel4 sizeToFit];
    [self.itemLabel5 sizeToFit];
    [self.itemLabel6 sizeToFit];
    [self.itemLabel7 sizeToFit];
    [self.itemLabel8 sizeToFit];
    [self.itemLabel9 sizeToFit];
    [self.itemLabel10 sizeToFit];
}

- (NSString *)stringFromHexString:(NSString *)hexString {
    NSData *data = [self dataFromHexString:hexString];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString *str = @"";
    str = [[NSString alloc]initWithData:data encoding:enc];
    return str;
}

- (NSData *)dataFromHexString:(NSString *)str{
    const char *chars = [str UTF8String];
    int i = 0, len = str.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

- (XHPageControl *)pageControl {
    _pageControl = [[XHPageControl alloc] init];
    _pageControl.frame=CGRectMake(0, _effectNodesScrollView.bounds.size.height + 50,[UIScreen mainScreen].bounds.size.width, 30);
    _pageControl.delegate=self;
    _pageControl.currentColor = [UIColor colorWithHex:0x3B6CA6];
    _pageControl.currentMultiple = 5;
    return _pageControl;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentPage = targetContentOffset->x / _effectNodesScrollView.bounds.size.width;
    self.pageControl.currentPage = currentPage;
}

-(void)xh_PageControlClick:(XHPageControl*)pageControl index:(NSInteger)clickIndex{
    CGPoint position = CGPointMake(_effectNodesScrollView.bounds.size.width * clickIndex, 0);
    [_effectNodesScrollView setContentOffset:position animated:YES];
}

@end
