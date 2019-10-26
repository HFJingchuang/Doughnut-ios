//
//  AssetTokensViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/10.
//  Copyright © 2019 jch. All rights reserved.
//

#import "TPOSMacro.h"
#import "AssetTokensViewController.h"
#import "UIColor+Hex.h"
#import "TokenTableViewCell.h"
#import "TokenCellModel.h"
#import "TPOSWalletModel.h"
#import "TPOSWalletDao.h"
#import <Masonry/Masonry.h>
#import "TPOSContext.h"
#import "TPOSAssetViewController.h"

static NSString * const cellID = @"TokenTableViewCell";
@interface AssetTokensViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tokensTable;

@property (nonatomic, assign) BOOL searchFlag;
@property (nonatomic, strong) NSMutableArray<TokenCellModel *> *visibleResults;
@property (nonatomic, strong) NSMutableArray<TokenCellModel *> *tokenArray;
@property (nonatomic, strong) NSMutableArray<TokenCellModel *> *selectedTokensArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedArray;


@property (nonatomic, strong) TPOSWalletDao *walletDao;
@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@end

@implementation AssetTokensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchFlag = NO;
    self.definesPresentationContext = YES;
    walletManage = [[WalletManage alloc]init];
    [self loadCurrentWallet];
    [self setupSubviews];
    [self registerCells];
    [self loadData];
}

- (void) loadCurrentWallet {
    _currentWallet = [TPOSContext shareInstance].currentWallet;
    _selectedTokensArray = [NSMutableArray new];
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
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"add_tokens"];
    self.navigationController.navigationBarHidden = NO;
}

-(void)loadData {
    [walletManage getAllTokens:^(NSDictionary *response) {
        if (response){
            NSMutableArray *data = [NSMutableArray arrayWithObject:response][0];
            if (!_tokenArray) {
                _tokenArray = [NSMutableArray new];
            }
            if (!_visibleResults) {
                _visibleResults = [NSMutableArray new];
            }
            if (data && data.count >0){
                for (int i = 0;i < data.count; i++) {
                    TokenCellModel *model = [TokenCellModel new];
                    NSArray <NSString *> *arr = [data[i] componentsSeparatedByString:@"_"];
                    [model setName:arr[0]];
                    [model setIssuer:arr[1]];
                    [_tokenArray addObject:model];
                }
            }
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            _tokenArray = [_tokenArray sortedArrayUsingDescriptors:@[descriptor]];
            _tokenArray = [_tokenArray sortedArrayUsingComparator:^NSComparisonResult(TokenCellModel* obj1, TokenCellModel *obj2) {
                BOOL b1 = [self matchNumbers:obj1.name];
                BOOL b2 = [self matchNumbers:obj2.name];
                if(b1&&!b2){
                    return NSOrderedDescending;
                }else if(!b1&&b2){
                    return NSOrderedAscending;
                }else{
                    return NSOrderedAscending;
                }
            }];
            [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:nil];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)reloadTable {
    [self.tokensTable reloadData];
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
    [self.tokensTable registerNib:[UINib nibWithNibName:@"TokenTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    [self.tokensTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_tokenArray&&_visibleResults){
        return _searchFlag?_visibleResults.count:_tokenArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TokenTableViewCell *cell = (TokenTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSString *name = @"";
    NSString *issuer = @"";
    if(_searchFlag){
        if(_visibleResults&&_visibleResults.count >0){
            if ([_visibleResults[indexPath.row].name isEqualToString:@"CNY"] && [_visibleResults[indexPath.row].issuer isEqualToString:@"jGa9J9TkqtBcUoHe2zqhVFFbgUVED6o9or"]){
                name = @"CNT";
            }else {
                name = _visibleResults[indexPath.row].name;
            }
            issuer = _visibleResults[indexPath.row].issuer;
        }
    }else{
        if(_tokenArray&&_tokenArray.count >0){
            if ([_tokenArray[indexPath.row].name isEqualToString:@"CNY"] && [_tokenArray[indexPath.row].issuer isEqualToString:@"jGa9J9TkqtBcUoHe2zqhVFFbgUVED6o9or"]){
                name = @"CNT";
            }else {
                name = _tokenArray[indexPath.row].name;
            }
            issuer = _tokenArray[indexPath.row].issuer;
        }
    }
    [cell updateWithModel:name :issuer];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TokenTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(!_selectedArray) {
        _selectedArray = [NSMutableArray new];
    }
    if([_selectedArray containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        [cell setSelectedStatus:NO];
        [_selectedArray removeObject:[NSNumber numberWithInteger:indexPath.row]];
        if(!_searchFlag){
            [_selectedTokensArray removeObject:_tokenArray[indexPath.row]];
        }else {
            [_selectedTokensArray removeObject:_visibleResults[indexPath.row]];
        }
    } else {
        [cell setSelectedStatus:YES];
        [_selectedArray addObject:[NSNumber numberWithInteger:indexPath.row]];
        if(!_searchFlag){
            [_selectedTokensArray addObject:_tokenArray[indexPath.row]];
        }else {
            [_selectedTokensArray addObject:_visibleResults[indexPath.row]];
        }
    }
    
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
    [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
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
        [self.tokensTable reloadData];
        return;
    }
    _searchFlag = YES;
    [_visibleResults removeAllObjects];
    for (int i = 0;i <_tokenArray.count; i++) {
        if([_tokenArray[i].name containsString:searchText]){
            [_visibleResults addObject:_tokenArray[i]];
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
    if(_selectedTokensArray.count >0){
        for(int i=0; i< _selectedTokensArray.count; i++){
            NSString *str = [NSString stringWithFormat:@"%@_%@",_selectedTokensArray[i].name,_selectedTokensArray[i].issuer];
            if (_currentWallet.viewTokens.length ==0 ){
                _currentWallet.viewTokens = str;
            }else{
                NSArray<NSString *> *arr = [_currentWallet.viewTokens componentsSeparatedByString:@","];
                if (![arr containsObject:str]){
                   _currentWallet.viewTokens = [NSString stringWithFormat:@"%@,%@",_currentWallet.viewTokens,str];
                }
            }
        }
    }
    [_walletDao updateWalletWithWalletModel:_currentWallet complement:^(BOOL success) {
        if(success){}
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeWalletNotification object:_currentWallet];
}

@end
