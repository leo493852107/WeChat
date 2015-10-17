//
//  WCChatViewController.m
//  WeChat
//
//  Created by leo on 15/10/16.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCChatViewController.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface WCChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    
    NSFetchedResultsController *_resultContr;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *  输入框距离底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

- (IBAction)imgChooseBtnClick:(id)sender;

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
    
    // 判断消息的类型有没有附件
    // 1.获取原始的xml数据
    XMPPMessage *message = msgObj.message;
    
    // 获取附件的类型
    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
    if ([bodyType isEqualToString:@"image"]) {
        // 图片
        // 获取文件路径
        NSString *url = msgObj.body;
        
        // 显示图片
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ihead_007"]];
        
        // 清除循环引用导致的残留文字
        cell.textLabel.text = nil;
    } else {
        // 纯文本
        cell.textLabel.text = msgObj.body;
        
        // 清除循环引用导致的残留图片
        cell.imageView.image = nil;
    }
    
    
    return cell;
}

#pragma mark - 文件发送方案1
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *ID = @"ChatCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    
//    // 获取聊天信息
//    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
//    
//    // 判断消息的类型有没有附件
//    // 1.获取原始的xml数据
//    XMPPMessage *message = msgObj.message;
//    
//    // 获取附件的类型
//    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
//    
//    if ([bodyType isEqualToString:@"image"]) {
//        // 图片
//        // 2.遍历message的子节点
//        NSArray *childArr = message.children;
//        for (XMPPElement *note in childArr) {
//            // 获取节点的名字
//            if ([[note name] isEqualToString:@"attachement"]) {
//                WCLog(@"获取到附件...");
//                // 获取附件字符串，然后转成NSData，接着转成图片
//                NSString *imgBaseStr = [note stringValue];
//                NSData *imgData = [[NSData alloc]initWithBase64EncodedString:imgBaseStr options:0];
//                UIImage *img = [UIImage imageWithData:imgData];
//                cell.imageView.image = img;
//            }
//        }
//        
//    } else if ([bodyType isEqualToString:@"sound"]) {
//        // 音频
//        
//    } else {
//        // 纯文本
//        cell.textLabel.text = msgObj.body;
//    }
//    
//    
//    return cell;
//}

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

#pragma mark - 文件发送(以图片为例)
- (IBAction)imgChooseBtnClick:(id)sender {
    // 从图片库选取图片
    UIImagePickerController *imgPC = [[UIImagePickerController alloc]init];
    imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imgPC.allowsEditing = YES;
    imgPC.delegate = self;
    
    [self presentViewController:imgPC animated:YES completion:nil];
}

#pragma mark - 用户选择的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    WCLog(@"%@",info);
    
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    // 发送附件
//    [self sendAttachementWithData:UIImagePNGRepresentation(img) bodyType:@"img"];
    [self sendImg:img];
    
    // 隐藏图片选择的控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)sendImg:(UIImage *)img {
    // 1.把文件上传到文件服务器
    /**
     *  >文件上传的路径
     *  http://localhost:8080/imfileserver/Upload/Image/ + 文件名
     *  >文件上传的方法不是使用POST，而是使用put，在公司开发中，put方式的文件上传比较常用
     *  文件上传的路径也就是文件下载的路径
     */
    
    // 1.1定义文件名 user + 20151017161112(zhangsan20151017161112)
    NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
    dateForm.dateFormat = @"yyyyMMddHHmmss";
    NSString *currentTimeStr = [dateForm stringFromDate:[NSDate date]];
    
    NSString *fileName = [[WCAccount shareAccount].loginUser stringByAppendingString:currentTimeStr];
    
    // 1.2拼接文件上传路径
    NSString *uploadPath = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    
    WCLog(@"%@",uploadPath);
    
    // 2.上传成功后，把文件路径发送给openfire服务器
    HttpTool *httpTool = [[HttpTool alloc] init];
    // 图片上传的时候，以jpg格式上传
    // 因为文件服务器只接受jpg
    [httpTool uploadData:UIImageJPEGRepresentation(img, 0.75) url:[NSURL URLWithString:uploadPath] progressBlock:nil completion:^(NSError *error) {
        if (!error) {
            WCLog(@"上传成功");
            XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
            [msg addAttributeWithName:@"bodyType" stringValue:@"image"];
            [msg addBody:uploadPath];
            
            [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
        } else {
            WCLog(@"上传失败");
        }
    }];
    
}

#pragma mark - 发送图片附件
- (void)sendAttachementWithData:(NSData *)data bodyType:(NSString *)bodyType {
    // 发送图片
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    // 设置类型
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    
#pragma mark - 没有body就不认
    [msg addBody:bodyType];
//    [msg addBody:@"sound"];
//    [msg addBody:@"doc"];
//    [msg addBody:@"xls"];

    
    // 把附件经过"base64编码"转成字符串
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    // 定义附件
    XMPPElement *attachement = [XMPPElement elementWithName:@"attachement" stringValue:base64Str];
    
    // 添加子节点
    [msg addChild:attachement];
    
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
    WCLog(@"%@",msg);
}

//- (void)sendAttachementWithImage:(UIImage *)img {
//    // 发送图片
//    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
//    
//    //    [msg addAttributeWithName:<#(NSString *)#> boolValue:<#(BOOL)#>];
//#pragma mark - 没有body就不认
//    [msg addBody:@"image"];
//    //    [msg addBody:@"sound"];
//    //    [msg addBody:@"doc"];
//    //    [msg addBody:@"xls"];
//    
//    
//    // 把图片经过"base64编码"转成字符串
//    // 1.把图片转成NSData
//    NSData *imgData = UIImagePNGRepresentation(img);
//    // 2.把data转成base64的字符串
//    NSString *imgBaseStr = [imgData base64EncodedStringWithOptions:0];
//    
//    // 定义附件
//    XMPPElement *attachement = [XMPPElement elementWithName:@"attachement" stringValue:imgBaseStr];
//    
//    // 添加子节点
//    [msg addChild:attachement];
//    
//    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
//    WCLog(@"%@",msg);
//}


@end
