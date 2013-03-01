//
//  AccountsViewController.m
//  Oitter
//
//  Created by Jun on 2/11/13.
//
//

#import "AccountsViewController.h"
#import "MainViewController.h"

@interface AccountsViewController ()

- (void)fetchData;

@property(nonatomic, strong)NSCache *userNameCache;
@property(nonatomic, strong)NSCache *userImageCache;

@end

@implementation AccountsViewController

ACAccount *account;
ACAccountStore *accountStore;

@synthesize accountsTableView;

@synthesize accountsArray = _accountsArray;

@synthesize userNameCache = _userNameCache;
@synthesize userImageCache = _userImageCache;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [accountsTableView setDelegate:self];
    [accountsTableView setDataSource:self];
    
    _userNameCache = [[NSCache alloc] init];
    [_userNameCache setName:@"TWUsernameCache"];
    _userImageCache = [[NSCache alloc] init];
    [_userImageCache setName:@"TWImageCache"];

    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountTypeTwitter
                            withCompletionHandler:^(BOOL granted, NSError *error) {
                                if (granted) {
                                    // Set the twitter account from saved identifier
                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                    NSString *accountIdentifier = [defaults objectForKey:@"identifier"];
                                    account = [accountStore accountWithIdentifier:accountIdentifier];
                                }
                            }];
    
    [self fetchData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_userNameCache removeAllObjects];
    [_userImageCache removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _accountsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    account = [self.accountsArray objectAtIndex:[indexPath row]];
    
    UILabel *userName = (UILabel *)[cell viewWithTag:100];
    
    UIImageView *userImage = (UIImageView *)[cell viewWithTag:101];
    
    NSString *username = [_userNameCache objectForKey:account.username];
    if (username) {
        userName.text = username;
    }
    else {
        TWRequest *fetchAdvancedUserProperties = [[TWRequest alloc]
                                                  initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"]
                                                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil]
                                                  requestMethod:TWRequestMethodGET];
        [fetchAdvancedUserProperties performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) {
                NSError *error;
                id userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                if (userInfo != nil) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_userNameCache setObject:[userInfo valueForKey:@"name"] forKey:account.username];
                        [self.accountsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                    });
                }
            }
        }];
    }
    
    UIImage *image = [_userImageCache objectForKey:account.username];
    if (image) {
        userImage.image = image;
    }
    else {
        TWRequest *fetchUserImageRequest = [[TWRequest alloc]
                                            initWithURL:[NSURL URLWithString:
                                                         [NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@",
                                                          account.username]]
                                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"bigger", @"size", nil]
                                            requestMethod:TWRequestMethodGET];
        [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) {
                UIImage *image = [UIImage imageWithData:responseData];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_userImageCache setObject:image forKey:account.username];
                    [self.accountsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                });
            }
        }];
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    account = [self.accountsArray objectAtIndex:indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account.identifier forKey:@"identifier"];
    [defaults synchronize];
}

#pragma mark - Private methods

- (void)fetchData
{
    accountStore = [[ACAccountStore alloc] init];
    if (_accountsArray == nil) {
        ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                self.accountsArray = [accountStore accountsWithAccountType:accountTypeTwitter];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.accountsTableView reloadData];
                });
            }
        }];
    }
}

@end