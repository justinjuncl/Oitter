//
//  TimelineViewController.h
//  Oitter
//
//  Created by Jun on 1/1/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "ECSlidingViewController.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "NewTweetViewController.h"

@interface TimelineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *timelineTableView;
}

@property(nonatomic, strong)IBOutlet UITableView *timelineTableView;

@property(nonatomic, strong)id timeline;

@end
