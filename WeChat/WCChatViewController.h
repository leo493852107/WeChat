//
//  WCChatViewController.h
//  WeChat
//
//  Created by leo on 15/10/16.
//  Copyright © 2015年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeChat-Prefix.pch"

@interface WCChatViewController : UIViewController

/**
 *  好友的Jid
 */
@property (nonatomic, strong) XMPPJID *friendJid;

@end
