//
//  TimelineViewController.m
//  Oitter
//
//  Created by Jun on 1/1/13.
//
//

#import "TimelineViewController.h"
#import "TweetCell.h"

#define FONT_SIZE 15.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 7.0f

@interface TimelineViewController() {
    NSIndexPath *selectedRow;
}

- (void)fetchData;

@end

@implementation TimelineViewController

ACAccount *account;
ACAccountStore *accountStore;

@synthesize timelineTableView;
@synthesize timeline = _timeline;

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
    [timelineTableView delegate];
    [self fetchData];
    timelineTableView.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id tweet = [self.timeline objectAtIndex:[indexPath row]];
    NSString *tweetBody = [tweet valueForKeyPath:@"text"];

    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [tweetBody sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:FONT_SIZE]
                        constrainedToSize:constraint];
    CGFloat height = size.height + (CELL_CONTENT_MARGIN * 2) + 14;
    
    if (selectedRow && indexPath.row == selectedRow.row) {
        NSLog(@"CELLIEXTEND");
        return 460;
    } else {
        return height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeline count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedRow && indexPath.row == selectedRow.row) {
        static NSString *cellIdentifier = @"TweetCellSelected";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        id tweet = [self.timeline objectAtIndex:[indexPath row]];
        
        UILabel *userName = (UILabel *)[cell viewWithTag:100];
        userName.text = [tweet valueForKeyPath:@"user.name"];
        
//        UILabel *tweetBody = (UILabel *)[cell viewWithTag:103];
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"TweetCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        id tweet = [self.timeline objectAtIndex:[indexPath row]];
        
        UILabel *userName = (UILabel *)[cell viewWithTag:100];
        userName.text = [tweet valueForKeyPath:@"user.name"];
        
        UILabel *tweetBody = (UILabel *)[cell viewWithTag:103];
        
        if ([tweet objectForKey:@"truncated"] == @"1") {
            tweetBody.text = [tweet valueForKeyPath:@"retweeted_status.text"];
        }
        else {
            tweetBody.text = [tweet objectForKey:@"text"];   
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath;
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
    if(distanceFromBottom < height)
    {
        NSLog(@"Reached End");
    }
}

#pragma - Private methods

- (void)fetchData
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                             parameters:nil
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSLog(@"Timeline retrive successed!");
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                self.timeline = jsonResult;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.timelineTableView reloadData];
                });
            }
            else    NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
        }
    }];
}

@end