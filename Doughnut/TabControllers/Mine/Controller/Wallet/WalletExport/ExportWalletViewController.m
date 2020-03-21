//
//  ExportWalletViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/14.
//  Copyright © 2019 jch. All rights reserved.
//
#import "TPOSTabBarController.h"
#import "ExportWalletViewController.h"
#import "UIImage+TPOS.h"
#import "TPOSPrivateKeyImportWalletViewController.h"
#import "PKExportViewController.h"
#import "KSExportViewController.h"
#import "TPOSScrollContentView.h"
#import "TPOSScanQRCodeViewController.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"

#import "Masonry.h"

@interface ExportWalletViewController ()<TPOSPageContentViewDelegate,TPOSSegmentTitleViewDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) TPOSPageContentView *pageContentView;
@property (nonatomic, strong) TPOSSegmentTitleView *titleView;
@property (nonatomic, strong) NSMutableArray *importTypeTitles;

@property (nonatomic, strong) PKExportViewController *pkVC;
@property (nonatomic, strong) KSExportViewController *keystoreVC;
@end

@implementation ExportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupView];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"wallet_export"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarStyle];
    [self.view setBackgroundColor:[UIColor colorWithHex:0x3B6CA6]];
}

- (void)setNavigationBarStyle {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0x3B6CA6]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xffffff]}];
    [self addLeftBarButtonImage:[[UIImage imageNamed:@"icon_back_withe"] tb_imageWithTintColor:[UIColor whiteColor]] action:@selector(responseLeftButton)];
}

-(void)responseLeftButton{
    if (_isFirst) {
        [(UINavigationController *)self.view.window.rootViewController setViewControllers:@[[[TPOSTabBarController alloc] init]] animated:NO];
         [self.navigationController pushViewController:[[TPOSTabBarController alloc] init] animated:NO];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupData {
    [self.importTypeTitles addObject:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"pri_key"]];
    [self.importTypeTitles addObject:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"keyStore"]];
}

- (void)setupView {
    [self contentView];
    [self.view addSubview:_contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-40);
    }];
    self.titleView = [[TPOSSegmentTitleView alloc]initWithFrame:CGRectZero
                                                         titles:[self importTypeTitles]
                                                       delegate:self
                                                  indicatorType:TPOSIndicatorTypeNone];
    self.titleView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    self.titleView.titleNormalColor = [UIColor colorWithHex:0xC7C7CC];
    self.titleView.titleSelectColor = [UIColor colorWithHex:0x021E38];
    self.titleView.titleSelectFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    self.titleView.titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    self.titleView.selectIndex = 0;
    [self.contentView addSubview:_titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.height.equalTo(@45);
    }];
    NSMutableArray *childVCs = [[NSMutableArray alloc]init];
    _pkVC = [[PKExportViewController alloc] initWithNibName:@"PKExportViewController" bundle:nil];
    _pkVC.walletName = self.walletModel.walletName;
    _pkVC.privateKey = self.walletModel.privateKey;
    [childVCs addObject:_pkVC];
    [self addChildViewController:_pkVC];
    _keystoreVC = [[KSExportViewController alloc] initWithNibName:@"KSExportViewController" bundle:nil];
    _keystoreVC.walletName = self.walletModel.walletName;
    _keystoreVC.keyStore = self.walletModel.keyStore;
    [childVCs addObject:_keystoreVC];
    [self addChildViewController:_keystoreVC];
    self.pageContentView = [[TPOSPageContentView alloc]initWithFrame:CGRectMake(0, 45, self.contentView.bounds.size.width, self.contentView.frame.size.height - 45) childVCs:childVCs parentVC:self delegate:self];
    self.pageContentView.contentViewCanScroll = NO;
    self.pageContentView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    self.pageContentView.contentViewCurrentIndex = 0;
    [self.contentView addSubview:_pageContentView];
}

#pragma mark - TPOSPageContentViewDelegate & TPOSSegmentTitleViewDelegate
- (void)TPOSSegmentTitleView:(TPOSSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.pageContentView.contentViewCurrentIndex = endIndex;
}

- (void)FSContenViewDidEndDecelerating:(TPOSPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.titleView.selectIndex = endIndex;
}

#pragma mark - Getter
- (NSMutableArray *)importTypeTitles {
    if (!_importTypeTitles) {
        _importTypeTitles = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _importTypeTitles;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.frame = CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height - 60);
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    }
    return _contentView;
}

@end
