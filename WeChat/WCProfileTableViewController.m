//
//  WCProfileTableViewController.m
//  WeChat
//
//  Created by leo on 15/10/14.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCProfileTableViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditVCardTableViewController.h"

@interface WCProfileTableViewController ()<WCEditVCardTableViewControllerDelegate>

// 头像
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
// 昵称
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
// 微信号
@property (weak, nonatomic) IBOutlet UILabel *wechatNumLabel;
// 公司
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
// 部门
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
// 职称
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
// 电话
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
// 邮箱
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@end

@implementation WCProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.它内部回去数据查找
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 获取头像
    if (myvCard.photo) {
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 微信号(显示用户名)
    self.wechatNumLabel.text = [WCAccount shareAccount].loginUser;
    
    //
    self.nicknameLabel.text = myvCard.nickname;
    
    // 公司
    self.orgNameLabel.text = myvCard.orgName;
    
    // 部门
    if (myvCard.orgUnits.count > 0) {
        self.departmentLabel.text = myvCard.orgUnits[0];
    }
    
    self.titleLabel.text = myvCard.title;
    
    // 使用note充当电话
    self.telLabel.text = myvCard.note;
    
    // 邮箱
    // 使用mailer充当
    self.emailLabel.text = myvCard.mailer;

}

#pragma mark - 表格的选择
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 根据cell不同tag进行相应的操作
    /**
     *  tag = 0,换头像
     *  tag = 1,进行到下一个控制器
     *  tag = 2,不做任何操作
     */
    
    // 获取cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    switch (selectedCell.tag) {
        case 0:
            WCLog(@"换头像");
            break;
        case 1:
            WCLog(@"进入下一个控制器");
            [self performSegueWithIdentifier:@"toEditVcSegue" sender:selectedCell];
            break;
        case 2:
            WCLog(@"不做任何操作");
            break;
            
        default:
            WCLog(@"不做任何操作");
            break;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // 获取目标控制器
    id destVc = segue.destinationViewController;
    
    // 设置编辑电子名片控制器的cell属性
    if ([destVc isKindOfClass:[WCEditVCardTableViewController class]]) {
        WCEditVCardTableViewController *editVc = destVc;
        editVc.cell = sender;
        // 设置代理
        editVc.delegate = self;
    }
}

#pragma mark - 编辑电子名片控制器的代理
- (void)editVCardTableViewController:(WCEditVCardTableViewController *)edit VcdidFinishedSave:(id)sender {
    WCLog(@"保存");
    
    // 获取当前的电子名片
    XMPPvCardTemp *myVCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 重新设置myvCard里的属性
    myVCard.nickname = self.nicknameLabel.text;
    myVCard.orgName = self.orgNameLabel.text;
    if (self.departmentLabel.text != nil) {
        myVCard.orgUnits = @[self.departmentLabel.text];
    }
    myVCard.title = self.titleLabel.text;
    myVCard.note = self.telLabel.text;
    myVCard.mailer = self.emailLabel.text;
    
    
    // 把数据保存到服务器
    // 内部实现数据上传是把整个电子名片数据都重新上传一次，包括图片
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:myVCard];
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
