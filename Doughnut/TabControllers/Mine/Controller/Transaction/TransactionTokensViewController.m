//
//  TransactionTokensViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/11.
//  Copyright © 2019 jch. All rights reserved.
//

#import "WalletManage.h"
#import "CaclUtil.h"
#import "NSString+TPOS.h"
#import "TPOSMacro.h"
#import "AssetTokensViewController.h"
#import "UIColor+Hex.h"
#import "AssetTableViewCell.h"
#import "TokenCellModel.h"
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import <Masonry/Masonry.h>
#import "TPOSContext.h"
#import "TransactionViewController.h"
#import "TransactionTokensViewController.h"

static NSString * const cellID = @"AssetTableViewCell";

@interface TransactionTokensViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tokensTable;

@property (nonatomic, assign) BOOL searchFlag;
@property (nonatomic, strong) NSMutableArray<TokenCellModel *> *tokenArray;
@property (nonatomic, strong) TokenCellModel *selectedToken;
@property (nonatomic, strong) NSNumber *selected;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *zeroArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *hiddenArray;

@property (nonatomic, strong) TPOSWalletDao *walletDao;
@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@property (nonatomic, strong) WalletManage *walletManage;
@property (nonatomic, strong) CaclUtil *caclUtil;
@end

@implementation TransactionTokensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchFlag = NO;
    self.definesPresentationContext = YES;
    [self loadCurrentWallet];
    [self setupSubviews];
    [self registerCells];
    [self registerNotifications];
}

- (void) loadCurrentWallet {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
}

- (TPOSWalletDao *)walletDao {
    if (!_walletDao) {
        _walletDao = [TPOSWalletDao new];
    }
    return _walletDao;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xffffff]];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"select_token"];
    self.navigationController.navigationBarHidden = NO;
}

-(void)reloadTable {
    [self.tokensTable reloadData];
}

-(void)registerNotifications {
    _walletManage = [[WalletManage alloc]init];
    _caclUtil = [[CaclUtil alloc]init];
    if (!_tokenArray) {
        _tokenArray = [NSMutableArray new];
    }
    [_walletManage createRemote];
    [_walletManage requestBalanceByAddress:@"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceListAction:) name:@"jBvrdYc6G437hipoCiEpTwrWSRBS2ahXN6" object:nil];
}

-(void) getBalanceListAction:(NSNotification *) notification {
    NSMutableArray<NSMutableDictionary *> *data = notification.object;
    [_tokenArray removeAllObjects];
    @try {
        for (int n = 0; n < data.count; n++) {
            TokenCellModel *model = [TokenCellModel new];
            [model setName:[data[n] valueForKey:@"currency"]];
            [model setBalance:[data[n] valueForKey:@"balance"]];
            [model setFreezeValue:[data[n] valueForKey:@"limit"]];
            [model setIssuer:[data[n] valueForKey:@"account"]];
            [_tokenArray addObject:model];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    NSSortDescriptor *balanceSD = [NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:NO];
    NSSortDescriptor *freezeSD = [NSSortDescriptor sortDescriptorWithKey:@"freezeValue" ascending:NO];
    NSSortDescriptor *nameSD = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *temp = [_tokenArray copy];
    temp = [temp sortedArrayUsingDescriptors:@[balanceSD,freezeSD,nameSD]];
    [_tokenArray removeAllObjects];
    [_tokenArray addObjectsFromArray:temp];
    [_walletManage getAllTokenPrice:^(NSArray *priceData) {
        NSString *swtPrice = @"0.00";
        if(priceData.count != 0){
            NSArray<NSString *> *arr = [priceData valueForKey:@"SWT-CNY"];
            swtPrice = arr[1];
            for (int i=0;i<_tokenArray.count;i++){
                TokenCellModel *cell = _tokenArray[i];
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
                    [_tokenArray[i] setCnyValue:@"0.00"];
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
                NSString *value = [_caclUtil mul:sum :price :2];
                if ([_caclUtil compare:value :@"0" ] == NSOrderedSame){
                    [_tokenArray[i] setCnyValue:@"0.00"];
                }else {
                    [_tokenArray[i] setCnyValue:value];
                }
            }
        }
        [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:nil];
     } failure:^(NSError *error) {
         NSLog(@"%@", error);
     }];
}

- (void)setupSubviews {
    [self.view addSubview:self.searchBar];
    [self modifyStyleByTraversal];
    [self.view addSubview:self.tokensTable];
    [self.tokensTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-19);
        make.left.equalTo(self.view).offset(19);
    }];
}

- (void)registerCells {
    [self.tokensTable registerNib:[UINib nibWithNibName:@"AssetTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    [self.tokensTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_tokenArray){
        return _tokenArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_hiddenArray &&[_hiddenArray containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        return 0;
    }else if(_zeroArray &&[_zeroArray containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        return 0;
    }else{
        return 86;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetTableViewCell *cell = (AssetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSString *name = @"";
    NSString *issuer = @"";
    if(_tokenArray&&_tokenArray.count >0){
        TokenCellModel *cellModel = _tokenArray[indexPath.row];
        if ([_caclUtil compare:cellModel.balance :@"0" ]== NSOrderedSame||[cellModel.balance tb_isEmpty] ) {
            [cellModel setBalance:@"0.00"];
            cell.hidden = YES;
            _zeroArray = [NSMutableArray new];
            [_zeroArray addObject:[NSNumber numberWithInteger:indexPath.row]];
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
        if ([cellModel.name isEqualToString:@"CNY"] && [cellModel.issuer isEqualToString:@"jGa9J9TkqtBcUoHe2zqhVFFbgUVED6o9or"]){
            name = @"CNT";
        }else {
            name = cellModel.name;
        }
        issuer = cellModel.issuer;
    }
    NSString *balanceLable = [NSString stringWithFormat:@"%@%@%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"available"],_tokenArray[indexPath.row].balance,[[TPOSLocalizedHelper standardHelper]stringWithKey:@"frozen"],_tokenArray[indexPath.row].freezeValue];
    NSString *cny = _tokenArray[indexPath.row].cnyValue;
    [cell updateWithModel:name :balanceLable :cny :[NSString stringWithFormat:@"%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"issuer"],_tokenArray[indexPath.row].issuer]];
    if(_hiddenArray && [_hiddenArray containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        cell.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter]postNotificationName:getChangeToken object: _tokenArray[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UITableView *)tokensTable {
    _tokensTable.tableHeaderView = [UIView new];
    _tokensTable.tableFooterView = [UIView new];
    _tokensTable.backgroundColor = [UIColor colorWithHex:0xffffff];
    _tokensTable.separatorColor = [UIColor colorWithHex:0xF5F5F9];
    _tokensTable.showsVerticalScrollIndicator = NO;
    _tokensTable.delegate = self;
    _tokensTable.dataSource = self;
    if (@available(iOS 11,*)) {
        _tokensTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _tokensTable;
}

- (UISearchBar *)searchBar {
    _searchBar.delegate = self;
    [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [_searchBar setPositionAdjustment:UIOffsetMake(10, 0) forSearchBarIcon:UISearchBarIconSearch];
    return _searchBar;
}

-(BOOL)matchNumbers:(NSString *)str{
    //判断是否以数字开头
    NSString *subStr = [str substringWithRange:NSMakeRange(0, 1)];
    NSString *numbers = @"0123456789";
    return [numbers containsString:subStr];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length == 0){
        _searchFlag = NO;
        _hiddenArray = [NSMutableArray new];
        [self.tokensTable reloadData];
        return;
    }
    _searchFlag = YES;
    _hiddenArray = [NSMutableArray new];
    for (int i = 0;i <_tokenArray.count; i++) {
        if(![_tokenArray[i].name containsString:searchText]){
            [_hiddenArray addObject:[NSNumber numberWithInt:i] ];
        }
    }
    [self.tokensTable reloadData];
    [self.tokensTable layoutIfNeeded];
}

- (void)modifyStyleByTraversal {
    for (UIView *view in self.searchBar.subviews.lastObject.subviews) {
        if([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            UITextField *textField = (UITextField *)view;
            textField.clipsToBounds = YES;
            textField.center = CGPointMake(self.searchBar.center.x, 0);
            textField.layer.cornerRadius = 20;
            textField.textColor = [UIColor colorWithHex:0xA6A9AD];
            textField.placeholder = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"search_tokens"];
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = self.tokensTable.contentOffset;
    if (offset.y <= 0) {
        offset.y = 0;
    }
    self.tokensTable.contentOffset = offset;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
