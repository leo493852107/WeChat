//
//  AppDelegate.h
//  WeChat
//
//  Created by leo on 15/10/6.
//  Copyright © 2015年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoginFailure//登录失败
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  XMPP用户登录
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  注销
 */
- (void)xmppLogout;


@end

