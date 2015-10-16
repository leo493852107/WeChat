//
//  WCAddContactTableViewController.m
//  WeChat
//
//  Created by leo on 15/10/16.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCAddContactTableViewController.h"

@interface WCAddContactTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)addContactBtnClick:(id)sender;


@end

@implementation WCAddContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

#pragma mark - 添加好友
- (IBAction)addContactBtnClick:(id)sender {
    // 添加好友
    // 获取用户输入好友名称
    NSString *user = self.textField.text;
    
    
    // 1.不能添加自己为好友
    if ([user isEqualToString:[WCAccount shareAccount].loginUser]) {
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    
    // 2.已经存在的好友无需添加
    XMPPJID *userJid = [XMPPJID jidWithUser:user domain:[WCAccount shareAccount].domain resource:nil];
    
    BOOL userExits = [[WCXMPPTool sharedWCXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream];
    if (userExits) {
        [self showMsg:@"好友已存在"];
        return;
    }
    
    // 3.添加好友 (订阅)
    [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:userJid];
    
    // 添加好友在现有openfire存在的问题
    // 1.添加不存在的好友，通讯录里面也显示了好友
    // 解决办法1:服务器可以拦截好友添加的请求，如果当前服务器没有好友，不要返回信息
    
    // 解决办法2:过滤数据库的Subscription字段查询请求
    // none 对方没有同意添加好友
    // to 发给对方的请求
    // from 别人发来的请求
    // both 双方互为好友
    // 当前采用方法2
    
}

- (void)showMsg:(NSString *)msg {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [av show];
}


@end
