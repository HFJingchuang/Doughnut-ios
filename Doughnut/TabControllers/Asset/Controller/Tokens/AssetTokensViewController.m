//
//  AssetTokensViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/10/10.
//  Copyright © 2019 jch. All rights reserved.
//

#import "AssetTokensViewController.h"
#import "UIColor+Hex.h"
#import "TokenTableViewCell.h"
#import <Masonry/Masonry.h>

static NSString * const cellID = @"TokenTableViewCell";
@interface AssetTokensViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tokensTable;

@property (nonatomic, copy) NSString *filterString;
@property (readwrite, copy) NSArray *visibleResults;
@property (nonatomic, strong) NSMutableArray<NSString *> *tokenArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedArray;

@end

@implementation AssetTokensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.delegate = self;
    self.definesPresentationContext = YES;
    [self setupSubviews];
    [self registerCells];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    UITextField *searchField = [self.searchController.searchBar valueForKey:@"_searchField"];
    searchField.center=self.searchController.searchBar.center;
    self.view.backgroundColor = [UIColor colorWithHex:0xffffff];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"add_tokens"];
    self.navigationController.navigationBarHidden = NO;
}

- (void)changeLanguage {
}

- (void)setupSubviews {
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
    if(_tokenArray&&_tokenArray.count >0){
        return _tokenArray.count;
    }else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TokenTableViewCell *cell = (TokenTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(_tokenArray&&_tokenArray.count >0){
        for (int i = 0;i < _tokenArray.count;i++) {
            [cell updateWithModel:_tokenArray[i]];
        }
    }
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
    } else {
        [cell setSelectedStatus:YES];
        [_selectedArray addObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UITableView *)tokensTable {
    _tokensTable.tableHeaderView = self.searchController.searchBar;
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

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return CGSizeMake(200, 200);
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
}

- (void)setNeedsFocusUpdate {
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return NO;
}

- (void)updateFocusIfNeeded {
}

@end
