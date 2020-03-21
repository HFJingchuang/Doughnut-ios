//
//  DOSPointSettingViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/8/13.
//  Copyright © 2019 MarcusWoo. All rights reserved.
//

#import "DOSPointSettingViewController.h"
#import "DOSJTNodesViewCell.h"
#import "UIColor+Hex.h"
#import "Masonry.h"
#import "TPOSMacro.h"
#import "WalletManage.h"
#import "DOSJTNodeDialogView.h"

@interface DOSPointSettingViewController ()
    <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *addCustomNodeButton;

@property (nonatomic, strong) NSArray *publicNodes;
@property (nonatomic, strong) NSMutableArray *customNodes;

@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSString *currentNode;

@end

@implementation DOSPointSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x021E38]}];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"point_settings"];
    self.navigationController.navigationBarHidden = NO;
}

- (void)changeLanguage {
    [self.addCustomNodeButton setTitle:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"add_custom_node"]  forState:UIControlStateNormal];
}

#pragma mark - private method

- (void)registerCell {
    [self.tableView registerNib:[UINib nibWithNibName:@"DOSJTNodesViewCell" bundle:nil] forCellReuseIdentifier:@"DOSJTNodesViewCell"];
}

- (void) setupSubViews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self.view);
        make.right.equalTo(self.view).offset(-19);
        make.left.equalTo(self.view).offset(19);
    }];
    __weak typeof(self) weakSelf = self;
    MJRefreshGifHeader *header = [self colorfulTableHeaderWithBigSize:NO RefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}

-(void)loadData{
    self.publicNodes = [self readLocalFileWithName:@"publicNodes"];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    _customNodes = [NSMutableArray new];
    [_customNodes addObjectsFromArray:[defaults objectForKey:@"customNodes"]];
    _currentNode = [WalletManage shareWalletManage].currentNode;
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

- (void)setupTableView {
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 47)];
    [footer addSubview:_addCustomNodeButton];
    [_addCustomNodeButton addTarget:self action:@selector(addCustomNodes) forControlEvents:UIControlEventTouchUpInside];
    [_addCustomNodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(footer).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.tableView.tableFooterView = footer;
    [self registerCell];
}

- (void)addCustomNodes {
    DOSJTNodeDialogView *view = [DOSJTNodeDialogView DOSJTNodeDialogView];
    view.confirmBack = ^(NSString *nodeAddr){
        if (nodeAddr.length != 0){
            NSString *str = nodeAddr;
            NSMutableDictionary *node = [NSMutableDictionary new];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd HH:mm:ss"];
            [node setValue:[NSString stringWithFormat:@"%@(%@)",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"custom_node"],[formatter stringFromDate:[NSDate date]]] forKey:@"name"];
            [node setValue:str forKey:@"node"];
            [_customNodes addObject:node];
            [self.tableView reloadData];
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:_customNodes forKey:@"customNodes"];
            [defaults synchronize];
        }
    };
    [view showWithAnimate:TPOSAlertViewAnimateCenterPop inView:self.view.window];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"delete"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [_customNodes removeObjectAtIndex:indexPath.row];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView reloadData];
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:_customNodes forKey:@"customNodes"];
            [defaults synchronize];
        }];
        return @[action0];
    }else{
        return @[];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return _publicNodes.count;
    }else {
        return _customNodes.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const mineCellId = @"DOSJTNodesViewCell";
    DOSJTNodesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mineCellId forIndexPath:indexPath];
    if (indexPath.section == 0){
        [cell updateWithData:_publicNodes[indexPath.row]];
    }else{
        [cell updateWithData:_customNodes[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *add;
    if (indexPath.section == 0) {
        add = [_publicNodes[indexPath.row] valueForKey:@"node"];
    }else {
        add = [_customNodes[indexPath.row] valueForKey:@"node"];
    }
    if (![add isEqualToString:[WalletManage shareWalletManage].currentNode]){
        [[WalletManage shareWalletManage]changeNodeAddress:add];
        [self.tableView reloadData];
        [self showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"node_changed"],add]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 47)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0, 100, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    headerLabel.textColor = [UIColor colorWithHex:0xA6A9AD];
    NSIndexPath *indexPath = [[NSIndexPath alloc]initWithIndex:section];
    if (0 == indexPath.section) {
        headerLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"defult_node"];
    }else {
        headerLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"custom_node"];
    }
    [headerLabel sizeToFit];
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;
        //_tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
        if (@available(iOS 11,*)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
    }
    return _tableView;
}

- (UIButton *)addCustomNodeButton {
    if (!_addCustomNodeButton) {
        _addCustomNodeButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        _addCustomNodeButton.layer.cornerRadius = 10;
        _addCustomNodeButton.backgroundColor = [UIColor colorWithHex:0x383B3E];
        _addCustomNodeButton.titleLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"add_custom_node"];
        _addCustomNodeButton.titleLabel.textColor = [UIColor colorWithHex:0xffffff];
        _addCustomNodeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _addCustomNodeButton.userInteractionEnabled = YES;
    }
    return _addCustomNodeButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
