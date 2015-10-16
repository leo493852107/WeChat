//
//  WCChatViewController.m
//  WeChat
//
//  Created by leo on 15/10/16.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCChatViewController.h"

@interface WCChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
    
    NSFetchedResultsController *_resultContr;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *  输入框距离底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@end

@implementation WCChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 加载数据库的聊天数据
    
    // 1.上下文
    NSManagedObjectContext *msgContext = [WCXMPPTool sharedWCXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    
    // 2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤 (当前登录用户 并且 好友的聊天消息)
    NSString *loginUserJid = [WCXMPPTool sharedWCXMPPTool].xmppStream.myJID.bare;
    WCLog(@"%@",loginUserJid);
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    // 设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 3.执行请求
    _resultContr = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *error = nil;
    [_resultContr performFetch:&error];
    WCLog(@"%@",error);
    WCLog(@"%@",_resultContr.fetchedObjects);
    
}

#pragma mark - 数据库内容改变调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
    
    // 表格滚动到底部
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_resultContr.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

#pragma mark - 表格数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 获取聊天信息
    
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = msgObj.body;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 键盘的通知
#pragma mark - 键盘将显示
- (void)kbWillShow:(NSNotification *)noti {
    // 显示的时候改变bottomConstraint
    
    // 获取键盘高度
    NSLog(@"%@",noti.userInfo);
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.bottomConstraint.constant = kbHeight;
}

#pragma mark - 键盘将隐藏
- (void)kbWillHide:(NSNotification *)noti {
    self.bottomConstraint.constant = 0;
}

#pragma mark - 发送聊天数据
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *txt = textField.text;
    
    // 怎么发聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:txt];
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
    
    // 清空输入框文本
    textField.text = nil;
    return YES;
}

#pragma mark - 表格滚动，隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


@end
