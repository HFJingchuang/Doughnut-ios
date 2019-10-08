//
//  TPOSAssetViewController.m
//  TokenBank
//
//  Created by MarcusWoo on 07/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import "TPOSAssetViewController.h"
#import "UIColor+Hex.h"
#import "TPOSMacro.h"
#import "TPOSAssetCell.h"
#import "TPOSQRCodeReceiveViewController.h"
#import "TPOSNavigationController.h"
#import <AVFoundation/AVFoundation.h>
#import "TPOSScanQRCodeViewController.h"
#import "TPOSCameraUtils.h"
#import "TPOSQRResultHandler.h"
#import "TPOSQRCodeResult.h"
#import "TPOSCreateWalletViewController.h"
#import "TPOSTokenDetailViewController.h"
#import "TPOSTransactionViewController.h"
#import "TPOSTokenModel.h"
#import "TPOSContext.h"
#import "TPOSWalletModel.h"
#import "TPOSAssetItem.h"
#import "TPOSAssetTopView.h"
#import "TPOSAssetPopWindow.h"
#import "TPOSAssetChooseWalletView.h"
#import "TPOSWalletManagerViewController.h"

#import "TPOSBlockChainModel.h"
#import "TPOSAssetEmptyView.h"
#import "TPOSWalletDao.h"
#import "TPOSBackupAlert.h"
#import "TPOSJTManager.h"
#import "TPOSSelectChainTypeViewController.h"
#import "DOSAssetHeader.h"

#import "TPOSWalletDetailDaoManager.h"

#import <Masonry/Masonry.h>;

static NSString * const TPOSAssetCellId = @"TPOSAssetCellIdentifier";

@interface TPOSAssetViewController ()<UITableViewDelegate, UITableViewDataSource, TPOSAssetEmptyViewDelegate>

@property (strong, nonatomic) UICollectionView *mainView;
@property (strong, nonatomic) DOSAssetHeader *header;
@property (strong, nonatomic) UITableView *table;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) CGFloat totleAsset;
@property (nonatomic, copy) NSString *unit;

@property (nonatomic, strong) NSArray<TPOSTokenModel *> *tokenModels;

@property (nonatomic, weak) TPOSAssetChooseWalletView *assetChooseWalletView;

@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@property (nonatomic, assign) BOOL privateMode;

@property (nonatomic, strong) TPOSAssetEmptyView *emptyView;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@property (nonatomic, strong) NSArray<TPOSWalletModel *> *wallets;

@end

@implementation TPOSAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
    [self loadWallets];
    [self loadCurrentWallet];
    [self setupSubviews];
    [self registerCells];
    [self checkBackup];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
    [self addRightBarButtonImage:[UIImage imageNamed:@"icon_sao"] action:@selector(TapRightImage)];
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithTitle:_currentWallet.walletName style:UIBarButtonItemStylePlain target:self action:@selector(TapWalletName)];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateSelected];
}

-(void)viewWillDisappear:(BOOL)animated {}

-(void) TapWalletName {
    TPOSWalletManagerViewController *walletManagerViewController = [[TPOSWalletManagerViewController alloc] init];
    [self.navigationController pushViewController:walletManagerViewController animated:YES];
}

-(void)TapRightImage {
    __weak typeof(self) weakSelf = self;
    [weakSelf pushToScan];
}

- (void)changeLanguage{
//    self.acountBalanceLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"account_asset"];
//    self.addAssetLabel.text = [NSString stringWithFormat:@"%@%@",@" + ",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"add_asset"]];
//    self.myAssetLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"my_asset"];
//    self.createLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"create_wallet"];
//    self.importLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"import"];
//    self.toCNYLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"toCNY"];
}

- (void)registerCells {
    [self.table registerNib:[UINib nibWithNibName:@"TPOSAssetCell" bundle:nil] forCellReuseIdentifier:TPOSAssetCellId];
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
}

- (void)viewDidReceiveLocalizedNotification {
    [super viewDidReceiveLocalizedNotification];
    [self.emptyView changeLanguage];
    [self changeLanguage];
    [self.table reloadData];
}

- (void)dealloc {
    if (_table) {
        [_table removeObserver:self forKeyPath:@"contentOffset"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public
- (void)autoRefreshData {
    [self.table.mj_header beginRefreshing];
}

#pragma mark - Private

- (void) loadCurrentWallet {
    __weak typeof(self) weakSelf = self;
    _currentWallet = [TPOSContext shareInstance].currentWallet;
    if (_currentWallet) {
    }
}

- (void)loadWallets {
    __weak typeof(self) weakSelf = self;
    [self.walletDao findAllWithComplement:^(NSArray<TPOSWalletModel *> *walletModels) {
        weakSelf.wallets = walletModels;
    }];
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

- (void)loadBalance {
    __weak typeof (self) weakSelf = self;
    
    if (weakSelf.currentWallet) {
        if ([weakSelf.currentWallet.blockChainId isEqualToString:swtcChain]) {
            [weakSelf loadSWTCBalance];
        }
    }
}

- (void)loadSWTCBalance {
    __weak typeof (self) weakSelf = self;
    NSString *address = weakSelf.currentWallet.address;
    [[TPOSJTManager shareInstance] requestBalance:address success:^(NSArray<TPOSTokenModel *> *tokenList) {
        weakSelf.tokenModels = tokenList;
        [weakSelf.table reloadData];
        //[weakSelf.header updateTotalAsset:0 unit:@"￥" privateMode:weakSelf.privateMode];
        [weakSelf setWalletModels:tokenList];
        [weakSelf.table.mj_header endRefreshing];
    } failure:^(NSError *error) {
        weakSelf.tokenModels = nil;
        [weakSelf.table reloadData];
        [weakSelf.table.mj_header endRefreshing];
    }];
}

- (void)checkBackup {
    __weak typeof(self) weakSelf = self;
    [[[TPOSWalletDao alloc] init] findAllWithComplement:^(NSArray<TPOSWalletModel *> *walletModels) {
        [walletModels enumerateObjectsUsingBlock:^(TPOSWalletModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.backup) {
                [TPOSBackupAlert showWithWalletModel:obj inView:[UIApplication sharedApplication].keyWindow.rootViewController.view navigation:(id)weakSelf.navigationController];
            }
        }];
    }];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWallet:) name:kChangeWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteWallet:) name:kDeleteWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWallet:) name:kCreateWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editWallet:) name:kEditWalletNotification object:nil];
}

- (void)changeWallet:(NSNotification *)noti {
    [self loadCurrentWallet];
}

- (void)deleteWallet:(NSNotification *)noti {
    [self loadWallets];
}

- (void)addWallet:(NSNotification *)noti {
    [self loadWallets];
}

- (void)editWallet:(NSNotification *)noti {
    [self loadWallets];
}

- (void)setupSubviews {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _mainView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) collectionViewLayout:layout];
    _mainView.backgroundColor = [UIColor colorWithHex:0xffffff];
    [self.view addSubview:self.mainView];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self.view);
        make.right.equalTo(self.view).offset(-19);
        make.left.equalTo(self.view).offset(19);
    }];
    [_mainView registerNib:[UINib nibWithNibName:@"DOSAssetHeaderCell" bundle:nil] forCellWithReuseIdentifier:@"DOSAssetHeaderCell"];
    __weak typeof(self) weakSelf = self;
    MJRefreshGifHeader *header = [self grayTableHeaderWithBigSize:YES RefreshingBlock:^{
        [weakSelf loadBalance];
    }];
    self.mainView.mj_header = header;
    [self autoRefreshData];
}

- (IBAction)tapCreateAction:(id)sender {
    [self pushToCreateWallet];
}

- (IBAction)tapImportAction:(id)sender {
    [self pushToImportWallet];
}

#pragma mark - TPOSAssetEmptyViewDelegate
- (void)TPOSAssetEmptyViewDidTapAddAssetButton {
    
}

- (void)changeWalletAction {
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (BOOL)shouldShowEmptyView {
    return _tokenModels.count == 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self shouldShowEmptyView]) {
        return 1;
    } else {
        if (section == 1) {
            return 1;
        } else {
            return _tokenModels.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self shouldShowEmptyView]) {
        return 380;
    } else {
        if (indexPath.section == 1) {
            return 52;
        }
        return 77;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self shouldShowEmptyView]) {
        UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
        [emptyCell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [emptyCell.contentView addSubview:self.emptyView];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return emptyCell;
    } else {
        TPOSAssetCell *cell = (TPOSAssetCell *)[tableView dequeueReusableCellWithIdentifier:TPOSAssetCellId forIndexPath:indexPath];
        [cell updateWithModel:_tokenModels[indexPath.row]];
        if (_privateMode) {
            [cell updatePrivateStatus:_privateMode];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((indexPath.section == 1) || [self shouldShowEmptyView]) {
        return;
    }
    TPOSTokenDetailViewController *tokenDetailViewController = [[TPOSTokenDetailViewController alloc] init];
    tokenDetailViewController.tokenModel = _tokenModels[indexPath.row];
    [self.navigationController pushViewController:tokenDetailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *ID = @"UITableViewHeaderFooterViewID";
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:ID];
        view.contentView.backgroundColor = [UIColor colorWithHex:0xf5f5f9];
        view.backgroundColor = [UIColor colorWithHex:0xf5f5f9];
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithHex:0x808080];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.centerY.equalTo(view);
        }];
        label.tag = 0xdf;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 10;
    }
    return 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        NSValue *p = [change objectForKey:NSKeyValueChangeNewKey];
        CGPoint point = [p CGPointValue];
        if (point.y < 0) {
            //self.topBgView.transform = CGAffineTransformMakeScale(1, 1+(fabs(point.y)/160.0));
        } else {
        }
    }
}

#pragma mark - TPOSAssetHeaderDelegate

- (void)TPOSAssetHeaderDidTapTransactionButton {
    [self pushToTransaction];
}

- (void)TPOSAssetHeaderDidTapReceiverButton {
    [self showQRCodeReceiver];
}

- (void)TPOSAssetHeaderDidTapPrivateButtonWithStatus:(BOOL)status {
    _privateMode = status;
    [self.table reloadData];
}

#pragma mark - TPOSAssetTopViewDelegate
- (void)assetTopViewDidTapAddButton:(TPOSAssetTopView *)assetTopView {
    __weak typeof(self) weakSelf = self;
    [TPOSAssetPopWindow showInView:self.view callBack:^(NSInteger index) {
        switch (index) {
            case 0: // 扫一扫
                
                break;
            case 1: //添加钱包
                [weakSelf pushToCreateWallet];
                break;
            default:
                break;
        }
    }];
}

- (void)assetTopViewDidTapReceiverButton:(TPOSAssetTopView *)assetTopView {
    [self showQRCodeReceiver];
}

- (void)assetTopViewDidTapTransactionButton:(TPOSAssetTopView *)assetTopView {
    [self pushToTransaction];
}

- (void)assetTopViewDidTapChangeWalletButton:(TPOSAssetTopView *)assetTopView {
    if (_assetChooseWalletView) {
        [_assetChooseWalletView close];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    CGFloat off = 74;
    if (kIphoneX) {
        off = 98;
    }
    _assetChooseWalletView = [TPOSAssetChooseWalletView showInView:[UIApplication sharedApplication].keyWindow walletModels:_wallets offset:off selectWalletModel:_currentWallet callBack:^(TPOSWalletModel *walletModel,BOOL add, BOOL cancel) {
        if (!cancel && !add) {
            if (walletModel.walletId == _currentWallet.walletId) {
                return;
            }
            weakSelf.currentWallet = walletModel;
            [weakSelf autoRefreshData];
            [weakSelf.walletDao updateCurrentWalletID:walletModel.walletId complement:nil];
            [weakSelf.table reloadData];
        }
        
        if (add) { //创建钱包
            [weakSelf pushToCreateWallet];
        }
        
    }];
}

#pragma mark - push
- (void)pushToTransaction {
    TPOSTransactionViewController *transactionViewController = [[TPOSTransactionViewController alloc] init];
    
    [_tokenModels enumerateObjectsUsingBlock:^(TPOSTokenModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.token_type == 0) {
            transactionViewController.currentTokenModel = obj;
            *stop = YES;
        }
    }];
    [self.navigationController pushViewController:transactionViewController animated:YES];
}

- (void)pushToImportWallet {
    TPOSSelectChainTypeViewController *vc = [[TPOSSelectChainTypeViewController alloc] init];
    [self presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)pushToScan {
    
    __weak typeof(self) weakSelf = self;
    
    [[TPOSCameraUtils sharedInstance] startScanCameraWithVC:self completion:^(NSString *result) {
        TPOSQRCodeResult *qrResult = [[TPOSQRResultHandler sharedInstance] codeResultWithScannedString:result];
        if (qrResult != nil) {
            TPOSTransactionViewController *vc = [[TPOSTransactionViewController alloc] init];
            vc.qrResult = qrResult;
            TPOSNavigationController *nvc = [[TPOSNavigationController alloc] initWithRootViewController:vc];
            [weakSelf presentViewController:nvc animated:YES completion:nil];
        }
    }];
}

- (void)showQRCodeReceiver {
    TPOSQRCodeReceiveViewController *qrVC = [[TPOSQRCodeReceiveViewController alloc] init];
    
    if (_currentWallet) {
        qrVC.address = _currentWallet.address;
        qrVC.tokenType = [_currentWallet.blockChainId isEqualToString:ethChain] ? @"ETH" : @"SWT" ;
        qrVC.tokenAmount = 0;
        qrVC.basicType = [_currentWallet.blockChainId isEqualToString:ethChain] ? TPOSBasicTokenTypeEtheruem : TPOSBasicTokenTypeJingTum;
        TPOSNavigationController *navi = [[TPOSNavigationController alloc] initWithRootViewController:qrVC];
        [self presentViewController:navi animated:YES completion:nil];
    } else {
        
        __weak typeof(self) weakSelf = self;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"no_wallet_tips"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf pushToCreateWallet];
        }];
        [alert addAction:confirmAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)pushToCreateWallet {
    TPOSCreateWalletViewController *createWalletViewController = [[TPOSCreateWalletViewController alloc] init];
    TPOSNavigationController *navi = [[TPOSNavigationController alloc] initWithRootViewController:createWalletViewController];
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark -
- (void)onScanButtonTapped:(UIButton *)btn {
    
    __weak typeof(self) weakSelf = self;
    
    [[TPOSCameraUtils sharedInstance] startScanCameraWithVC:self completion:^(NSString *result) {
        TPOSQRCodeResult *qrResult = [[TPOSQRResultHandler sharedInstance] codeResultWithScannedString:result];
        if (qrResult != nil) {
            TPOSTransactionViewController *vc = [[TPOSTransactionViewController alloc] init];
            vc.qrResult = qrResult;
            TPOSNavigationController *nvc = [[TPOSNavigationController alloc] initWithRootViewController:vc];
            [weakSelf presentViewController:nvc animated:YES completion:nil];
        }
    }];
}

#pragma mark - Getter & Setter
- (UITableView *)table {
    //_table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    _table.tableHeaderView = [UIView new];
//    _table.tableFooterView = [UIView new];
    _table.backgroundColor = [UIColor clearColor];
    _table.separatorColor = [UIColor colorWithHex:0xF5F5F9];
    _table.delegate = self;
    _table.dataSource = self;
    if (@available(iOS 11,*)) {
        _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [_table addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    return _table;
}

- (void)setWalletModels:(NSArray<TPOSTokenModel *> *)walletModels {
    
    [[TPOSWalletDetailDaoManager shareInstance] updateWalletDetailModels:walletModels];
}
@end
