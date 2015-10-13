//
//  AppDelegate.m
//  WeChat
//
//  Created by leo on 15/10/6.
//  Copyright © 2015年 leo. All rights reserved.
//

/**
 用户登录流程
 1.初始化XMPPStream

 2.连接服务器(传一个jid)

 3.连接成功，接着发送密码
 
 4.发送一个“在线消息”给服务器(默认登录成功是不在线的)，可以通知其他用户你上线
 */

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [self setupStream];
//    [self connectToHost];
    
    // 判断用户是否登录
    if ([WCAccount shareAccount].isLogin) {
        // 来界面
        id mainVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        self.window.rootViewController = mainVc;
        
        // 自动登录
        [[WCXMPPTool sharedWCXMPPTool] xmppLogin:nil];
    }
    
    return YES;
}


@end
