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
#import <Masonry/Masonry.h>
#import "TPOSMacro.h"


@interface DOSPointSettingViewController ()
    <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *addCustomNodeButton;

@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) UIView *alertbackView;
@property (nonatomic, strong) UIView *alertContentView;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UILabel *warnLabel;
@property (nonatomic, strong) UITextField *nodeAddr;

@property (nonatomic, strong) NSArray *publicNodes;
@property (nonatomic, strong) NSMutableArray *customNodes;

@property (nonatomic, strong) void (^isClickSure)(BOOL isClick);
@property (nonatomic, strong) void (^isClickCancel)(BOOL isClick);
@property (nonatomic, strong) void (^isClickBg)(BOOL isClick);

@property (nonatomic, strong) NSNumber *index;

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
    [self addCustomAlertView];
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
    _alertbackView.hidden = NO;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"delete"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
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

#pragma mark - 弹出框
-(void)addCustomAlertView{
    CGFloat QCWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat QCHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat offset = 40;//弹出框两边边距
    CGFloat width = QCWidth -offset*2;//弹出框宽
    CGFloat height = 180;//弹出框高
    //实现弹出方法
    _alertWindow = [UIApplication sharedApplication].keyWindow;
    _alertWindow.windowLevel = UIWindowLevelNormal;
    _alertWindow.layer.masksToBounds = YES;
    //背景图
    _alertbackView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, QCWidth, QCHeight+64)];
    _alertbackView.backgroundColor = [[UIColor clearColor]colorWithAlphaComponent:0.3f];
    [_alertWindow addSubview:_alertbackView];
    _alertbackView.hidden = YES;
    //显示弹窗视图
    _alertContentView = [[UIView alloc]initWithFrame:CGRectMake(offset,(QCHeight-height)/2,width,height)];
    _alertContentView.backgroundColor =[UIColor whiteColor];
    _alertContentView.layer.cornerRadius = 8;
    [_alertbackView addSubview:_alertContentView];
    //背景点击移除
//    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap:)];
//    tap.cancelsTouchesInView=NO;//YES，系统会识别手势，并取消触摸事件；为NO的时候，手势识别之后，系统将触发触摸事件。
//    [backview addGestureRecognizer:tap];
//    self.isClickBg = ^(BOOL isClick) {
//        if (isClick) {}
//    };
    //===================自定义部分开始区域，可以在下边加入你想要自定义的内容，视图添加到view上=
    UILabel *egLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, width, 13)];
    [_alertContentView addSubview:egLabel];
    egLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    egLabel.textColor = [UIColor colorWithHex:0x021E38];
    egLabel.textAlignment = NSTextAlignmentCenter;
    egLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"custom_node"];
    [self nodeAddr];
    [_alertContentView addSubview:_nodeAddr];
    [_alertContentView addSubview:_warnLabel];
    //============================自定义部分截止区=====================
    UIView *hoLine = [UIView new];
    [_alertContentView addSubview:hoLine];
    hoLine.frame = CGRectMake(0, height - 48, width ,1 );
    hoLine.backgroundColor = [UIColor colorWithHex:0xEEEEF2];//浅灰
    //verticaLine
    UIView *verticalLine = [UIView new];
    [_alertContentView addSubview:verticalLine];
    verticalLine.frame = CGRectMake(width/2, height - 48, 1, 48);
    verticalLine.backgroundColor = [UIColor colorWithHex:0xEEEEF2];//浅灰
    [self cancelBtn];
    [_alertContentView addSubview:_cancelBtn];
//    //取消操作放到此处
//    self.isClickCancel = ^(BOOL isClick) {
//        if (isClick) {}
//    };
    [self confirmBtn];
    [_alertContentView addSubview:_confirmBtn];
    //确认按钮的操作放在此处
//    self.isClickSure = ^(BOOL isClick) {
//        if (isClick) {}
//    };
}

#pragma mark - 用block充当事件点击协议，确认按钮或视图被点击
-(void)viewTap:(UITapGestureRecognizer *)tap
{
    if (self.isClickBg) {
        self.isClickBg(YES);
    }
}

-(void)clickBtn:(UIButton *)btn{
    
    switch (btn.tag) {
            //取消按钮
        case 200:
            _nodeAddr.text = @"";
            _alertbackView.hidden = YES;
            break;
            //确定按钮
        case 201:
            if (_nodeAddr.text.length != 0){
                NSString *str = _nodeAddr.text;
                NSMutableDictionary *node = [NSMutableDictionary new];
                [node setValue:[NSString stringWithFormat:@"%@%@",[[TPOSLocalizedHelper standardHelper]stringWithKey:@"custom_node"],[_index stringValue]] forKey:@"name"];
                _index = [NSNumber numberWithInt:[_index intValue] + 1];
                [node setValue:str forKey:@"node"];
                if (!_customNodes){
                    _customNodes = [NSMutableArray new];
                }
                [_customNodes addObject:node];
                [self.tableView reloadData];
            }
            _alertbackView.hidden = YES;
            _nodeAddr.text = @"";
            break;
        default:
            _nodeAddr.text = @"";
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextField *)nodeAddr{
    CGFloat QCWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat offset = 40;//弹出框两边边距
    CGFloat width = QCWidth -offset*2;
    _nodeAddr  = [[UITextField alloc]initWithFrame:CGRectMake(20,50, width-40, 48)];
    _nodeAddr.backgroundColor = [UIColor colorWithHex:0xF4F5F6];
    _nodeAddr.layer.borderColor = [UIColor colorWithHex:0xEEEEF2].CGColor;
    _nodeAddr.layer.borderWidth = 1;
    _nodeAddr.layer.cornerRadius = 10;
    _nodeAddr.layer.masksToBounds = YES;
    _warnLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,108, width-40, 20)];
    _warnLabel.text = [[TPOSLocalizedHelper standardHelper]stringWithKey:@"node_warn"];
    _warnLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    _warnLabel.textColor = [UIColor redColor];
    _warnLabel.hidden = YES;
    _nodeAddr.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 13, 21)];
    label.backgroundColor = [UIColor clearColor];
    _nodeAddr.leftViewMode = UITextFieldViewModeAlways;
    _nodeAddr.leftView = label;
    _nodeAddr.placeholder = @"ws://";
    return _nodeAddr;
}

- (UIButton *)cancelBtn{
    CGFloat QCWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat offset = 40;//弹出框两边边距
    CGFloat width = QCWidth -offset*2;//弹出框宽
    CGFloat height = 180;//弹出框高
    //取消按钮
    _cancelBtn = [UIButton new];
    _cancelBtn.frame = CGRectMake(0, height - 48, width/2, 48);
    _cancelBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    [_cancelBtn setTitle:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"cancel"] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor colorWithHex:0xA6A9AD] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.tag = 200;
    return _cancelBtn;
}

- (UIButton *)confirmBtn{
    CGFloat QCWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat offset = 40;//弹出框两边边距
    CGFloat width = QCWidth -offset*2;//弹出框宽
    CGFloat height = 180;//弹出框高
    //确定按钮
    _confirmBtn = [UIButton new];
    _confirmBtn.tag = 201;
    _confirmBtn.frame = CGRectMake(width/2 +1, height - 48, width/2-1, 48);
    [_confirmBtn setTitle:[[TPOSLocalizedHelper standardHelper]stringWithKey:@"confirm"] forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor colorWithHex:0x3B6CA6] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    [_confirmBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    return _confirmBtn;
}


@end
