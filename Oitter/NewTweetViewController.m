//
//  NewTweetViewController.m
//  Oitter
//
//  Created by Jun on 1/1/13.
//
//

#import "NewTweetViewController.h"
#import "MainViewController.h"

@interface NewTweetViewController()
@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;
@end

@implementation NewTweetViewController

ACAccount *account;
ACAccountStore *accountStore;

@synthesize peekLeftAmount, letterCount, inputMessage, buttonsBar, keyboardPlaceholder, imagePickerController, image;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.slidingViewController setAnchorLeftRevealAmount:320.0f];
    self.slidingViewController.underRightWidthLayout = ECFullWidth;
    
    [inputMessage setDelegate:self];
    [buttonsBar setDelegate:self];
    
    [[self buttonsBar] setBackgroundImage:[UIImage imageNamed:@"tabBar.png"]];
    
    [[self keyboardPlaceholder] setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"keyboardPlaceHolder.png"]]];
    [[self inputMessage] setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"newTweetMessageView.png"]]];

    imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    [imagePickerController setAllowsEditing:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    letterCount = nil;
    inputMessage = nil;
    buttonsBar = nil;
    image = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    int count = textView.text.length;
    letterCount.text = [NSString stringWithFormat:@"%d", 140 - count];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text length] == 0)
    {
        if([inputMessage.text length] != 0)
        {
            return YES;
        }
        else {
            return NO;
        }
    }
    else if([[inputMessage text] length] > 139)
    {
        return NO;
    }
    return YES;
}

#pragma mark UITabBar Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [inputMessage resignFirstResponder];
    switch (item.tag) {
        case 1: //Picture
        {
            UIButton *choosePictureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [choosePictureButton addTarget:self action:@selector(choosePicture:) forControlEvents:UIControlEventTouchUpInside];
            [choosePictureButton setTitle:@"Choose picture from album" forState:UIControlStateNormal];
            choosePictureButton.frame = CGRectMake(55.0, 79.0, 210.0, 26.0);
            [keyboardPlaceholder addSubview:choosePictureButton];
            
            UIButton *capturePictureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [capturePictureButton addTarget:self action:@selector(capturePicture:) forControlEvents:UIControlEventTouchUpInside];
            [capturePictureButton setTitle:@"Capture new picture" forState:UIControlStateNormal];
            capturePictureButton.frame = CGRectMake(55.0, 112.0, 210.0, 26.0);
            [keyboardPlaceholder addSubview:capturePictureButton];
            
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                capturePictureButton.enabled = NO;
            }
            
            break;
        }
        case 2: //URL
        {
            NSLog(@"URL");
            break;
        }
        case 3: //Location
        {
            NSLog(@"Location");
            break;
        }
        case 4: //Friends
        {
            NSLog(@"Friends");
            break;
        }
        default:
            break;
    }
}

#pragma mark UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    [picker dismissModalViewControllerAnimated:YES];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    
    imageView.frame = CGRectMake(7.0, 7.0, 306.0, 202.0);
    [keyboardPlaceholder addSubview:imageView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
    [inputMessage resignFirstResponder];
    [self.slidingViewController resetTopView];
    inputMessage.text = nil;
    letterCount.text = @"140";
    image = nil;
}

- (IBAction)tweet:(id)sender
{    
    // Build a twitter request
    if (image == nil){
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:
                                  [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
                                                     parameters:[NSDictionary dictionaryWithObject:inputMessage.text
                                                                                            forKey:@"status"] requestMethod:TWRequestMethodPOST];
        // Post the request
        [postRequest setAccount:account];
        
        // Block handler to manage the response
        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
         }];
    } else {
        TWRequest *postRequestWithMedia = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"]
                                                              parameters:nil
                                                           requestMethod:TWRequestMethodPOST];
        [postRequestWithMedia addMultiPartData:[inputMessage.text dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data"];
        
        NSData *imageData = UIImagePNGRepresentation(image);
        [postRequestWithMedia addMultiPartData:imageData withName:@"media[]" type:@"image/jpeg"];

        // Post the request
        [postRequestWithMedia setAccount:account];
        
        // Block handler to manage the response
        [postRequestWithMedia performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
         }];
        imageData = nil;
    }
    
    [inputMessage resignFirstResponder];
    [self.slidingViewController resetTopView];
    inputMessage.text = nil;
    letterCount.text = @"140";
    image = nil;
}

- (IBAction)choosePicture:(id)sender
{
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (IBAction)capturePicture:(id)sender
{
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:imagePickerController animated:YES completion:NULL];}

@end