//
//  WCMeTableViewController.m
//  WeChat
//
//  Created by leo on 15/10/9.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCMeTableViewController.h"
#import "AppDelegate.h"

#import "XMPPvCardTemp.h"

@interface WCMeTableViewController ()

/**
 *  登录用户的头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;

/**
 *  微信号
 */
@property (weak, nonatomic) IBOutlet UILabel *wechatNumLabel;

@end

@implementation WCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 显示头像和微信号
    
    // 从数据库里获取用户信息
    
    // 获取登录用户信息，使用电子名片模块
    
    // 登录用户的电子名片信息
    // 1.它内部回去数据查找
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 获取头像
    if (myvCard.photo) {
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 微信号(显示用户名)
//    self.wechatNumLabel.text = myvCard.jid.user;
    self.wechatNumLabel.text = [@"微信号:" stringByAppendingString:[WCAccount shareAccount].loginUser];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logoutBtnClick:(id)sender {
    
    // 注销
    [[WCXMPPTool sharedWCXMPPTool] xmppLogout];
    
    // 注销的时候，要把沙盒登录状态设置为NO
    [WCAccount shareAccount].login = NO;
    [[WCAccount shareAccount] saveToSandBox];
    
    // 2.断开连接
    // 回到登录控制器
    [UIStoryboard showInitialVCWithName:@"Login"];
}

@end
