//
//  NewTweetViewController.h
//  Oitter
//
//  Created by Jun on 1/1/13.
//
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"

@interface NewTweetViewController : UIViewController <UITextViewDelegate, UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UILabel *letterCount;
    IBOutlet UITextView *inputMessage;
    IBOutlet UITabBar *buttonsBar;
    IBOutlet UIView *keyboardPlaceholder;
    UIImagePickerController *imagePickerController;
    UIImage *image;
}

@property(nonatomic, strong)IBOutlet UILabel *letterCount;
@property(nonatomic, strong)IBOutlet UITextView *inputMessage;
@property(nonatomic, strong)IBOutlet UITabBar *buttonsBar;
@property(nonatomic, strong)IBOutlet UIView *keyboardPlaceholder;
@property(nonatomic, strong)UIImagePickerController *imagePickerController;
@property(nonatomic, strong)UIImage *image;

- (IBAction)cancel:(id)sender;
- (IBAction)tweet:(id)sender;
- (IBAction)choosePicture:(id)sender;
- (IBAction)capturePicture:(id)sender;

@end
