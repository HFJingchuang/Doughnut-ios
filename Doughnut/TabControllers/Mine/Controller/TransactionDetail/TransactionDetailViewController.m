//
//  TransactionDetailViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/28.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "UIColor+Hex.h"
#import <Toast/Toast.h>
#import "NSString+TPOS.h"
#import "CaclUtil.h"
#import "XHPageControl.h"
#import "TransactionNodeView.h"

@interface TransactionDetailViewController ()<UIScrollViewDelegate ,XHPageControlDelegate>
@property (weak, nonatomic) IBOutlet UIView *transactionInfoView;
@property (weak, nonatomic) IBOutlet UIScrollView *infoScrollView;
@property (weak, nonatomic) IBOutlet UILabel *currentHashLabel;
@property (weak, nonatomic) IBOutlet UIButton *hashCopyBtn;
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
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"transaction_details"];
    self.transactionInfoView.layer.shadowColor = (__bridge CGColorRef _Nullable)([UIColor colorWithHex:0x051B2A alpha:50]);
    self.transactionInfoView.layer.cornerRadius = 6;
    self.transactionInfoView.layer.masksToBounds = YES;
    self.transactionInfoView.layer.shadowOffset = CGSizeMake(0,5);
    self.transactionInfoView.layer.shadowOpacity = 1;
    self.transactionInfoView.layer.shadowRadius = 15;
    UIView *back = [[UIView alloc]initWithFrame:CGRectMake(_infoScrollView.frame.origin.x ,_infoScrollView.frame.origin.y - 2, ([UIScreen mainScreen].bounds.size.width) - 19,50)];
    back.backgroundColor = [UIColor colorWithHex:0x3B6CA6];
    back.layer.cornerRadius = 6;
    [self.view addSubview:back];
    [self.view sendSubviewToBack:back];
    self.infoScrollView.scrollEnabled = YES;
    self.infoScrollView.contentSize = CGSizeMake(self.transactionInfoView.frame.size.width,self.transactionInfoView.frame.size.height);
    self.infoScrollView.bounces = NO;
    self.navigationController.navigationBarHidden = NO;
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCopyBtn)];
    [_hashCopyBtn addGestureRecognizer:tapGesture2];
    _hashCopyBtn.userInteractionEnabled = YES;
}

-(void)clickCopyBtn{
    if (_currentHash.text &&_currentHash.text.length >0){
        [[UIPasteboard generalPasteboard] setString:_currentHash.text];
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"copy_to_board"]];
    }
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
    [[WalletManage shareWalletManage] getTransactionDetail:_currentTransactionHash :^(NSDictionary *response) {
        NSString *type = [response valueForKey:@"type"];
        if ([type isEqualToString:@"Payment"]){
            weakSelf.dataLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"payment"];
            weakSelf.dataLabel2.text = [response valueForKey:@"account"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"account"]]){
                weakSelf.dataLabel2.textColor = [UIColor colorWithHex:0xFFA500];
            }
            [weakSelf.dataLabel2 addLongPressCopy];
            weakSelf.itemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_amount"];
            weakSelf.dataLabel3.attributedText = [@"" getAttrStringWithV1:[[response valueForKey:@"amount"] valueForKey:@"value"] C1:[[response valueForKey:@"amount"] valueForKey:@"currency"] V2:nil C2:nil TYPE:@""];
            weakSelf.dataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
            weakSelf.dataLabel3.textAlignment = NSTextAlignmentRight;
            weakSelf.itemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_to"];
            weakSelf.dataLabel4.text = [response valueForKey:@"dest"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"dest"]]){
                weakSelf.dataLabel4.textColor = [UIColor colorWithHex:0xFFA500];
            }
            [weakSelf.dataLabel4 addLongPressCopy];
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
                    NSString *price = [weakSelf getPriceWithV1:[[response valueForKey:@"matchGets"]valueForKey:@"value"] V2:[[response valueForKey:@"matchPays"]valueForKey:@"value"] C1:c1 C2:c2 ][0];
                    NSString *cny = [weakSelf getPriceWithV1:[[response valueForKey:@"matchGets"]valueForKey:@"value"] V2:[[response valueForKey:@"matchPays"]valueForKey:@"value"] C1:c1 C2:c2 ][1];
                    weakSelf.dataLabel6.attributedText = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
                    weakSelf.dataLabel6.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                    weakSelf.dataLabel6.textAlignment = NSTextAlignmentRight;
                    
                }
            }
            weakSelf.dataLabel2.text = [response valueForKey:@"account"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"account"]]){
                weakSelf.dataLabel2.textColor = [UIColor colorWithHex:0xFFA500];
            }
            [weakSelf.dataLabel2 addLongPressCopy];
            weakSelf.itemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_amount"];
            weakSelf.itemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_price"];
            if ([[response allKeys]containsObject:@"takerGets"]&&[[response allKeys]containsObject:@"takerPays"]){
                NSString *v1 = @"";
                NSString *c1 = @"";
                NSString *v2 = @"";
                NSString *c2 = @"";
                v1 = [_cacl formatAmount:[[response valueForKey:@"takerGets"]valueForKey:@"value"] :2 :NO :NO];
                c1 = [[response valueForKey:@"takerGets"]valueForKey:@"currency"];
                v2 = [_cacl formatAmount:[[response valueForKey:@"takerPays"]valueForKey:@"value"] :2 :NO :NO];
                c2 = [[response valueForKey:@"takerPays"]valueForKey:@"currency"];
                
                weakSelf.dataLabel3.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
                weakSelf.dataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                weakSelf.dataLabel3.textAlignment = NSTextAlignmentRight;
               
                NSString *price = [weakSelf getPriceWithV1:[[response valueForKey:@"takerGets"]valueForKey:@"value"] V2:[[response valueForKey:@"takerPays"]valueForKey:@"value"] C1:c1 C2:c2 ][0];
                NSString *cny = [weakSelf getPriceWithV1:[[response valueForKey:@"takerGets"]valueForKey:@"value"] V2:[[response valueForKey:@"takerPays"]valueForKey:@"value"] C1:c1 C2:c2 ][1];
                weakSelf.dataLabel4.attributedText = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
                weakSelf.dataLabel4.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                weakSelf.dataLabel4.textAlignment = NSTextAlignmentRight;
            }else {
                weakSelf.dataLabel3.text = @"---";
                weakSelf.dataLabel4.text = @"---";
            }
        }else if([type isEqualToString:@"OfferCancel"]){
            weakSelf.dataLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_cancel"];
            weakSelf.dataLabel2.text = [response valueForKey:@"account"];
            if([weakSelf isCurrentAddress:[response valueForKey:@"account"]]){
                weakSelf.dataLabel2.textColor = [UIColor colorWithHex:0xFFA500];
            }
            [weakSelf.dataLabel2 addLongPressCopy];
            weakSelf.itemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_amount"];
            weakSelf.itemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"offer_price"];
            if ([[response allKeys]containsObject:@"takerGets"]&&[[response allKeys]containsObject:@"takerPays"]){
                NSString *v1 = @"";
                NSString *c1 = @"";
                NSString *v2 = @"";
                NSString *c2 = @"";
                v1 = [_cacl formatAmount:[[response valueForKey:@"takerGets"]valueForKey:@"value"] :2 :NO :NO];
                c1 = [[response valueForKey:@"takerGets"]valueForKey:@"currency"];
                v2 = [_cacl formatAmount:[[response valueForKey:@"takerPays"]valueForKey:@"value"] :2 :NO :NO];
                c2 = [[response valueForKey:@"takerPays"]valueForKey:@"currency"];
                weakSelf.dataLabel3.attributedText = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
                weakSelf.dataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                weakSelf.dataLabel3.textAlignment = NSTextAlignmentRight;
                NSString *price = [weakSelf getPriceWithV1:[[response valueForKey:@"takerGets"]valueForKey:@"value"] V2:[[response valueForKey:@"takerPays"]valueForKey:@"value"] C1:c1 C2:c2 ][0];
                NSString *cny = [weakSelf getPriceWithV1:[[response valueForKey:@"takerGets"]valueForKey:@"value"] V2:[[response valueForKey:@"takerPays"]valueForKey:@"value"] C1:c1 C2:c2 ][1];
                weakSelf.dataLabel4.attributedText = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
                weakSelf.dataLabel4.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
                weakSelf.dataLabel4.textAlignment = NSTextAlignmentRight;
            }else {
                weakSelf.dataLabel3.text = @"---";
                weakSelf.dataLabel4.text = @"---";
            }
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
        if([[response allKeys]containsObject:@"affectedNodes"]) {
            [weakSelf addAffectNodes:response];
        }else {
            weakSelf.effectNodesScrollView.hidden = YES;
            weakSelf.bottomConstraints.constant = 100;
        }
    } failure:^(NSError *error) {
        [weakSelf.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"req_exchange_list_fail"]];
    }];
}

- (void)addAffectNodes:(NSDictionary *)response {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *arr = [response valueForKey:@"affectedNodes"];
    weakSelf.effectNodesScrollView.contentSize = CGSizeMake(_effectNodesScrollView.bounds.size.width * arr.count, 100);
    weakSelf.effectNodesScrollView.delegate = self;
    weakSelf.effectNodesScrollView.pagingEnabled = YES;
    NSNumber *pages = [NSNumber numberWithInt:0];
    if (arr.count == 0){
        pages = [NSNumber numberWithInt:1];
        TransactionNodeView *imgV = [[[NSBundle mainBundle] loadNibNamed:@"TransactionNodeView" owner:self options:nil] firstObject];
        imgV.frame = CGRectMake(5, 0, weakSelf.effectNodesScrollView.bounds.size.width - 10, weakSelf.effectNodesScrollView.bounds.size.height);
        imgV.layer.cornerRadius = 6;
        imgV.layer.masksToBounds = YES;
        imgV.contentTitleLabel.text = [NSString stringWithFormat:@"%@   %@", [weakSelf getSeq:1], [[TPOSLocalizedHelper standardHelper]stringWithKey:@"transaction_detail"]];
        imgV.contentItemLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"index"];
        imgV.contentDataLabel1.text = [weakSelf getSeq:1];
        imgV.contentItemLabel2.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"side"];
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage imageNamed:[response valueForKey:@"type"]];
        imageAttachment.bounds = CGRectMake(-5, -4, 20, 20);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        NSMutableAttributedString *completeText= [[NSMutableAttributedString alloc] initWithString:@""];
        [completeText appendAttributedString:attachmentString];
        [completeText appendAttributedString:weakSelf.dataLabel1.attributedText];
        imgV.contentDataLabel2.attributedText = completeText;
        imgV.contentItemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"content"];
        imgV.contentDataLabel3.attributedText = weakSelf.dataLabel3.attributedText;
        imgV.contentItemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"price"];
        imgV.contentDataLabel4.attributedText = weakSelf.dataLabel4.attributedText;
        [weakSelf.effectNodesScrollView addSubview:imgV];
        [imgV.contentDataLabel2 sizeToFit];
    }else{
        pages = [NSNumber numberWithInteger:arr.count];
        for (int i = 0; i < arr.count; i++) {
            NSDictionary *pre = [arr[i] valueForKey:@"previous"];
            NSDictionary *fin = [arr[i] valueForKey:@"final"];
            TransactionNodeView *imgV = [[[NSBundle mainBundle] loadNibNamed:@"TransactionNodeView" owner:self options:nil] firstObject];
            imgV.frame = CGRectMake(weakSelf.effectNodesScrollView.bounds.size.width * i + 5, 0, weakSelf.effectNodesScrollView.bounds.size.width - 10, weakSelf.effectNodesScrollView.bounds.size.height);
            imgV.layer.cornerRadius = 6;
            imgV.layer.masksToBounds = YES;
            imgV.contentTitleLabel.text = [NSString stringWithFormat:@"%@   %@", [weakSelf getSeq:i + 1], [[TPOSLocalizedHelper standardHelper]stringWithKey:@"transaction_detail"]];
            imgV.contentItemLabel1.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"index"];
            imgV.contentDataLabel1.text = [weakSelf getSeq:i + 1];
            NSString *v1 = @"";
            NSString *c1 = @"";
            NSString *v2 = @"";
            NSString *c2 = @"";
            v1 = [_cacl sub:[[pre valueForKey:@"takerPays"]valueForKey:@"value"] :[[fin valueForKey:@"takerPays"]valueForKey:@"value"] :2];
            c1 = [[pre valueForKey:@"takerPays"]valueForKey:@"currency"];
            v2 = [_cacl sub:[[pre valueForKey:@"takerGets"]valueForKey:@"value"] :[[fin valueForKey:@"takerGets"]valueForKey:@"value"] :2];
            c2 = [[pre valueForKey:@"takerGets"]valueForKey:@"currency"];
            NSArray *priceArr = [weakSelf getPriceWithV1:[_cacl sub:[[pre valueForKey:@"takerPays"]valueForKey:@"value"] :[[fin valueForKey:@"takerPays"]valueForKey:@"value"]] V2:[_cacl sub:[[pre valueForKey:@"takerGets"]valueForKey:@"value"] :[[fin valueForKey:@"takerGets"]valueForKey:@"value"]] C1:c1 C2:c2 ];
            NSAttributedString *content = [@"" getAttrStringWithV1:v1 C1:c1 V2:v2 C2:c2 TYPE:@"offer"];
            NSString *price = priceArr[0];
            NSString *cny = priceArr[1];
            NSAttributedString *priceAttr = [@"" getAttrStringWithV1:price C1:cny V2:nil C2:nil TYPE:@""];
            if ([[arr[i] valueForKey:@"account"] isEqualToString:_currentWalletAddress]){
                imgV.contentItemLabel2.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"side"];
                NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
                imageAttachment.image = [UIImage imageNamed:[response valueForKey:@"type"]];
                imageAttachment.bounds = CGRectMake(-5, -4, 20, 20);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                NSMutableAttributedString *completeText= [[NSMutableAttributedString alloc] initWithString:@""];
                [completeText appendAttributedString:attachmentString];
                [completeText appendAttributedString:weakSelf.dataLabel1.attributedText];
                imgV.contentDataLabel2.attributedText = completeText;
                imgV.contentItemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"content"];
                imgV.contentDataLabel3.attributedText = content;
                imgV.contentDataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
                imgV.contentDataLabel3.textAlignment = NSTextAlignmentRight;
                imgV.contentItemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"price"];
                imgV.contentDataLabel4.attributedText = priceAttr;
                imgV.contentDataLabel4.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
                imgV.contentDataLabel4.textAlignment = NSTextAlignmentRight;
            }else {
                imgV.contentItemLabel2.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"content"];
                imgV.contentDataLabel2.attributedText = content;
                imgV.contentDataLabel2.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
                imgV.contentDataLabel2.textAlignment = NSTextAlignmentRight;
                imgV.contentItemLabel3.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"price"];
                imgV.contentDataLabel3.attributedText = priceAttr;
                imgV.contentDataLabel3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
                imgV.contentDataLabel3.textAlignment = NSTextAlignmentRight;
                imgV.contentItemLabel4.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"trans_to"];
                imgV.contentDataLabel4.text = [arr[i] valueForKey:@"account"];
                imgV.contentDataLabel4.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
                [imgV.contentDataLabel4 addLongPressCopy];
            }
            [weakSelf.effectNodesScrollView addSubview:imgV];
        }
    }
    [weakSelf performSelectorOnMainThread:@selector(setPageControl:) withObject:pages waitUntilDone:nil];
}

-(NSString *)getSeq:(int)index{
    NSString *seq = [NSString stringWithFormat:@"%d",index];
    if (seq.length == 1 && seq != 0){
        seq = [NSString stringWithFormat:@"%@%@",@"0",seq ];
    }
    return seq;
}

-(void)setPageControl:(NSNumber *)pages{
    [self addPageControl];
    float height = _effectNodesScrollView.frame.origin.y + _effectNodesScrollView.frame.size.height;
    _pageControl.frame=CGRectMake(5, height ,kScreenWidth - 40, 30);
    _pageControl.numberOfPages = [pages integerValue];
    _pageControl.currentPage = 0;
    [self.view addSubview:_pageControl];
    [self.view bringSubviewToFront:_pageControl];
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

- (NSArray *) getPriceWithV1:(NSString *)v1 V2:(NSString *)v2 C1:(NSString *)c1 C2:(NSString *)c2 {
    NSString *priceC = @"";
    NSString *cny = @"";
    if([c1 isEqualToString:@"CNY"]){
        priceC = [_cacl formatAmount:[_cacl div:v1 :v2 ] :6 :NO :NO];
        cny = c1;
    }else if([c1 isEqualToString:@"SWTC"]&&![c2 isEqualToString:@"CNY"]){
        priceC = [_cacl formatAmount:[_cacl div:v1 :v2 ] :6 :NO :NO];
        cny = c1;
    }else {
        priceC = [_cacl formatAmount:[_cacl div:v2 :v1 ] :6 :NO :NO];
        cny = c2;
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

- (XHPageControl *)addPageControl {
    _pageControl = [[XHPageControl alloc] init];
    _pageControl.frame=CGRectMake(0, _effectNodesScrollView.bounds.size.height + 50,kScreenWidth - 40, 30);
    _pageControl.delegate=self;
    _pageControl.currentColor = [UIColor colorWithHex:0x3B6CA6];
    _pageControl.currentMultiple = 3;
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
