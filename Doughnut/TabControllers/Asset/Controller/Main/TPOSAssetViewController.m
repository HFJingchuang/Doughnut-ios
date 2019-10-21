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
#import "TPOSAssetChooseWalletView.h"
#import "TPOSWalletManagerViewController.h"
#import "TPOSBlockChainModel.h"
#import "TPOSWalletDao.h"
#import "AssetTableViewCell.h"
#import "TPOSBackupAlert.h"
#import "TPOSJTManager.h"
#import "TPOSSelectChainTypeViewController.h"
#import "AssetTokensViewController.h"

#import "TPOSWalletDetailDaoManager.h"
#import "WalletManage.h"
#import "AccountInfoModal.h"
#import "LineModel.h"
#import "TokenCellModel.h"
#import <Masonry/Masonry.h>//;

static NSString * const AssetTableViewCellID = @"AssetTableViewCellIdentifier";

@interface TPOSAssetViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIButton *assetSeeButton;
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (weak, nonatomic) IBOutlet UITableView *table;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tokenZeroSwitchConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalPointConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CNYPointConstraint;

//labels
@property (weak, nonatomic) IBOutlet UILabel *totalAssetLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAssetValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPointValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *CNYBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *CNYBalanceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *CNYPointValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *myAssetLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenZeroLabel;
@property (weak, nonatomic) IBOutlet UISwitch *tokenZeroSwitch;
@property (weak, nonatomic) IBOutlet UILabel *addAssetLabel;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet UILabel *importLabel;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) CGFloat totleAsset;
@property (nonatomic, copy) NSString *unit;

@property (nonatomic, strong) NSArray<TPOSTokenModel *> *tokenModels;

@property (nonatomic, strong) NSMutableArray<TokenCellModel *> *tokenCells;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *hiddenCells;

@property (nonatomic, weak) TPOSAssetChooseWalletView *assetChooseWalletView;

@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@property (nonatomic, assign) BOOL cellHidden;

@property (nonatomic, assign) BOOL valueHidden;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@property (nonatomic, strong) NSString *totalValue;

@property (nonatomic, strong) NSString *cnyValue;

@end

@implementation TPOSAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
    self.bottomConstraint.constant = kIphoneX?83:49;
    self.cellHidden = NO;
    self.valueHidden = NO;
    [self loadCurrentWallet];
    [self setupSubviews];
    [self registerCells];
    [self checkBackup];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self addRightBarButtonImage:[UIImage imageNamed:@"icon_sao"] action:@selector(TapRightImage)];
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithTitle:_currentWallet.walletName style:UIBarButtonItemStylePlain target:self action:@selector(TapWalletName)];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:24],NSForegroundColorAttributeName :[UIColor colorWithHex:0x021933]} forState:UIControlStateSelected];
    [self.assetSeeButton setImage:[UIImage imageNamed:@"icon_see"] forState:UIControlStateNormal];
    [self.assetSeeButton setImage:[UIImage imageNamed:@"icon_navi_nosee"] forState:UIControlStateSelected];
    self.tokenZeroSwitch.onTintColor = [UIColor colorWithHex:0x021933];
    self.tokenZeroSwitch.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [self.tokenZeroLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
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
    self.totalAssetLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"account_asset"];
    self.addAssetLabel.text = [NSString stringWithFormat:@"%@%@",@" + ",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"add_asset"]];
    self.addAssetLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAddAssetLabel)];
    [self.addAssetLabel addGestureRecognizer:labelTapGestureRecognizer];
    self.myAssetLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"my_asset"];
    [self.myAssetLabel sizeToFit];
    self.createLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"create_wallet1"];
    self.importLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"import"];
    self.CNYBalanceLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"toCNY"];
    self.tokenZeroLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"token_zero"];
    [self.tokenZeroLabel sizeToFit];
    self.tokenZeroSwitchConstraint.constant = self.tokenZeroLabel.frame.size.width + self.myAssetLabel.frame.size.width;
}

- (IBAction)tapSeeButton:(id)sender {
    self.assetSeeButton.selected = !self.assetSeeButton.selected;
    if(self.assetSeeButton.selected){
        self.totalAssetValueLabel.text = @"****";
        self.totalPointValueLabel.hidden = YES;
        self.CNYBalanceValueLabel.text = @"****";
        self.CNYPointValueLabel.hidden = YES;
    } else {
        self.totalAssetValueLabel.text = _totalValue;
        self.totalPointValueLabel.hidden = NO;
        self.CNYBalanceValueLabel.text = _totalValue;
        self.CNYPointValueLabel.hidden = NO;
    }
    [self.table reloadData];
    [self refreshConstraint];
}

- (IBAction)tapZeroSwitch:(id)sender {
    _valueHidden = !_tokenZeroSwitch.on;
    [self.table reloadData];
}


- (void)tapAddAssetLabel{
    AssetTokensViewController *vc = [[AssetTokensViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)registerCells {
    [self.table registerNib:[UINib nibWithNibName:@"AssetTableViewCell" bundle:nil] forCellReuseIdentifier:AssetTableViewCellID];
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
}

- (void)viewDidReceiveLocalizedNotification {
    [super viewDidReceiveLocalizedNotification];
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
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - Private

- (void) loadCurrentWallet {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
    _tokenCells = [[NSMutableArray alloc]init];
    _currentWallet.viewTokens = @"CNY,VCC,JSLASH,GK1,GK2,09ajoaf,joafa";
    NSArray *arr = [_currentWallet.viewTokens componentsSeparatedByString:@","];
    for (NSString *token in arr) {
        TokenCellModel *model = [TokenCellModel new];
        [model setName:token];
        [_tokenCells addObject:model];
    }
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

- (void)loadBalance {
    __weak typeof (self) weakSelf = self;
    _cellHidden = NO;
    [_hiddenCells removeAllObjects];
    [self loadCurrentWallet];
    if (weakSelf.currentWallet) {
        [walletManage requestBalanceByAddress:@"jfdLqEWhfYje92gEaWixVWsYKjK5C6bMoi"];
        [weakSelf.collectionView.mj_header endRefreshing];
    }
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
    walletManage = [[WalletManage alloc]init];
    [walletManage createRemote];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWallet:) name:kChangeWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteWallet:) name:kDeleteWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWallet:) name:kCreateWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editWallet:) name:kEditWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceListAction:) name:getBalanceList object:nil];
}

-(void) getAccountInfo:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the info from server is: %@", message);
    NSDictionary *accountData = [notification.object objectForKey:@"account_data"];
    AccountInfoModal *model = [AccountInfoModal mj_objectWithKeyValues:accountData];
    if([model.Balance integerValue] > 0){
        NSArray *array = [model.Balance componentsSeparatedByString:@"."];
        self.totalAssetValueLabel.text = array[0];
        self.totalPointValueLabel.text = [NSString stringWithFormat:@".%@",array[1]];
        self.totalValue = array[0];
        [self refreshConstraint];
    }
}

-(void) getBalanceListAction:(NSNotification *) notification {
    NSString * message = notification.object;
    NSLog(@"the info from server is: %@", message);
    NSMutableArray<NSMutableDictionary *> *data = notification.object;
    @try {
        for (int i = 0; i < data.count; i++) {
            for (int j = 0;j < _tokenCells.count; j++) {
                if([[data[i] valueForKey:@"currency"] isEqualToString:_tokenCells[j].name]){
                    [_tokenCells[j] setBalance:[data[i] valueForKey:@"balance"]];
                    [_tokenCells[j] setFreezeValue:[data[i] valueForKey:@"limit"]];
                }else {
                    [_tokenCells[j] setBalance:@"0.00"];
                    [_tokenCells[j] setFreezeValue:@"0.00"];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    [self.table reloadData];
}

//刷新小数点标签距离
-(void) refreshConstraint {
    [self.totalAssetValueLabel sizeToFit];
    [self.CNYBalanceValueLabel sizeToFit];
    self.totalPointConstraint.constant = self.totalAssetValueLabel.frame.size.width + 20;
    self.CNYPointConstraint.constant =self.CNYBalanceValueLabel.frame.size.width + 20;
}

- (void)changeWallet:(NSNotification *)noti {
    [self loadCurrentWallet];
}

- (void)deleteWallet:(NSNotification *)noti {
    [self loadCurrentWallet];
}

- (void)addWallet:(NSNotification *)noti {
    [self loadCurrentWallet];
}

- (void)editWallet:(NSNotification *)noti {
    [self loadCurrentWallet];
}

- (void)setupSubviews {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView.backgroundColor = [UIColor colorWithHex:0xffffff];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-83);
        make.right.equalTo(self.view).offset(-19);
        make.left.equalTo(self.view).offset(19);
    }];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"id"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    __weak typeof(self) weakSelf = self;
    MJRefreshGifHeader *header = [self colorfulTableHeaderWithBigSize:YES RefreshingBlock:^{
        [weakSelf loadBalance];
    }];
    self.collectionView.mj_header = header;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_tokenCells&&_tokenCells.count >0){
        return _tokenCells.count;
    }else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"hide"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        _cellHidden = YES;
        if (!_hiddenCells) {
            _hiddenCells = [[NSMutableArray alloc]init];
        }
        [_hiddenCells addObject:[NSNumber numberWithInteger:indexPath.row]];
        [self.table reloadData];
        
    }];
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"showall"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        _cellHidden = NO;
        [_hiddenCells removeAllObjects];
        [self.table reloadData];
    }];
    return _cellHidden?@[action1, action0]:@[action0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_hiddenCells &&[_hiddenCells containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        return 0;
    }else {
        return 86;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetTableViewCell *cell = (AssetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AssetTableViewCellID forIndexPath:indexPath];
    if(_tokenCells&&_tokenCells.count >0){
        TokenCellModel *cellModel = _tokenCells[indexPath.row];
        NSString *balanceLable = @"";
        NSString *cny = @"";
        if(self.assetSeeButton.selected){
            balanceLable = [NSString stringWithFormat:@"%@%@%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"available"],@"***",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"frozen"],@"***"];
            cny = @"***";
        }else {
            balanceLable = [NSString stringWithFormat:@"%@%@%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"available"],cellModel.balance,[[TPOSLocalizedHelper standardHelper]stringWithKey:@"frozen"],cellModel.freezeValue];
            cny = @"0.0";
        }
        [cell updateWithModel:cellModel.name :balanceLable :cny];
//        if(!(cellModel.balance.floatValue != 0)){
//            cell.hidden = _valueHidden;
//        }
        if (_hiddenCells &&[_hiddenCells containsObject:[NSNumber numberWithInteger:indexPath.row]]){
            cell.hidden = YES;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushToTransaction];
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

#pragma mark - TPOSAssetHeaderDelegate

- (void)TPOSAssetHeaderDidTapTransactionButton {
    [self pushToTransaction];
}

- (void)TPOSAssetHeaderDidTapReceiverButton {
    [self showQRCodeReceiver];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.collectionView.contentOffset.y >= self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
        self.collectionView.contentOffset = CGPointMake(0, 0);
    }
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
    _table.tableHeaderView = [UIView new];
    _table.tableFooterView = [UIView new];
    _table.backgroundColor = [UIColor colorWithHex:0xffffff];
    _table.separatorColor = [UIColor colorWithHex:0xF5F5F9];
    _table.showsVerticalScrollIndicator = NO;
    _table.delegate = self;
    _table.dataSource = self;
    if (@available(iOS 11,*)) {
        _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _table;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"id" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHex:0xffffff];
    [cell addSubview:self.labelView];
    [self.labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(cell);
    }];
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor colorWithHex:0xffffff];
        [headerView addSubview:self.header];
        [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.left.equalTo(headerView);
        }];
        return headerView;
    }else if(kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor colorWithHex:0xffffff];
        [footerView addSubview:self.table];
        [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.left.equalTo(footerView);
        }];
        return footerView;
    }
    return nil;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.collectionView.frame.size.width, 30);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.collectionView.frame.size.width, 212);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height - 212 - 33);
}

@end
