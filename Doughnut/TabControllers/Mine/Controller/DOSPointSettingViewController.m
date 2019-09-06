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
#import <Masonry/Masonry.h>;
#import "TPOSMacro.h"


@interface DOSPointSettingViewController ()
    <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIButton *addCustomNodeButton;

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
}

- (void)setupTableView {
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 47)];
    [footer addSubview:_addCustomNodeButton];
    [_addCustomNodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(footer).insets(UIEdgeInsetsMake(0, 15, 0, 15));
    }];
    self.tableView.tableFooterView = footer;
    [self registerCell];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const mineCellId = @"DOSJTNodesViewCell";
    DOSJTNodesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mineCellId forIndexPath:indexPath];
    //[cell updateWithModel:_dataList[indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 8 : 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
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
    }
    return _addCustomNodeButton;
}

@end
