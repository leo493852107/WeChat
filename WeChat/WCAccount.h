//
//  WCAccount.h
//  WeChat
//
//  Created by leo on 15/10/8.
//  Copyright © 2015年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAccount : NSObject

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *pwd;

/**
 *  判断用户是否登录
 */
@property (nonatomic, assign,getter=isLogin) BOOL login;


+ (instancetype)shareAccount;

/**
 *  保存最新的用户登录数据到沙盒
 */
- (void)saveToSandBox;

@end
