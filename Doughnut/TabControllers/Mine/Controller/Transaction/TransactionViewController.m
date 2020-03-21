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
#import "WalletManage.h"
#import "SVProgressHUD.h"
#import "Masonry.h"
#import "UIView+Toast.h"
#import "TransactionViewController.h"
#import "TransactionTokensViewController.h"
#import "TransactionGasView.h"
#import "TPOSNavigationController.h"
#import "ContactViewController.h"
#import "CaclUtil.h"
#import "TransferDialogView.h"


static long FIFTEEN = 15 * 60 * 1000;
@interface TransactionViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UILabel *addressTip;
@property (weak, nonatomic) IBOutlet UITextField *amountTF;
@property (weak, nonatomic) IBOutlet UILabel *amountTip;
@property (weak, nonatomic) IBOutlet UITextView *remarkTV;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *tokenSelectView;
@property (nonatomic, weak) IBOutlet UILabel *tokenSelectLabel;

@property (nonatomic, assign) CGFloat gas;

@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@end

@implementation TransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCurrentWallet];
    [self loadData];
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
    self.addressTip.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"wrong_addr_tips"];
    self.addressTip.hidden = YES;
    self.amountTip.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"amount_zore"];
    self.amountTip.hidden = YES;
    [self.doneButton setTitle:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"done"] forState:UIControlStateNormal];
}

-(void)setNavigation{
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self addRightBarButtonImage:[UIImage imageNamed:@"icon_sao"] action:@selector(toScan)];
}

- (void)toScan {
    [self pushToScan:self];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTokenType:) name:getChangeToken object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTransactionAddr:) name:getTransactionAddress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTransactionResult:) name:transactionFlag object:nil];
}

-(void)changeTokenType:(NSNotification *)notification{
    NSDictionary *data = notification.object;
    _tokenName = [data valueForKey:@"name"];
    _tokenIssuer = [data valueForKey:@"issuer"];
    _tokenBalance = [data valueForKey:@"balance"];
    _balanceLabel.text = [NSString stringWithFormat:@"%@:%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"balance_amount"],_tokenBalance];
    _tokenNameLabel.text = _tokenName;
    _tokenSelectLabel.text = self.tokenName;
}

-(void)getTransactionAddr:(NSNotification *)notification{
    NSDictionary *data = notification.object;
    _addressTF.text = [data valueForKey:@"address"]?[data valueForKey:@"address"]:@"";
}

-(void)getTransactionResult:(NSNotification *)notification {
    NSDictionary *result = notification.object;
    if([[result valueForKey:@"status"] isEqualToString:@"success"]){
        NSDictionary *tx = [result objectForKey:@"result"];
        NSDictionary *txJson = [tx objectForKey:@"tx_json"];
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        NSMutableArray *records = [NSMutableArray new];
        [records addObjectsFromArray:[defaults objectForKey:@"transactionContacts"]];
        NSMutableDictionary *record = [NSMutableDictionary new];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [record setValue:self.addressTF.text forKey:@"address"];
        [record setValue:[formatter stringFromDate:[NSDate date]] forKey:@"date"];
        float amount = [[txJson valueForKey:@"Amount"] floatValue]/1000000;
        [record setValue:[NSString stringWithFormat:@"%@ %@", [[NSString stringWithFormat:@"%f",amount] deleteFloatAllZero], _tokenSelectLabel.text] forKey:@"content"];
        [records addObject:record];
        [defaults setObject:records forKey:@"transactionContacts"];
        [defaults synchronize];
        self.addressTF.text = @"";
        self.amountTF.text = @"";
        self.remarkTV.text = @"";
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_suc"]];
        [self checkDoneButtonStatus];
    }else {
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_fai"]];
    }
}

- (void)loadData {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *data = [defaults objectForKey:@"currentTokenForTransaction"];
    if (!_tokenName && !_tokenIssuer &&!_tokenBalance){
        _tokenName = [data valueForKey:@"name"]?[data valueForKey:@"name"]:@"SWTC";
        _tokenIssuer = [data valueForKey:@"issuer"];
        _tokenBalance = [data valueForKey:@"value"]?[data valueForKey:@"value"]:@"---";
    }
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
    _balanceLabel.text = [NSString stringWithFormat:@"%@:%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"balance_amount"],_tokenBalance];
    _tokenNameLabel.text = self.tokenName;
    _tokenSelectLabel.text = self.tokenName?self.tokenName:@"SWTC";
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTokenName)];
    [_tokenSelectView addGestureRecognizer:tapGesture2];
    _tokenSelectView.userInteractionEnabled = YES;
    self.amountTF.rightView = _tokenSelectView;
    self.amountTF.rightViewMode = UITextFieldViewModeAlways;
    [self.amountTF bringSubviewToFront:_tokenSelectView];
    self.gas = 0.00001;
    self.gasLabel.text = [NSString stringWithFormat:@"%@ %@ %@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"gas_fee"],[[[CaclUtil alloc]init]formatAmount:[NSString stringWithFormat:@"%f",self.gas]:6 :YES :NO],@"SWTC"];
    UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFeeLabel)];
    [self.gasLabel addGestureRecognizer:tapGesture3];
    self.gasLabel.userInteractionEnabled = YES;
    [self.addressTF addTarget:self action:@selector(textFieldDidEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [self.amountTF addTarget:self action:@selector(textFieldDidEditing:) forControlEvents:UIControlEventEditingChanged];
    self.addressTF.delegate = self;
    self.amountTF.delegate = self;
    [self checkDoneButtonStatus];
    if (self.address&& [[Remote instance]isValidAddress:self.address]){
        self.addressTF.text = self.address;
    }
    if (self.amount&& [[[CaclUtil alloc]init] compare:_amountTF.text :@"0"] != NSOrderedDescending ){
        self.amountTF.text = self.amount;
    }
    if (!_tokenBalance||[[[CaclUtil alloc]init] compare:_tokenBalance :@"0"] != NSOrderedDescending){
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_enough_token"]];
    }
}

- (void)clickTokenName {
    TransactionTokensViewController *vc = [[TransactionTokensViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)clickContact {
    ContactViewController *vc = [[ContactViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textFieldDidEditing:(UITextField *)textField {
    [self checkDoneButtonStatus];
}

- (void)checkDoneButtonStatus {
    BOOL enable = YES;
    if (_addressTF.text.length == 0) {
        enable = NO;
    }
    if ([[[CaclUtil alloc]init] compare:_tokenBalance :@"0"] != NSOrderedDescending){
        enable = NO;
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_enough_token"]];
    }
    if (![[WalletManage shareWalletManage].remote isValidAddress:_addressTF.text]) {
        enable = NO;
        self.addressTip.hidden = NO;
    }else {
        self.addressTip.hidden = YES;
    }
    if (_amountTF.text.length == 0||[[[CaclUtil alloc]init] compare:_amountTF.text :@"0"] != NSOrderedDescending) {
        enable = NO;
        self.amountTip.hidden = NO;
    }else if ([[[CaclUtil alloc]init] compare:_amountTF.text :_tokenBalance] == NSOrderedDescending){
        enable = NO;
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_enough_token"]];
    }else {
        self.amountTip.hidden = YES;
    }
    if ([_addressTF.text isEqualToString:_currentWallet.address]){
        enable = NO;
        self.addressTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wrong_addr_tips"];
        self.addressTip.hidden = NO;
    }else {
        self.addressTip.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_to_self"];
        self.addressTip.hidden = YES;
    }
    self.doneButton.enabled = enable;
    [self.doneButton setBackgroundColor:enable?[UIColor colorWithHex:0x383B3E alpha:1]:[UIColor colorWithHex:0x383B3E alpha:0.5]];
}

-(void)clickFeeLabel{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    TransactionGasView *transactionGasView = [TransactionGasView transactionViewWithMinFee:0.00001 maxFee:1 recommentFee:self.gas];
    transactionGasView.getGasPrice = ^(CGFloat gas) {
        self.gas = gas;
        self.gasLabel.text = [NSString stringWithFormat:@"%@ %@ %@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"gas_fee"], [[[CaclUtil alloc]init]formatAmount:[NSString stringWithFormat:@"%f",self.gas]:6 :YES :NO],@"SWTC"];
    };
    [transactionGasView showWithAnimate:TPOSAlertViewAnimateBottomUp inView:self.view.window];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _amountTF){
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSPredicate * predicate0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0][0-9]+$"];
        NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(([1-9]{1}[0-9]*|[0])\.?[0-9]{0,6})$"];
        return ![predicate0 evaluateWithObject:str] && [predicate1 evaluateWithObject:str] ? YES : NO;
    }else {
        return YES;
    }
}
- (IBAction)transactionAction:(id)sender {
    NSError* err = nil;
    KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.currentWallet.keyStore error:&err];
    //Wallet *decryptEthECKeyPair = [KeyStore decrypt:weakAlertController.textFields.firstObject.text wallerFile:keystore];
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setValue:self.currentWallet.address forKey:@"account"];
    [data setValue:self.addressTF.text forKey:@"to"];
    [data setValue:[NSNumber numberWithFloat:[self.amountTF.text floatValue]] forKey:@"value"];
    [data setValue:self.tokenName forKey:@"currency"];
    [data setValue:self.tokenIssuer?self.tokenIssuer:@"" forKey:@"issuer"];
    [data setValue:[NSNumber numberWithFloat:self.gas * 1000000] forKey:@"fee"];
    [data setValue:self.remarkTV.text forKey:@"memo"];
    //[data setValue:[decryptEthECKeyPair secret] forKey:@"secret"];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *time = [defaults objectForKey:@"setTime"]?[defaults objectForKey:@"setTime"]:@"0";
    long deff = [[[[CaclUtil alloc]init] sub:[NSString stringWithFormat:@"%.f",([[NSDate date] timeIntervalSince1970]*1000)] :time] longLongValue];
    if (deff > FIFTEEN){
        TransferDialogView *dialog = [TransferDialogView transactionDialogView];
        dialog.wallet = _currentWallet;
        dialog.confirmAction = ^(NSString *backSecret) {
            if (backSecret){
                [data setValue:backSecret forKey:@"secret"];
                [[WalletManage shareWalletManage]transactionWithData:data];
            }
        };
        [dialog showWithAnimate:TPOSAlertViewAnimateCenterPop inView:self.view.window];
    }else {
        NSString *password = [defaults objectForKey:@"setPassword"];
        Wallet *decryptEthECKeyPair = [KeyStore decrypt:password wallerFile:keystore];
        [data setValue:[decryptEthECKeyPair secret] forKey:@"secret"];
        [[WalletManage shareWalletManage]transactionWithData:data];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
