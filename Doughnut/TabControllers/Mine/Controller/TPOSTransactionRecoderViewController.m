//
//  TPOSTransactionRecoderViewController.m
//  TokenBank
//
//  Created by xiaoyuan on 2018/1/9.
//  Copyright © 2018年 MarcusWoo. All rights reserved.
//

#import "TPOSTransactionRecoderViewController.h"
#import "UIColor+Hex.h"
#import "TPOSTransactionRecoderCell.h"
#import "TPOSExchangeWalletVewController.h"
#import "TPOSNavigationController.h"
#import "TPOSTransactionRecoderModel.h"
#import "TPOSContext.h"
#import "TPOSWalletModel.h"
#import "TPOSMacro.h"
#import "TPOSJTManager.h"
#import "TPOSJTPaymentInfo.h"
#import "TransactionDetailViewController.h"

#import <Masonry/Masonry.h>;
#import <Toast/Toast.h>;

@interface TPOSTransactionRecoderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) int currentPage;

@property (nonatomic, strong) TPOSWalletModel *currentWalletModel;

@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, assign) NSInteger ledger;



@end

@implementation TPOSTransactionRecoderViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initCurrentWallet];
    [self setupSubviews];
    [self setupConstraints];
    [self registerCell];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - private method

- (void)_initCurrentWallet {
    _currentWalletModel = [TPOSContext shareInstance].currentWallet;
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [[WalletManage shareInstance] getTransactionHistory:@"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6" page:_currentPage :^(NSDictionary *response) {
        NSArray *list = [NSMutableArray array];
        if (![[[response valueForKey:@"count"] stringValue] isEqualToString:@"0"]){
            list = [response valueForKey:@"list"];
        }
        if (_currentPage == 0) {
            [weakSelf.dataList removeAllObjects];
        }
        if (list.count < 10) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        NSSortDescriptor *seqSD = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
        list = [list sortedArrayUsingDescriptors:@[seqSD]];
        [weakSelf.dataList addObjectsFromArray:list];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"req_exchange_list_fail"]];
    }];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWallet:) name:kChangeWalletNotification object:nil];
}

- (void)changeWallet:(NSNotification *)note {
    _currentWalletModel = note.object;
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupSubviews {
    self.title = [[TPOSLocalizedHelper standardHelper] stringWithKey:@"trans_record"];
    [self.view addSubview:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    MJRefreshGifHeader *header = [self colorfulTableHeaderWithBigSize:NO RefreshingBlock:^{
        weakSelf.currentPage = 0;
        weakSelf.seq = 0;
        weakSelf.ledger = 0;
        [weakSelf loadData];
    }];
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [TPOSCustomMJRefreshFooter footerWithRefreshingBlock:^{
        weakSelf.currentPage += 1;
        [weakSelf loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.view);
    }];
}

- (void)registerCell {
    [self.tableView registerNib:[UINib nibWithNibName:@"TPOSTransactionRecoderCell" bundle:nil] forCellReuseIdentifier:@"TPOSTransactionRecoderCell"];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const mineCellId = @"TPOSTransactionRecoderCell";
    TPOSTransactionRecoderCell *cell = [tableView dequeueReusableCellWithIdentifier:mineCellId forIndexPath:indexPath];
    [cell updateWithData:_dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TransactionDetailViewController *transactionDetailViewController = [[TransactionDetailViewController alloc] init];
    transactionDetailViewController.currentTransactionHash = [_dataList[indexPath.row] valueForKey:@"hash"];
    transactionDetailViewController.currentWalletAddress = @"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6";
    //_currentWalletModel.address;
    [self.navigationController pushViewController:transactionDetailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorColor = [UIColor colorWithHex:0xe8e8e8];
        
    }
    return _tableView;
}

- (NSMutableArray<TPOSTransactionRecoderModel *> *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
