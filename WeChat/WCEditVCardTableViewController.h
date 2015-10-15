//
//  WCEditVCardTableViewController.h
//  WeChat
//
//  Created by leo on 15/10/15.
//  Copyright © 2015年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeChat-Prefix.pch"

@class WCEditVCardTableViewController;
@protocol WCEditVCardTableViewControllerDelegate <NSObject>

- (void)editVCardTableViewController:(WCEditVCardTableViewController *)edit VcdidFinishedSave:(id)sender;

@end

@interface WCEditVCardTableViewController : UITableViewController


/**
 *  上一个控制器(个人信息控制器)传入的cell
 */
@property (nonatomic, strong) UITableViewCell *cell;


@property (nonatomic, weak)id<WCEditVCardTableViewControllerDelegate> delegate;

@end
