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

@end
