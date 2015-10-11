//
//  WCAccount.m
//  WeChat
//
//  Created by leo on 15/10/8.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCAccount.h"

#define kUserKey @"user"
#define kPwdKey @"pwd"
#define kLoginKey @"login"

@implementation WCAccount


+ (instancetype)shareAccount {
    return [[self alloc]init];
}

#pragma mark - 分配内存创建对象
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    NSLog(@"%s",__func__);
    static WCAccount *account;
    
    // 创建单例对象
    // 为了线程安全
    // 三个线程同时调用这个方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (account == nil) {
            account = [super allocWithZone:zone];
            
            // 从沙盒获取上次的用户登录信息
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            account.user = [defaults objectForKey:kUserKey];
            account.pwd = [defaults objectForKey:kPwdKey];
            account.login = [defaults boolForKey:kLoginKey];
            
        }
    });
    return account;
}

- (void)saveToSandBox {
    
    // 保存user pwd login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:kUserKey];
    [defaults setObject:self.pwd forKey:kPwdKey];
    [defaults setBool:self.isLogin forKey:kLoginKey];
    [defaults synchronize];
    
}

@end
