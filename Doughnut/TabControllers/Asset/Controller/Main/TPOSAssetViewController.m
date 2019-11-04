//
//  TPOSAssetViewController.m
//  TokenBank
//
//  Created by MarcusWoo on 07/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import "TPOSAssetViewController.h"
#import "NSString+TPOS.h"
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
#import "CaclUtil.h"
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

@property (nonatomic, strong) NSMutableArray<NSNumber *> *zeroCells;

@property (nonatomic, weak) TPOSAssetChooseWalletView *assetChooseWalletView;

@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@property (nonatomic, assign) BOOL cellHidden;

@property (nonatomic, assign) BOOL valueHidden;

@property (nonatomic, strong) TPOSWalletDao *walletDao;

@property (nonatomic, strong) NSString *totalValue;

@property (nonatomic, strong) NSString *cnyValue;

@property (nonatomic, strong) CaclUtil *caclUtil;

@end

@implementation TPOSAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
    self.bottomConstraint.constant = kIphoneX?83:49;
    self.cellHidden = NO;
    self.valueHidden = YES;
    _caclUtil = [[CaclUtil alloc]init];
    _tokenCells = [NSMutableArray new];
    _hiddenCells = [NSMutableArray new];
    _zeroCells = [NSMutableArray new];
    [self loadCurrentWallet];
    [self registerCells];
    [self checkBackup];
    [self registerNotifications];
    [self setupSubviews];
    [self loadBalance];
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

-(void)viewWillDisappear:(BOOL)animated {
}

-(void) TapWalletName {
    TPOSWalletManagerViewController *walletManagerViewController = [[TPOSWalletManagerViewController alloc] init];
    walletManagerViewController.flag = YES;
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
        self.totalAssetValueLabel.text = _totalValue?_totalValue:@"0";
        self.totalPointValueLabel.hidden = NO;
        self.CNYBalanceValueLabel.text = _cnyValue?_cnyValue:@"0";
        self.CNYPointValueLabel.hidden = NO;
    }
    [self.table reloadData];
    [self refreshConstraint];
}

- (IBAction)tapZeroSwitch:(id)sender {
    _valueHidden = !_tokenZeroSwitch.on;
    if (_valueHidden){
        [_zeroCells removeAllObjects];
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public
- (void)autoRefreshData {
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - Private

- (void) loadCurrentWallet {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
    [self loadBalance];
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
    if (weakSelf.currentWallet) {
        [walletManage requestBalanceByAddress:@"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6"];
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

-(void) getBalanceListAction:(NSNotification *) notification {
    __weak typeof(self) weakSelf = self;
    NSString * message = notification.object;
    NSLog(@"the info from server is: %@", message);
    NSMutableArray<NSMutableDictionary *> *data = notification.object;
    [_tokenCells removeAllObjects];
    NSArray *arr = [_currentWallet.viewTokens componentsSeparatedByString:@","];
    NSMutableArray<NSString *> *arr2 = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < data.count; i++) {
        NSString *currency = [data[i] valueForKey:@"currency"];
        [arr2 addObject:currency];
    }
    @try {
        for (int n = 0; n < data.count; n++) {
            TokenCellModel *model = [TokenCellModel new];
            [model setName:[data[n] valueForKey:@"currency"]];
            [model setBalance:[data[n] valueForKey:@"balance"]];
            [model setFreezeValue:[data[n] valueForKey:@"limit"]];
            [model setIssuer:[data[n] valueForKey:@"account"]];
            [_tokenCells addObject:model];
        }
        for (int j = 0; j< arr.count; j++){
            if(![arr2 containsObject:[arr[j] componentsSeparatedByString:@"_"][0]]) {
                TokenCellModel *model = [TokenCellModel new];
                [model setName:[arr[j] componentsSeparatedByString:@"_"][0]];
                [model setBalance:@"0.00"];
                [model setFreezeValue:@"0.00"];
                [model setIssuer:[arr[j] componentsSeparatedByString:@"_"][1]];
                [_tokenCells addObject:model];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    NSSortDescriptor *balanceSD = [NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:NO];
    NSSortDescriptor *freezeSD = [NSSortDescriptor sortDescriptorWithKey:@"freezeValue" ascending:NO];
    NSSortDescriptor *nameSD = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *temp = [_tokenCells copy];
    temp = [temp sortedArrayUsingDescriptors:@[balanceSD,freezeSD,nameSD]];
    [_tokenCells removeAllObjects];
    [_tokenCells addObjectsFromArray:temp];
    [walletManage getAllTokenPrice:^(NSArray *priceData) {
        // 钱包总价值
        NSString *values = @"0.00";
        // 钱包折换总SWT
        NSString *number = @"0.00";
        NSString *swtPrice = @"0.00";
        if(priceData.count != 0){
            NSArray<NSString *> *arr = [priceData valueForKey:@"SWT-CNY"];
            swtPrice = arr[1];
            for (int i=0;i<_tokenCells.count;i++){
                TokenCellModel *cell = _tokenCells[i];
                NSString *balance = cell.balance;
                if([balance tb_isEmpty]){
                    balance = @"0";
                }
                NSString *currency = cell.name;
                NSString *freeze = cell.freezeValue;
                if([freeze tb_isEmpty]){
                    freeze = @"0";
                }
                NSString *sum = [_caclUtil add:balance :freeze];
                if ([_caclUtil compare:sum :@"0"]==NSOrderedSame){
                    [_tokenCells[i] setCnyValue:@"0.00"];
                    continue;
                }
                NSString *price = @"0";
                if ([currency isEqualToString:CURRENCY_CNY]) {
                    price = @"1";
                } else if([currency isEqualToString:CURRENCY_SWTC]) {
                    price = swtPrice;
                }else{
                    NSString *currency_cny = [NSString stringWithFormat:@"%@%@",currency,@"-CNY"];
                    NSArray<NSString *> *currencyLst = [priceData valueForKey:currency_cny];
                    if (currencyLst != nil) {
                        price = currencyLst[1]?currencyLst[1]:@"0";
                    }
                }
                NSString *value = [_caclUtil mul:sum :price];
                if ([_caclUtil compare:value :@"0" ] == NSOrderedSame){
                    [_tokenCells[i] setCnyValue:@"0.00"];
                }else {
                    [_tokenCells[i] setCnyValue:value];
                }
                values = [_caclUtil add:value :values];
            }
            
            number = [_caclUtil div:values :swtPrice :2];
            [self.totalAssetLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@≈￥%@)",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"account_asset"],[_caclUtil formatAmount:swtPrice :5:NO:YES]] waitUntilDone:YES];
            NSString *valuesF = [_caclUtil formatAmount:values :2:YES:NO];
            if ([valuesF containsString:@"."]){
                NSArray<NSString *> *arrs = [valuesF componentsSeparatedByString:@"."];
                self.cnyValue = arrs[0];
                [self.CNYBalanceValueLabel performSelectorOnMainThread:@selector(setText:) withObject:arrs[0] waitUntilDone:YES];
                if (![arr[1] tb_isEmpty]) {
                    [self.CNYPointValueLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@".%@",arrs[1]] waitUntilDone:YES];
                }
            }else {
                self.cnyValue = valuesF;
                [self.CNYBalanceValueLabel performSelectorOnMainThread:@selector(setText:) withObject:valuesF waitUntilDone:YES];
                [self.CNYPointValueLabel performSelectorOnMainThread:@selector(setText:) withObject:@".00" waitUntilDone:YES];
            }
            NSString *valuesE = [_caclUtil formatAmount:number :2:YES:NO];
            if ([number containsString:@"."]) {
                NSArray<NSString *> *arrss = [valuesE componentsSeparatedByString:@"."];
                self.totalValue = arrss[0];
                [self.totalAssetValueLabel performSelectorOnMainThread:@selector(setText:) withObject:arrss[0] waitUntilDone:YES];
                if (![arrss[1] tb_isEmpty]) {
                    [self.totalPointValueLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@".%@",arrss[1]] waitUntilDone:YES];
                }
            } else {
                self.totalValue = valuesE;
                [self.totalAssetValueLabel performSelectorOnMainThread:@selector(setText:) withObject:valuesE waitUntilDone:YES];
                [self.totalPointValueLabel performSelectorOnMainThread:@selector(setText:) withObject:@".00" waitUntilDone:YES];
            }
        }
        else{
            self.cnyValue = @"---";
            [self.CNYBalanceValueLabel performSelectorOnMainThread:@selector(setText:) withObject:@"---" waitUntilDone:YES];
            [self.CNYPointValueLabel performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:YES];
            self.totalValue = @"---";
            [self.totalAssetValueLabel performSelectorOnMainThread:@selector(setText:) withObject:@"---" waitUntilDone:YES];
            [self.totalPointValueLabel performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:YES];
        }
        [self performSelectorOnMainThread:@selector(updateLayout) withObject:nil waitUntilDone:YES];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    [weakSelf.collectionView.mj_header endRefreshing];
}

//刷新小数点标签距离
-(void) refreshConstraint {
    [self.totalAssetLabel sizeToFit];
    [self.totalAssetLabel layoutIfNeeded];
    [self.totalAssetValueLabel sizeToFit];
    [self.totalAssetValueLabel layoutIfNeeded];
    [self.CNYBalanceValueLabel sizeToFit];
    [self.CNYBalanceValueLabel layoutIfNeeded];
    self.totalPointConstraint.constant = self.totalAssetValueLabel.frame.size.width + 20;
    self.CNYPointConstraint.constant =self.CNYBalanceValueLabel.frame.size.width + 20;
}

-(void) updateLayout {
    [self refreshConstraint];
    [self.table reloadData];
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
    __weak typeof(self) weakSelf = self;
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
    MJRefreshGifHeader *header = [self colorfulTableHeaderWithBigSize:YES RefreshingBlock:^{
        [weakSelf loadBalance];
    }];
    self.collectionView.mj_header = header;
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
    action0.backgroundColor = [UIColor colorWithHex:0xCD5C5C];
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"showall"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        _cellHidden = NO;
        [_hiddenCells removeAllObjects];
        [self.table reloadData];
    }];
    action1.backgroundColor = [UIColor colorWithHex:0x3CB371];
    return _cellHidden?@[action0, action1]:@[action0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_hiddenCells &&[_hiddenCells containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        return 0;
    }else if(_zeroCells &&[_zeroCells containsObject:[NSNumber numberWithInteger:indexPath.row]]&&_valueHidden){
        return 0;
    }else{
        return 86;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetTableViewCell *cell = (AssetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AssetTableViewCellID forIndexPath:indexPath];
    if(_tokenCells&&_tokenCells.count >0){
        TokenCellModel *cellModel = _tokenCells[indexPath.row];
        NSString *balanceLable = @"";
        NSString *cny = @"";
        NSString *name = @"";
        if ([_caclUtil compare:cellModel.balance :@"0" ]== NSOrderedSame||[cellModel.balance tb_isEmpty] ) {
            [cellModel setBalance:@"0.00"];
        }else {
            [cellModel setBalance:[_caclUtil formatAmount:cellModel.balance:4:NO:NO]];
        }
        if ([_caclUtil compare:cellModel.freezeValue :@"0" ] == NSOrderedSame||[cellModel.freezeValue tb_isEmpty]) {
            [cellModel setFreezeValue:@"0.00"];
        }else {
            [cellModel setFreezeValue:[_caclUtil formatAmount:cellModel.freezeValue:4:NO:NO]];
        }
        if ([_caclUtil compare:cellModel.cnyValue :@"0" ] == NSOrderedSame||[cellModel.cnyValue tb_isEmpty]) {
            [cellModel setCnyValue:@"0.00"];
        }else {
            [cellModel setCnyValue:[_caclUtil formatAmount:cellModel.cnyValue :2 :NO :NO ]];
        }
        if(self.assetSeeButton.selected){
            balanceLable = [NSString stringWithFormat:@"%@%@%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"available"],@"***",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"frozen"],@"****"];
            cny = @"****";
        }else {
            balanceLable = [NSString stringWithFormat:@"%@%@%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"available"],cellModel.balance,[[TPOSLocalizedHelper standardHelper]stringWithKey:@"frozen"],cellModel.freezeValue];
            cny = cellModel.cnyValue;
        }
        if ([cellModel.name isEqualToString:@"CNY"]&&[cellModel.issuer isEqualToString:@"jGa9J9TkqtBcUoHe2zqhVFFbgUVED6o9or"]){
            name = @"CNT";
        }else {
            name = cellModel.name;
        }
        [cell updateWithModel:name :balanceLable :cny :[NSString stringWithFormat:@"%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"issuer"],cellModel.issuer]];
        if([_caclUtil compare:cellModel.balance :@"0" ] == NSOrderedSame){
            cell.hidden = _valueHidden;
            if (!_zeroCells) {
                _zeroCells = [[NSMutableArray alloc]init];
            }
            [_zeroCells addObject:[NSNumber numberWithInteger:indexPath.row]];
        }
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
