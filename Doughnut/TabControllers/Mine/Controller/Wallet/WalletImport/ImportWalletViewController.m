//
//  TPOSImportWalletViewController.m
//  TokenBank
//
//  Created by MarcusWoo on 11/02/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//
#import "UIImage+TPOS.h"
#import "ImportWalletViewController.h"
#import "TPOSPrivateKeyImportWalletViewController.h"
#import "PKImportWalletViewController.h"
#import "KSImportWalletViewController.h"
#import "TPOSScrollContentView.h"
#import "TPOSScanQRCodeViewController.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"
#import "TPOSBlockChainModel.h"

#import "Masonry.h"

@interface ImportWalletViewController ()<TPOSPageContentViewDelegate,TPOSSegmentTitleViewDelegate>
@property (nonatomic, strong) TPOSPageContentView *pageContentView;
@property (nonatomic, strong) TPOSSegmentTitleView *titleView;
@property (nonatomic, strong) NSMutableArray *importTypeTitles;

@property (nonatomic, strong) PKImportWalletViewController *pkVC;
@property (nonatomic, strong) KSImportWalletViewController *keystoreVC;
@end

@implementation ImportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupSubviews];
    self.view.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self addLeftBarButtonImage:[UIImage imageNamed:@"icon_navi_back"] action:@selector(responseLeftButton)];
}
     
-(void)responseLeftButton{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)setupData {
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_wallet"];
    [self.importTypeTitles addObject:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"pri_key"]];
    [self.importTypeTitles addObject:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"keyStore"]];
}

- (void)setupSubviews {
    self.titleView = [[TPOSSegmentTitleView alloc]initWithFrame:CGRectZero
                                                       titles:[self importTypeTitles]
                                                     delegate:self
                                                indicatorType:TPOSIndicatorTypeNone];
    self.titleView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    self.titleView.titleNormalColor = [UIColor colorWithHex:0xC7C7CC];
    self.titleView.titleSelectColor = [UIColor colorWithHex:0x021E38];
    self.titleView.titleSelectFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    self.titleView.titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    self.titleView.selectIndex = self.importFlag?self.importFlag:0;
    [self.view addSubview:_titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(@45);
    }];
    NSMutableArray *childVCs = [[NSMutableArray alloc]init];
        _pkVC = [[PKImportWalletViewController alloc] initWithNibName:@"PKImportWalletViewController" bundle:nil];
    _pkVC.scanResult = self.privateKey;
        [childVCs addObject:_pkVC];
        [self addChildViewController:_pkVC];
        _keystoreVC = [[KSImportWalletViewController alloc] initWithNibName:@"KSImportWalletViewController" bundle:nil];
    _keystoreVC.scanResult = self.keyStore;
        [childVCs addObject:_keystoreVC];
        [self addChildViewController:_keystoreVC];
    self.pageContentView = [[TPOSPageContentView alloc]initWithFrame:CGRectMake(0, 45.5, kScreenWidth, CGRectGetHeight(self.view.bounds)-55.5) childVCs:childVCs parentVC:self delegate:self];
    self.pageContentView.contentViewCanScroll = NO;
    self.pageContentView.contentViewCurrentIndex = self.importFlag?self.importFlag:0;
    [self.view addSubview:_pageContentView];
    [self setupNavigationBarItem];
}

- (void)setupNavigationBarItem {
    [self addRightBarButtonImage:[UIImage imageNamed:@"icon_sao"] action:@selector(gotoQRScanner)];
}

- (void)gotoQRScanner {
    [self pushToScan:self];
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

@end
