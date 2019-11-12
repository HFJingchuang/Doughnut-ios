//
//  TransactionViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/8.
//  Copyright © 2019 jch. All rights reserved.
//
#import "UIColor+Hex.h"
#import "TPOSCameraUtils.h"
#import "TPOSQRCodeResult.h"
#import "TPOSContext.h"
#import "TPOSWalletModel.h"
#import "NSObject+TPOS.h"
#import "TPOSQRResultHandler.h"
#import "TPOSMacro.h"
#import "TPOSWalletDao.h"
#import "NSString+TPOS.h"
#import "UIImage+TPOS.h"
#import "TPOSTransactionViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>
#import "TransactionViewController.h"
#import "TransactionTokensViewController.h"

@interface TransactionViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *amountTF;
@property (weak, nonatomic) IBOutlet UITextView *remarkTV;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *tokenSelectView;
@property (nonatomic, weak) IBOutlet UILabel *tokenSelectLabel;

@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@end

@implementation TransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCurrentWallet];
    [self setupSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"transaction"];
    [self registerNotifications];
}

- (void) loadCurrentWallet {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigation];
    self.addressTF.delegate = self;
    self.amountTF.delegate = self;
    self.remarkTV.delegate = self;
    self.addressLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"enter_receive_addr"];
    self.amountLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"enter_amount"];
    self.remarkLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"enter_memos"];
    [self.doneButton setTitle:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"done"] forState:UIControlStateNormal];
   
}

-(void)setNavigation{
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self addRightBarButtonImage:[UIImage imageNamed:@"icon_transaction_qcode"] action:@selector(transgferWithQRCode)];
}

- (void)transgferWithQRCode {}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTokenType:) name:getChangeToken object:nil];
}

-(void)changeTokenType:(NSNotification *)notification{
    NSDictionary *data = notification.object;
    _tokenName = [data valueForKey:@"name"];
    _tokenIssuer = [data valueForKey:@"issuer"];
    _tokenBalance = [data valueForKey:@"balance"];
    _balanceLabel.text = [NSString stringWithFormat:@"%@:%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"balance_amount"],_tokenBalance ];
    _tokenSelectLabel.text = self.tokenName?self.tokenName:@"CNT";
}

- (void)setupSubviews{
    UIImageView *contacts = [UIImageView new];
    contacts.image = [UIImage imageNamed:@"triangle"];
    contacts.frame = CGRectMake(0, 0, 5, 30);
    contacts.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickContact)];
    [contacts addGestureRecognizer:tapGesture1];
    contacts.userInteractionEnabled = YES;
    self.addressTF.rightView = contacts;
    self.addressTF.rightViewMode = UITextFieldViewModeAlways;
    _balanceLabel.text = [NSString stringWithFormat:@"%@:%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"balance_amount"],_tokenBalance?_tokenBalance:@"0.00",self.tokenName?self.tokenName:@"CNT" ];
    _tokenSelectLabel.text = self.tokenName?self.tokenName:@"CNT";
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTokenName)];
    [_tokenSelectView addGestureRecognizer:tapGesture2];
    _tokenSelectView.userInteractionEnabled = YES;
    self.amountTF.rightView = _tokenSelectView;
    self.amountTF.rightViewMode = UITextFieldViewModeAlways;
    [self.amountTF bringSubviewToFront:_tokenSelectView];
}

- (void)clickTokenName {
    TransactionTokensViewController *vc = [[TransactionTokensViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)clickContact {
    TPOSTransactionViewController *vc = [[TPOSTransactionViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.amountTF){
        return [self validateNumber:string];
    }
    return YES;
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
