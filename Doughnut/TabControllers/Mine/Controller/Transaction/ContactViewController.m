//
//  ContactViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/20.
//  Copyright © 2019 jch. All rights reserved.
//

#import "ContactViewController.h"
#import "TPOSWalletModel.h"
#import "TPOSContext.h"
#import "TPOSMacro.h"
#import "ContactTableViewCell.h"

@interface ContactViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *emptyBg;

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *datalist;
@property (nonatomic, strong) TPOSWalletModel *currentWallet;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"concacts"];
    [self loadData];
    [self setupView];
}

-(void)loadData {
    self.currentWallet = [[TPOSContext shareInstance]currentWallet];
    _datalist = [NSMutableArray new];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [_datalist addObjectsFromArray:[defaults objectForKey:@"transactionContacts"]];
    self.emptyBg.hidden = YES;
    [self.table reloadData];
}

-(void)setupView {
    [self registerCell];
}

- (void)registerCell {
    [self.table registerNib:[UINib nibWithNibName:@"ContactTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactTableViewCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datalist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    [cell updateWithData:_datalist[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter]postNotificationName:getTransactionAddress object: _datalist[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

#pragma mark - Getter & Setter
- (UITableView *)table{
    _table.tableFooterView = [UIView new];
    _table.backgroundColor = [UIColor clearColor];
    _table.showsVerticalScrollIndicator = NO;
    _table.bounces = NO;
    _table.delegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSelectionStyleDefault;
    if (@available(iOS 11,*)) {
        _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _table;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:_datalist forKey:@"transactionContacts"];
    [defaults synchronize];
}

@end
