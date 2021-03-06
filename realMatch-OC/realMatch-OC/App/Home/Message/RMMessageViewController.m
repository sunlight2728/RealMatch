//
//  RMMessageViewController.m
//  realMatch-OC
//
//  Created by arceushs on 2019/6/23.
//  Copyright © 2019 qingting. All rights reserved.
//

#import "RMMessageViewController.h"
#import "RMMessageTableViewCell.h"
#import "Router.h"
#import "realMatch_OC-Swift.h"
#import "UIView+RealMatch.h"
#import "RMFetchMessageAPI.h"
#import "SDWebImage.h"
#import "RMSocketManager.h"

@interface RMMessageViewController ()<UITableViewDelegate,UITableViewDataSource,RouterController,RMSocketManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (strong,nonatomic) NSString* userId;
@property (strong,nonatomic) NSArray<RMFetchMessageModel*>* messageArr;
@property (strong,nonatomic) NSArray<RMFetchLikesMeModel*>* likesArr;
@end

@implementation RMMessageViewController

- (BOOL)animation {
    return true;
}

- (DisplayStyle)displayStyle {
    return DisplayStylePush;
}

- (instancetype)initWithRouterParams:(NSDictionary *)params {
    if(self = [super init]){
        _userId = params[@"userId"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageTableView.delegate = self;
    self.messageTableView.dataSource = self;
    self.messageTableView.rowHeight = 97;
    self.messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.likesArr = [NSMutableArray array];
    self.messageArr = [NSMutableArray array];
    
    [self.messageTableView registerNib:[UINib nibWithNibName:@"RMMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"RMMessageTableViewCell"];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshView];
    [[RMSocketManager shared] addDelegate:self];
}

-(void)viewDidDisapper:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[RMSocketManager shared] removeDelegate:self];
}

-(void)didReceiveMessage{
    [self refreshView];
}
- (void)refreshView {
    RMFetchLikesMeAPI* likesMeAPI = [[RMFetchLikesMeAPI alloc] initWithUserId:_userId];
    [[RMNetworkManager shareManager] request:likesMeAPI completion:^(RMNetworkResponse *response) {
        RMFetchLikesMeAPIData* data = [[RMFetchLikesMeAPIData alloc]init];
        data = (RMFetchLikesMeAPIData*)response.responseObject;
        if([data.likesMeArr count]>0){
            RMMessageHeader* header = [[RMMessageHeader alloc]initWithFrame:CGRectMake(0, 0, self.messageTableView.width, 160) likesMeArr:data.likesMeArr];
            self.messageTableView.tableHeaderView = header;
        } else {
            self.messageTableView.tableHeaderView = nil;
        }
        self.likesArr = [data.likesMeArr copy];
    }];
    
    RMFetchMessageAPI* messageAPI = [[RMFetchMessageAPI alloc]initWithUserId:_userId];
    [[RMNetworkManager shareManager] request:messageAPI completion:^(RMNetworkResponse *response) {
        RMFetchMessageAPIData* data = [[RMFetchMessageAPIData alloc]init];
        data = (RMFetchMessageAPIData*)response.responseObject;
        self.messageArr = [data.list copy];
        if([data.list count]>0){
            [self.messageTableView reloadData];
        }else{
            RMMessageFooter* footer = [[RMMessageFooter alloc]initWithFrame:CGRectMake(0, 0, self.messageTableView.width, 400)];
            self.messageTableView.tableFooterView = footer;
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArr.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if([self.messageArr count]>0){
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 60)];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(16, 40, 300, 26)];
        label.text = [NSString stringWithFormat:@"Message(%lu)",[self.messageArr count]];
        [view addSubview:label];
        return view;
    }else{
        return [[UIView alloc]init];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([self.messageArr count]>0){
        return 60;
    }else{
        return 0.01;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RMMessageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RMMessageTableViewCell"];
    RMFetchMessageModel* model = self.messageArr[indexPath.row];
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"default.jpeg"]];
    cell.titleLabel.text = model.name;
    cell.subtitleLabel.text = model.msg;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RMFetchMessageModel* model = self.messageArr[indexPath.row];
    [[Router shared]routerTo:@"RMMessageDetailViewController" parameter:@{@"fromUser":self.userId,@"toUser":model.userId,@"fromUserName":model.name,@"avatar":model.avatar}];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





@end
