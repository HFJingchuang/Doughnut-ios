//
//  QRCodeReceiveViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/8.
//  Copyright © 2019 jch. All rights reserved.
//

#import "QRCodeReceiveViewController.h"
#import "TPOSMacro.h"
#import "SGQRCodeGenerateManager.h"
#import "TPOSWeb3Handler.h"
#import "TPOSNavigationController.h"
#import "UIImage+TPOS.h"
#import "NSObject+MJKeyValue.h"
#import "AssetTokensViewController.h"

#import <Masonry/Masonry.h>

@interface QRCodeReceiveViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *codeView;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletAddressLabel;
@property (weak, nonatomic) IBOutlet UIView *amountView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

@property (weak, nonatomic) IBOutlet UIView *tokenSelectView;
@property (nonatomic, weak) IBOutlet UILabel *tokenSelectLabel;

@end

@implementation QRCodeReceiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"receive"];
    self.tipLabel.text = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"share_for_collect"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.amountTextField];
    [self.tipLabel sizeToFit];
    [self loadData];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarStyle];
    self.amountTextField.delegate = self;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = self.contentView.frame.size;
    self.scrollView.backgroundColor = [UIColor colorWithHex:0x27B498];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    self.amountView.layer.cornerRadius = 10;
    self.amountView.layer.masksToBounds = YES;
    [self addLeftBarButtonImage:[[UIImage imageNamed:@"icon_back_withe"] tb_imageWithTintColor:[UIColor whiteColor]] action:@selector(responseLeftButton)];
}

- (void)setNavigationBarStyle {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0x27B498]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0x27B498]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xffffff]}];
    [self.view setBackgroundColor:[UIColor colorWithHex:0x27B498]];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTokenType:) name:getChangeToken object:nil];
}

-(void)changeTokenType:(NSNotification *)notification{
    NSDictionary *data = notification.object;
    _tokenName = [data valueForKey:@"name"];
    _tokenIssuer = [data valueForKey:@"issuer"];
    _tokenSelectLabel.text = self.tokenName?self.tokenName:@"SWTC";
}

- (void)setupSubviews {
    _tokenSelectLabel.text = self.tokenName?self.tokenName:@"SWTC";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTokenName)];
    [_tokenSelectView addGestureRecognizer:tapGesture];
    _tokenSelectView.userInteractionEnabled = YES;
    self.amountTextField.rightView = _tokenSelectView;
    self.amountTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.amountTextField bringSubviewToFront:_tokenSelectView];
    self.amountTextField.placeholder = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"set_collect_amount"];
}

- (void)clickTokenName {
    AssetTokensViewController *vc = [[AssetTokensViewController alloc]init];
    vc.viewName = NSStringFromClass(self.class);
    vc.singleFlag = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)responseLeftButton {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)loadData {
    self.walletNameLabel.text = self.walletName?self.walletName:@"--";
    self.walletAddressLabel.text = self.walletAddress?self.walletAddress:@"--";
    if (self.walletName && self.walletAddress && self.amountTextField.text.length == 0){
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setValue:[NSString stringWithFormat:@"%@_%@",self.tokenName?self.tokenName:@"SWTC",self.tokenIssuer?self.tokenIssuer:@""] forKey:@"Token_Name"];
        [data setValue:self.walletAddress forKey:@"Receive_Address"];
        [data setValue:@"0" forKey:@"Token_Amount"];
        NSString *str = [data mj_JSONString];
        UIImage *code = [SGQRCodeGenerateManager generateWithDefaultQRCodeData:str imageViewWidth:150];
        self.codeView.image = code;
        self.codeView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
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


//这里可以通过发送object消息获取注册时指定的UITextField对象
- (void)textFieldDidChangeValue:(NSNotification *)notification{
    UITextField *sender = (UITextField *)[notification object];
    if (self.walletName && self.walletAddress && sender.text.length != 0){
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setValue:self.tokenName forKey:@"Token_Name"];
        [data setValue:self.walletAddress forKey:@"Receive_Address"];
        [data setValue:sender.text forKey:@"Token_Amount"];
        NSString *str = [data mj_JSONString];
        UIImage *code = [SGQRCodeGenerateManager generateWithDefaultQRCodeData:str imageViewWidth:150];
        self.codeView.image = code;
        self.codeView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
