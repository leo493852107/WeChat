//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by leo on 15/10/12.
//  Copyright © 2015年 leo. All rights reserved.
//

#import "WCRegisterViewController.h"

@interface WCRegisterViewController ()

- (IBAction)cancelBtnClick:(id)sender;
- (IBAction)registerBtnClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;


@end

@implementation WCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelBtnClick:(id)sender {
    [UIStoryboard showInitialVCWithName:@"Login"];
}

- (IBAction)registerBtnClick:(id)sender {
    
    // 注册
    // 保存注册的用户名和密码
    [WCAccount shareAccount].registerUser = self.userField.text;
    [WCAccount shareAccount].registerPwd = self.pwdField.text;
    
    [MBProgressHUD showMessage:@"正在注册中..."];
    // 调用注册的方法
    __weak typeof (self) selfVc = self;
    [WCXMPPTool sharedWCXMPPTool].registerOperation = YES;
    [[WCXMPPTool sharedWCXMPPTool] xmppRegister:^(XMPPResultType resultType) {
        [selfVc handleXMPPResult:resultType];
    }];
}

#pragma mark - 处理注册的结果
- (void)handleXMPPResult:(XMPPResultType)resultType {
    
    // 在主线程工作
    dispatch_async(dispatch_get_main_queue(), ^{
       
        // 1.隐藏提示
        [MBProgressHUD hideHUD];
        
        // 2.提示注册成功
        if (resultType == XMPPResultTypeRegisterSuccess) {
            [MBProgressHUD showSuccess:@"注册成功,回到登录界面登录"];
        } else {
            [MBProgressHUD showError:@"用户名已存在"];
        }
        
    });
}



@end
