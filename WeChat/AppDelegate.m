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
#import "XMPPFramework.h"
#import "WeChat-Prefix.pch"

@interface AppDelegate () <XMPPStreamDelegate> {
    
    // 与服务器交互的核心类
    XMPPStream *_xmppStream;
    
    // 结果回调Block
    XMPPResultBlock _resultBlock;
}

/**
 *  1.初始化XMPPStream
 */
- (void)setupStream;

/**
 *  2.连接服务器(传一个jid)
 */
- (void)connectToHost;

/**
 *  3.连接成功，接着发送密码
 */
- (void)sendPwdToHost;

/**
 *  4.发送一个“在线消息”给服务器
 */
- (void)sendOnline;

/**
 *  发送"离线"消息
 */
- (void)sendOffline;

/**
 *  与服务器断开连接
 */
- (void)disconnectFromHost;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [self setupStream];
//    [self connectToHost];
    
    // 判断用户是否登录
    if ([WCAccount shareAccount].isLogin) {
        // 来界面
        id mainVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        self.window.rootViewController = mainVc;
    }
    
    return YES;
}

#pragma mark - 私有方法
- (void)setupStream {
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc]init];
    
    // 设置代理 -
#warning    所有的代理方法都将在子线程被调用
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)connectToHost {
    
    if (!_xmppStream) {
        [self setupStream];
    }
    
    // 1.设置用户的jid
    // resource 用户登录客户端设备的类型
    
    NSString *user = [WCAccount shareAccount].user;
    
    XMPPJID *myjid = [XMPPJID jidWithUser:user domain:@"127.0.0.1" resource:@"iphone6P"];
    _xmppStream.myJID = myjid;
    
    // 2.设置主机地址
    _xmppStream.hostName = @"127.0.0.1";
    
    // 3.设置主机的端口号(默认端口就是5222，可以不用设置)
    _xmppStream.hostPort = 5222;
    
    // 4.发送连接
    NSError *error = nil;
    // 缺少必要的参数时就会发起连接失败
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error);
    } else {
        NSLog(@"发起连接成功");
    }
}

- (void)sendPwdToHost {
    NSError *error = nil;
    NSString *pwd = [WCAccount shareAccount].pwd;
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

- (void)sendOnline {
    // XMPP框架，已经把所有的指令封装成对象
    XMPPPresence *presence = [XMPPPresence presence];
    NSLog(@"%@",presence);
    [_xmppStream sendElement:presence];
}

- (void)sendOffline {
    
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}

- (void)disconnectFromHost {
    [_xmppStream disconnect];
}


#pragma mark - XMPPStream的代理
#pragma mark - 连接建立成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"%s",__func__);
    
    [self sendPwdToHost];
}

#pragma mark - 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"%s",__func__);
    [self sendOnline];
    
    // 回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
}

#pragma mark - 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    
    NSLog(@"%s %@",__func__,error);
    // 回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
}

#pragma mark - 公共方法

#pragma mark - 用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock {
    
    // 不管什么情况，把以前的连接断开
    [_xmppStream disconnect];
    
    // 保存resultBlock
    _resultBlock = resultBlock;
    
    // 连接服务器开始登录的操作
    [self connectToHost];
}

#pragma mark - 用户注销
- (void)xmppLogout {
    // 注销
    // 1.发送"离线消息"给服务器
    [self sendOffline];
    
    // 2.断开连接
    [self disconnectFromHost];
}

@end
