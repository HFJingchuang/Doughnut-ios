//
//  DappMainViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/12/6.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DappMainViewController.h"
#import "TransferDialogView.h"
#import "NSString+TPOS.h"
#import "DappWKWebViewController.h"
#import "TPOSShareMenuView.h"
#import "TPOSShareView.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>


@interface DappMainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITextField *linkTF;

@end

@implementation DappMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavigationBarColor];
    _searchBtn.layer.cornerRadius = 10;
    _searchBtn.layer.masksToBounds = YES;
}

- (void)changeLanguage {
    _linkTF.placeholder = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"dapp_link"];
    [_searchBtn setTitle:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"search_btn"] forState:UIControlStateNormal];
}

- (void)setNavigationBarColor {
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"";
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"DAPP" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateSelected];
}

- (IBAction)searchAction:(id)sender {
    NSString *searchUrl = _linkTF.text;
    if (![searchUrl tb_isEmpty]) {
       if ([searchUrl hasPrefix:@"http://"] || [searchUrl hasPrefix:@"https://"]) {
           DappWKWebViewController *vc = [[DappWKWebViewController alloc]init];
           vc.htmlUrl = searchUrl;
           [self.navigationController pushViewController:vc animated:YES];
       } else {
           [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"err_link"]];
       }
    }else {
        [self showInfoWithStatus:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"null_link"]];
    }
//    [TPOSShareMenuView showInView:nil complement:^(TPOSShareType type) {
//        UIImage *image = [TPOSShareView shareImageByQrcodeImage:[UIImage imageNamed:@"OK"] address:@"232323"];
//        [self shareActionWithImage:image type:type];
//    }];
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
