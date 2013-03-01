//
//  AccountsViewController.h
//  Oitter
//
//  Created by Jun on 2/11/13.
//
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MainViewController.h"
#import "MenuViewController.h"
#import "NewTweetViewController.h"

@interface AccountsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *accountsTableView;
}

@property(nonatomic, strong)IBOutlet UITableView *accountsTableView;

@property(nonatomic, strong)NSArray *accountsArray;

@end
