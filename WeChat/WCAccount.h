//
//  WCAccount.h
//  WeChat
//
//  Created by leo on 15/10/8.
//  Copyright © 2015年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAccount : NSObject

/**
 *  用户登录的用户名和密码
 */
@property (nonatomic, copy) NSString *loginUser;
@property (nonatomic, copy) NSString *loginPwd;

/**
 *  用户注册的用户名和密码
 */
@property (nonatomic, copy) NSString *registerUser;
@property (nonatomic, copy) NSString *registerPwd;

/**
 *  判断用户是否登录
 */
@property (nonatomic, assign,getter=isLogin) BOOL login;


+ (instancetype)shareAccount;

/**
 *  保存最新的用户登录数据到沙盒
 */
- (void)saveToSandBox;

/**
 *  服务器的域名
 */
@property (nonatomic, copy, readonly) NSString *domain;

/**
 *  服务器的IP
 */
@property (nonatomic, copy, readonly) NSString *host;

/**
 *  服务器的端口
 */
@property (nonatomic, assign, readonly) int port;

@end
