//
//  DoughnutHandler.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/10.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DappWKWebViewController.h"
#import "JavaScriptCore/JavaScriptCore.h"
#import "TPOSMacro.h"
#import <WebKit/WebKit.h>
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import "TPOSContext.h"
#import "DappTransferDetailDialog.h"
#import "TransferDialogView.h"
#import "WalletManage.h"
#import "CaclUtil.h"
#import "TPOSShareMenuView.h"
#import "TPOSShareView.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

static NSString *MSG_SUCCESS = @"success";
static long FIFTEEN = 15 * 60 * 1000;
@interface DappWKWebViewController()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
   NSString *mFrom, *mTo, *mValue, *mToken, *mIssuer, *mGas, *mMemo;
}
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSMutableDictionary *result;
@property (nonatomic, strong) TPOSWalletDao *walletDao;
@property (nonatomic, strong) TPOSWalletModel *currentWallet;
@end

@implementation DappWKWebViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self initWKWebView];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getAppInfo"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getDeviceId"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getWallets"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getCurrentWallet"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"sign"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"transfer"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"invokeQRScanner"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"back"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"fullScreen"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"close"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getAppInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getDeviceId"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getWallets"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getCurrentWallet"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sign"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"transfer"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"invokeQRScanner"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"back"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"fullScreen"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"close"];
}

- (void)initWKWebView {
    self.view.backgroundColor = [UIColor redColor];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
//    NSString *bundlePath=[[NSBundle mainBundle]bundlePath];
//    NSString *path=[bundlePath stringByAppendingPathComponent:_htmlUrl];
//    NSURL *url=[NSURL fileURLWithPath:path];
//    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSURL *htmlURL = [NSURL URLWithString:_htmlUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    [self.webView loadRequest:request];
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTransactionResult:) name:transactionFlag object:nil];
}

-(void)getTransactionResult:(NSNotification *)notification {
    NSDictionary *tx = notification.object;
    if([[tx valueForKey:@"engine_result"] isEqualToString:@"tesSUCCESS"]){
        NSDictionary *txJson = [tx objectForKey:@"tx_json"];
        NSLog(@"%@", txJson);
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_suc"]];
    }else {
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_fai"]];
    }
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSLog(@"message.name====%@  body=%@",message.name,message.body);
    NSString *params = @"";
    NSString *callbackId = @"";
    NSMutableDictionary *body = message.body;
    if(body) {
        NSDictionary *data = [body objectForKey:@"body"];
        params = [data valueForKey:@"params"];
        callbackId = [data valueForKey:@"callback"];
    }
    if ([message.name isEqualToString:@"getAppInfo"]) {
        [self getAppInfo:callbackId];
    } else if ([message.name isEqualToString:@"getDeviceId"]) {
        [self getDeviceId:callbackId];
    } else if ([message.name isEqualToString:@"getWallets"]) {
        [self getWallets:callbackId];
    } else if ([message.name isEqualToString:@"getCurrentWallet"]) {
        [self getCurrentWallet:callbackId];
    } else if ([message.name isEqualToString:@"sign"]) {
        [self sign:params :callbackId];
    } else if ([message.name isEqualToString:@"transfer"]) {
        [self transfer:params :callbackId];
    } else if ([message.name isEqualToString:@"invokeQRScanner"]) {
        [self invokeQRScanner:callbackId];
    } else if ([message.name isEqualToString:@"back"]) {
        [self back];
    } else if ([message.name isEqualToString:@"fullScreen"]) {
        [self fullScreen:params];
    } else if ([message.name isEqualToString:@"close"]) {
        [self close];
    } else if ([message.name isEqualToString:@"shareToSNS"]) {
        [self shareToSNS:callbackId];
    }
}

- (void)getAppInfo:(NSString *)callbackId {
    NSString *version = @"";
    NSString *name = @"";
    NSBundle *currentBundle = [NSBundle mainBundle];
    NSDictionary *infoDictionary = [currentBundle infoDictionary];
    @try {
        if (infoDictionary) {
            version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        }
    } @catch (NSException *e) {
        NSLog(@"%@", e);
    }
    NSMutableDictionary *infoData = [NSMutableDictionary new];
    [infoData setValue:name forKey:@"name"];
    [infoData setValue:@"ios" forKey:@"system"];
    [infoData setValue:version forKey:@"version"];
    [infoData setValue:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"sys_version"];
    //infoData.putString("sys_version", Build.VERSION.SDK_INT + "");
    _result = [NSMutableDictionary new];
    [_result setValue:@(YES) forKey:@"result"];
    [_result setObject:infoData forKey:@"data"];
    [_result setValue:MSG_SUCCESS forKey:@"msg"];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callbackId, [_result mj_JSONString]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)getDeviceId:(NSString *)callbackId {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callbackId, result] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)getWallets:(NSString *)callbackId {
    NSMutableArray *infoData = [NSMutableArray new];
    [self.walletDao findAllWithComplement:^(NSArray<TPOSWalletModel *> *walletModels) {
        for (int i = 0; i < walletModels.count; i++) {
            NSMutableDictionary *wallet = [NSMutableDictionary new];
            NSString *address = walletModels[i].address;
            NSString *name = walletModels[i].walletName;
            [wallet setValue:address forKey:@"address"];
            [wallet setValue:name forKey:@"name"];
            [infoData addObject:wallet];
        }
    }];
    _result = [NSMutableDictionary new];
    [_result setValue:@(YES) forKey:@"result"];
    [_result setObject:infoData forKey:@"data"];
    [_result setValue:MSG_SUCCESS forKey:@"msg"];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callbackId, [_result mj_JSONString]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)getCurrentWallet:(NSString *)callbackId {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
    NSMutableDictionary *wallet = [NSMutableDictionary new];
    NSString *address = _currentWallet.address;
    NSString *name = _currentWallet.walletName;
    [wallet setValue:address forKey:@"address"];
    [wallet setValue:name forKey:@"name"];
    _result = [NSMutableDictionary new];
    [_result setValue:@(YES) forKey:@"result"];
    [_result setObject:wallet forKey:@"data"];
    [_result setValue:MSG_SUCCESS forKey:@"msg"];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callbackId,[_result mj_JSONString]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)sign:(NSString *)params :(NSString *)callbackId {
    @try {
        NSDictionary *tx = [self dictionaryWithJsonString:params];
        mTo = [tx valueForKey:@"to"]?[tx valueForKey:@"to"]:@"";
        mToken = [tx valueForKey:@"currency"]?[tx valueForKey:@"currency"]:@"";
        mIssuer = [tx valueForKey:@"issuer"]?[tx valueForKey:@"issuer"]:@"";
        mValue = [tx valueForKey:@"value"]?[tx valueForKey:@"value"]:@"";
        mMemo = [tx valueForKey:@"memo"]?[tx valueForKey:@"memo"]:@"";
        mGas = [tx valueForKey:@"gas"]?[tx valueForKey:@"gas"]:@"";
        NSString *fee = [[[NSDecimalNumber decimalNumberWithString:mGas] decimalNumberByMultiplyingBy: [NSDecimalNumber decimalNumberWithString:@"1000000"]] stringValue];
        _currentWallet = [TPOSContext shareInstance].currentWallet;
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setValue:_currentWallet.address forKey:@"from"];
        [data setValue:mTo forKey:@"to"];
        [data setValue:fee forKey:@"fee"];
        [data setValue:[NSString stringWithFormat:@"%@ %@",mValue,mToken] forKey:@"content"];
        [data setValue:mMemo forKey:@"memo"];
        DappTransferDetailDialog *dialog = [DappTransferDetailDialog DappTransferDetailDialogInit];
        [dialog setValues:data];
        dialog.confirmBack = ^(int i){
            NSError* err = nil;
            KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.currentWallet.keyStore error:&err];
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
        };
        [dialog showWithAnimate:TPOSAlertViewAnimateCenterPop inView:self.view.window];
    } @catch (NSException *e) {
        _result = [NSMutableDictionary new];
        [_result setValue:@(NO) forKey:@"result"];
        [_result setValue:e forKey:@"msg"];
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)",callbackId,[_result mj_JSONString]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    }
}

- (void)transfer:(NSString *)params :(NSString *)callbackId {
    @try {
        NSDictionary *tx = [self dictionaryWithJsonString:params];
        mTo = [tx valueForKey:@"to"]?[tx valueForKey:@"to"]:@"";
        mToken = [tx valueForKey:@"currency"]?[tx valueForKey:@"currency"]:@"";
        mIssuer = [tx valueForKey:@"issuer"]?[tx valueForKey:@"issuer"]:@"";
        mValue = [tx valueForKey:@"value"]?[tx valueForKey:@"value"]:@"";
        mMemo = [tx valueForKey:@"memo"]?[tx valueForKey:@"memo"]:@"";
        mGas = [tx valueForKey:@"gas"]?[tx valueForKey:@"gas"]:@"";
        NSString *fee = [[[NSDecimalNumber decimalNumberWithString:mGas] decimalNumberByMultiplyingBy: [NSDecimalNumber decimalNumberWithString:@"1000000"]] stringValue];
        _currentWallet = [TPOSContext shareInstance].currentWallet;
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setValue:_currentWallet.address forKey:@"from"];
        [data setValue:mTo forKey:@"to"];
        [data setValue:fee forKey:@"fee"];
        [data setValue:[NSString stringWithFormat:@"%@ %@",mValue,mToken] forKey:@"content"];
        [data setValue:mMemo forKey:@"memo"];
        DappTransferDetailDialog *dialog = [DappTransferDetailDialog DappTransferDetailDialogInit];
        [dialog setValues:data];
        dialog.confirmBack = ^(int i){
            NSError* err = nil;
            KeyStoreFileModel* keystore = [[KeyStoreFileModel alloc] initWithString:self.currentWallet.keyStore error:&err];
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
        };
        [dialog showWithAnimate:TPOSAlertViewAnimateCenterPop inView:self.view.window];
    } @catch (NSException *e) {
        _result = [NSMutableDictionary new];
        [_result setValue:@(NO) forKey:@"result"];
        [_result setValue:e forKey:@"msg"];
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)",callbackId,[_result mj_JSONString]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    }
}

- (void)invokeQRScanner:(NSString *)callbackId {
    [super pushToScan:self];
    [self.webView evaluateJavaScript:@"" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)back {
    [self.webView goBack];
}

- (void)fullScreen:(NSString *)params {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)shareToSNS:(NSString *)callbackId {
    [TPOSShareMenuView showInView:nil complement:^(TPOSShareType type) {
        UIImage *image = [TPOSShareView shareImageByQrcodeImage:[UIImage imageNamed:@"OK"] address:@"232323"];
        [self shareActionWithImage:image type:type];
    }];
}

- (void)shareActionWithImage:(UIImage *)image type:(TPOSShareType)type {
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSData *thumbData = UIImageJPEGRepresentation(image, 0.01);
    if (type < TPOSShareTypeQQSession) {
        WXImageObject *imageObject = [WXImageObject object];
        imageObject.imageData = imageData;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        WXMediaMessage *message = [WXMediaMessage message];
        message.mediaObject = imageObject;
        message.thumbData = thumbData;
        req.bText = NO;
        if (type == TPOSShareTypeWechatSession) {
            req.scene = WXSceneSession;
        } else {
            req.scene = WXSceneTimeline;
        }
        req.message = message;
        BOOL result = [WXApi sendReq:req];
        if (result) {
            
        }
    } else {
        QQApiImageObject *obj = [[QQApiImageObject alloc] init];
        obj.data = imageData;
        obj.previewImageData = thumbData;
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
        BOOL result = [QQApiInterface sendReq:req];
        if (result) {
            
        }
    }
    
}


@end
