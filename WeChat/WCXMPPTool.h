//
//  WCXMPPTool.h
//  WeChat
//
//  Created by leo on 15/10/12.
//  Copyright © 2015年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

typedef enum {
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoginFailure,//登录失败
    XMPPResultTypeRegisterSuccess,//注册成功
    XMPPResultTypeRegisterFailure//注册失败
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface WCXMPPTool : NSObject

singleton_interface(WCXMPPTool)

/**
 *  标识连接服务器是"登录"连接,还是"注册"连接
 *  NO --> 登录操作
 *  YES --> 注册操作
 */
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

/**
 *  XMPP用户登录
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  用户注册
 */
- (void)xmppRegister:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
- (void)xmppLogout;

@end