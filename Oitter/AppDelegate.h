//
//  AppDelegate.h
//  Oitter
//
//  Created by Justin Jun on 12/31/11.
//  Copyright (c) 2013 Justin Jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "ECSlidingViewController.h"

extern ACAccount *account;
extern ACAccountStore *accountStore;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}
@property (strong, nonatomic) UIWindow *window;

@end