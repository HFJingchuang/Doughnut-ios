//
//  TPOSBaseViewController.h
//  TokenBank
//
//  Created by MarcusWoo on 04/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MJRefreshGifHeader+TPOS.h"
#import "TPOSCustomMJRefreshFooter.h"
#import "TPOSLocalizedHelper.h"
#import "UIColor+Hex.h"
#import "KeyStoreFile.h"
#import "KeyStore.h"
#import "SVProgressHUD.h"
#import "TPOSMacro.h"
#import "TPOSCameraUtils.h"
#import "UILabel+Btn.h"
#import "NSString+TPOS.h"

typedef void (^tableHeaderRefreshAction)(void);

@class MJRefreshGifHeader;

@interface TPOSBaseViewController : UIViewController

- (UIButton *)backStyleButton;
- (void)addLeftBarButton:(UIBarButtonItem *)barButtonItem;
- (UIBarButtonItem *)addLeftBarButtonImage:(UIImage *)img action:(SEL)action;
- (UIBarButtonItem *)addRightBarButtonImage:(UIImage *)image action:(SEL)action;
- (void)addRightBarButton:(NSString *)title operationBlock:(void (^)(UIButton *rightBtn))operationBlock ;
- (void)addLeftBarButton:(NSString *)title operationBlock:(void (^)(UIButton *rightBtn))operationBlock ;

- (void)responseLeftButton;
- (void)responseRightButton;

- (void)setNavigationTitleColor:(UIColor *)textColor barColor:(UIColor *)barColor;

- (UITextField *)addNaviSearchBarWithPlaceholder:(NSString *)placeholder width:(CGFloat)width;
- (void)searchBarTextfieldDidChange:(UITextField *)textfield;

//更改本地化语言
- (void)viewDidReceiveLocalizedNotification;
- (void)changeLanguage;

- (MJRefreshGifHeader *)colorfulTableHeaderWithBigSize:(BOOL)isBigone
                                       RefreshingBlock:(tableHeaderRefreshAction)actionBlock;
// 读取本地JSON文件
- (id)readLocalFileWithName:(NSString *)name;
//json转字典
- (id)dictionaryWithJsonString:(NSString *)jsonString;
//写入json文件
- (void)writeLoaclFileWithPath:(NSString *)path content:(id)data;
// 扫码
- (void)pushToScan:(UIViewController *)viewController;

- (void) showErrorWithStatus:(NSString *)msg;
- (void) showInfoWithStatus:(NSString *)msg;
- (void) showSuccessWithStatus:(NSString *)msg;
@end
