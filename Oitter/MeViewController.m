//
//  MeViewController.m
//  Oitter
//
//  Created by Justin Jun on 1/1/13.
//  Copyright (c) 2013 Justin Jun. All rights reserved.
//

#import "MeViewController.h"

@implementation MeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[NewTweetViewController class]]) {
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewTweet"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

@end
