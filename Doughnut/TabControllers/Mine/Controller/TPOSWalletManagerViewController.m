//
//  TPOSWalletManagerViewController.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/8.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSWalletManagerViewController.h"
#import "ImportWalletViewController.h"
#import "TPOSWalletManagerCell.h"
#import "UIColor+Hex.h"
#import "TPOSEditWalletViewController.h"
#import "TPOSWalletDao.h"
#import "TPOSWalletModel.h"
#import "TPOSMacro.h"
#import "TPOSContext.h"
#import "TPOSNavigationController.h"
#import "TPOSAssetViewController.h"
#import "CreateWalletViewController.h"

@interface TPOSWalletManagerViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray<TPOSWalletModel *> *dataList;
@property (nonatomic, strong) TPOSWalletDao *walletDao;

//
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *importButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightCons;
@end

@implementation TPOSWalletManagerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"wallet_manage"];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
    [self registerNotifications];
    [self loadWallets];
}

- (void)changeLanguage {
    [self.createButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"create_wallet"] forState:UIControlStateNormal];
    [self.importButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"import_wallet"] forState:UIControlStateNormal];
}

#pragma mark - private method

- (void)registerCell {
    [self.tableView registerNib:[UINib nibWithNibName:@"TPOSWalletManagerCell" bundle:nil] forCellReuseIdentifier:@"TPOSWalletManagerCell"];
}

- (void)setupTableView {
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = 5;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [UIView new];
    [self registerCell];
}

- (void)loadWallets {
    __weak typeof(self) weakSelf = self;
    [self.walletDao findAllWithComplement:^(NSArray<TPOSWalletModel *> *walletModels) {
        weakSelf.dataList = walletModels;
        [weakSelf.tableView reloadData];
    }];
}

- (IBAction)createWallet {
    CreateWalletViewController *createWalletViewController = [[CreateWalletViewController alloc] init];
    [self presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:createWalletViewController] animated:YES completion:nil];
}

- (IBAction)importWallet {
    ImportWalletViewController *vc = [[ImportWalletViewController alloc] init];
    [self presentViewController:[[TPOSNavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

#pragma mark NSNotification
- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWallet:) name:kCreateWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteWallet:) name:kDeleteWalletNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editWallet:) name:kEditWalletNotification object:nil];
}

- (void)addWallet:(NSNotification *)note {
    if ([note.object isKindOfClass:TPOSWalletModel.class]) {
        [self loadWallets];
    }
}

- (void)deleteWallet:(NSNotification *)note {
    if ([note.object isKindOfClass:TPOSWalletModel.class]) {
        [self loadWallets];
    }
}

- (void)editWallet:(NSNotification *)note {
    if ([note.object isKindOfClass:TPOSWalletModel.class]) {
        [self loadWallets];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const mineCellId = @"TPOSWalletManagerCell";
    TPOSWalletManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:mineCellId forIndexPath:indexPath];
    [cell updateWithModel:_dataList[indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_flag){
        TPOSWalletModel *model = _dataList[indexPath.section];
        [self.walletDao updateCurrentWalletID:model.walletId complement:nil];
        [[TPOSContext shareInstance] setCurrentWallet:model];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
    TPOSEditWalletViewController *editWalletViewController = [[TPOSEditWalletViewController alloc] init];
    editWalletViewController.currentWallet = _dataList[indexPath.section];
    TPOSWalletManagerCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    editWalletViewController.currentWallet.balanceSWTC = cell.walletBalanceLabel.text;
    editWalletViewController.currentWallet.balanceCNY = [cell.balanceCNYLabel.text stringByReplacingOccurrencesOfString:@"≈￥" withString:@""];
    [self.navigationController pushViewController:editWalletViewController animated:YES];
    }
    _flag = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 8 : 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115;
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

@end
