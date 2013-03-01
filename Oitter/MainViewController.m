//
//  ViewController.m
//  Oitter
//
//  Created by Justin Jun on 12/31/11.
//  Copyright (c) 2013 Justin Jun. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard *storyboard;

    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"Timeline"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
