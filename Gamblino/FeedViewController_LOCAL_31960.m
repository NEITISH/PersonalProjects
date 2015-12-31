//
//  FeedViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "FeedViewController.h"
#import "NetworkManager.h"
#import "Contest.h"
#import "MBProgressHUD.h"
#import "FeedCell.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "UIView+Blur.h"
#import "ContestDetailsViewController.h"
#import "ContestInfoViewController.h"
#import "Constants.h"
#import "Sponsor.h"
#import "UIImage+ImageEffects.h"
#import "Pool.h"
#import "PoolType.h"
#import "AnalyticsManager.h"
#import "PoolDetailsViewController.h"
#import "PoolsInfoViewController.h"

@interface FeedViewController ()

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIView *profileView;
@property(nonatomic,weak) IBOutlet UIImageView *blurImageView;
@property(nonatomic,weak) IBOutlet UIImageView *userImageView;
@property(nonatomic,weak) IBOutlet UILabel *welcomeLabel;
@property(nonatomic,weak) IBOutlet UILabel *joinedLabel;
@property(nonatomic,weak) IBOutlet UILabel *initialsLabel;
@property(nonatomic,strong) NSArray *feeds;
@property(nonatomic,strong) User *myUser;
@property (nonatomic,assign) int remainingCallsToProcess;

@end

@implementation FeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.welcomeLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.joinedLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:12.0]];
    [self.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:48.0]];
    [self.userImageView.layer setCornerRadius:self.userImageView.bounds.size.width/2];
    [Flurry logEvent:@"Feed Screen Loaded"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.remainingCallsToProcess = 2;
    [self loadFeed];
    [self loadProfile];
}

- (void)loadProfile{
    NSString *remotePath=@"me";
        [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *usersDictionary){
            self.remainingCallsToProcess--;
            if(self.remainingCallsToProcess==0){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            if([usersDictionary.allKeys containsObject:@"users"]){
                NSDictionary *myUserDictionary=[usersDictionary valueForKey:@"users"];
                self.myUser=[[User alloc] initWithDictionary:myUserDictionary];
                [self displayProfile];
            }
        }failureBlock:^(NSError *error){
            self.remainingCallsToProcess--;
            if(self.remainingCallsToProcess==0){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            NSLog(@"error=%@",error.description);
        }];
}

-(void)loadFeed{
    
    [[NetworkManager sharedInstance] GET:@"v3/feed" withParameters:nil successBlock:^(NSDictionary *feedsDictionary){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        if([feedsDictionary.allKeys containsObject:@"feed"]){
            NSArray *feedsValue=[feedsDictionary valueForKey:@"feed"];
            NSMutableArray *feedsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in feedsValue){
                Feed *feed=[[Feed alloc] initWithDictionary:dic];
                [feedsArray addObject:feed];
            }
            self.feeds=feedsArray;
            if(feedsArray.count>0){
                self.tableView.hidden=NO;
                [self.tableView reloadData];
                self.profileView.hidden=YES;
            }
            else{
                self.tableView.hidden=YES;
                self.profileView.hidden=NO;
            }
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (void)displayProfile{
    NSDate *date=[Utils dateFromGamblinoDateString:self.myUser.createdAt];
    self.joinedLabel.text=[NSString stringWithFormat:@"JOINED %@",[Utils shortStringFromDate:date]];
    if(self.myUser.picture && self.myUser.picture.length>0){
        NSURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.myUser.picture]];
        __weak UIImageView *weakImageView = self.blurImageView;
        __weak UIImageView *weakProfileImageView = self.userImageView;
        weakProfileImageView.image = nil;
        [self.blurImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            UIImage *bluredImage=[image applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
            [weakImageView setImage:bluredImage];
            [weakProfileImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    else{
        self.userImageView.layer.borderColor=[UIColor whiteColor].CGColor;
        self.userImageView.layer.borderWidth=4.0f;
        self.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[self.myUser.firstName.uppercaseString substringToIndex:1],[self.myUser.lastName.uppercaseString substringToIndex:1]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.feeds && self.feeds.count>0){
        return self.feeds.count;
    }
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Feed *item=[self.feeds objectAtIndex:indexPath.row];
    if([item.action isEqualToString:@"new-contest"]){
        return 250.0;
    }
    else if([item.action isEqualToString:@"pool-invite"]){
        return 250.0;
    }
    else{
        return 170.0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed=[self.feeds objectAtIndex:indexPath.row];
    if([feed.action isEqualToString:@"new-contest"]){
        FeedCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ContestCell"];
        if(cell == nil){
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:self options:nil];
            cell = (FeedCell *)[nib objectAtIndex:0];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        }
        if([feed.contest.type isEqualToString:kContestTypeNational]){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.contest.bigPictureUrl]];
            __weak UIImageView *weakImageView = cell.contestImageView;
            weakImageView.image = nil;
            [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.contest.sponsor.pictureUrl]];
            __weak UIImageView *weakImageView = cell.contestImageView;
            weakImageView.image = nil;
            [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        cell.contestTitleLabel.text = feed.contest.title;
        cell.contestDescriptionLabel.text = feed.contest.subtitle;
        if(feed.contest.joined){
            cell.joinNowButtonImageView.hidden=YES;
        }
        else{
            cell.joinNowButtonImageView.hidden=NO;
        }
        return cell;
    }
    else if([feed.action isEqualToString:@"contest-winner"]){
        FeedCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ContestWinnerCell"];
        if(cell == nil){
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:self options:nil];
            cell = (FeedCell *)[nib objectAtIndex:1];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contestWinnerTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
            [cell.contestWinnerLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.pointsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.winnerImageView.layer setCornerRadius:cell.winnerImageView.bounds.size.width/2];
            [cell.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        }
        cell.contestWinnerLabel.text=[NSString stringWithFormat:@"%@ %@",feed.user.firstName.uppercaseString,feed.user.lastName.uppercaseString];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.usesGroupingSeparator = YES;
        numberFormatter.groupingSeparator = @",";
        numberFormatter.groupingSize = 3;
        cell.pointsLabel.text=[NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:feed.user.points.balance]]];
        
        if([feed.contest.type isEqualToString:kContestTypeNational]){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.contest.bigPictureUrl]];
            __weak UIImageView *weakImageView = cell.contestImageView;
            weakImageView.image = nil;
            [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.contest.sponsor.pictureUrl]];
            __weak UIImageView *weakImageView = cell.contestImageView;
            weakImageView.image = nil;
            [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }

        if(feed.user.picture && feed.user.picture.length>0){
            cell.initialsLabel.hidden = YES;
            NSMutableURLRequest *request2=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.user.picture]];
            __weak UIImageView *weakImageView2 = cell.winnerImageView;
            weakImageView2.image = nil;
            [cell.winnerImageView setImageWithURLRequest:request2 placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView2 setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.initialsLabel.hidden = NO;
            cell.winnerImageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
            cell.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[feed.user.firstName.uppercaseString substringToIndex:1],[feed.user.lastName.uppercaseString substringToIndex:1]];
        }
        
        return cell;
    }
    else if([feed.action isEqualToString:@"pool-winner"]){
        FeedCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PoolWinnerCell"];
        if(cell == nil){
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:self options:nil];
            cell = (FeedCell *)[nib objectAtIndex:2];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contestWinnerTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
            [cell.contestWinnerLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.pointsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.winnerImageView.layer setCornerRadius:cell.winnerImageView.bounds.size.width/2];
            [cell.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        }
        cell.contestWinnerLabel.text=[NSString stringWithFormat:@"%@ %@",feed.user.firstName.uppercaseString,feed.user.lastName.uppercaseString];
        cell.contestWinnerTitleLabel.text=[NSString stringWithFormat:@"%@ WINNER",feed.pool.title.uppercaseString];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.usesGroupingSeparator = YES;
        numberFormatter.groupingSeparator = @",";
        numberFormatter.groupingSize = 3;
        cell.pointsLabel.text=[NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:feed.user.points.balance]]];
        
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.pool.poolType.image]];
        __weak UIImageView *weakImageView = cell.contestImageView;
        weakImageView.image = nil;
        [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
        
        
        
        if(feed.user.picture && feed.user.picture.length>0){
            cell.initialsLabel.hidden = YES;
            NSMutableURLRequest *request2=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.user.picture]];
            __weak UIImageView *weakImageView2 = cell.winnerImageView;
            weakImageView2.image = nil;
            [cell.winnerImageView setImageWithURLRequest:request2 placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView2 setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.initialsLabel.hidden = NO;
            cell.winnerImageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
            cell.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[feed.user.firstName.uppercaseString substringToIndex:1],[feed.user.lastName.uppercaseString substringToIndex:1]];
        }
        
        return cell;
    }
    else if([feed.action isEqualToString:@"pool-invite"]){
        FeedCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PoolInviteCell"];
        if(cell == nil){
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:self options:nil];
            cell = (FeedCell *)[nib objectAtIndex:3];
            cell.backgroundColor = [UIColor clearColor];
            [cell.PoolTitle setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.PoolCreator setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.PoolInviteMessage setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:13.0]];
            [cell.PoolCreatorImageView.layer setCornerRadius:cell.PoolCreatorImageView.bounds.size.width/2];
            cell.initialsLabel.hidden=YES;
            
        }
       
        if(feed.pool.poolType.image && feed.pool.poolType.image.length>0){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.pool.poolType.image]];
            __weak UIImageView *weakImageView = cell.poolTypeImage;
            weakImageView.image = nil;
            [cell.poolTypeImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                UIImage *bluredImage=[image applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
                [weakImageView setImage:bluredImage];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        
        if(feed.pool.creator.picture && feed.pool.creator.picture.length>0){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.pool.creator.picture]];
            __weak UIImageView *weakImageView = cell.PoolCreatorImageView;
            weakImageView.image = nil;
            [cell.PoolCreatorImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }else{
            [cell.PoolCreatorImageView setImage:nil];
            [cell.PoolCreatorImageView setBackgroundColor:[UIColor clearColor]];
            cell.PoolCreatorImageView.layer.borderColor=[UIColor whiteColor].CGColor;
            cell.PoolCreatorImageView.layer.borderWidth=2.0f;
            cell.initialsLabel.hidden=NO;
            cell.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[feed.pool.creator.firstName.uppercaseString substringToIndex:1],[feed.pool.creator.lastName.uppercaseString substringToIndex:1]];
          
        }
        
        NSString *InviteMessage=[NSString stringWithFormat:@"%@ has invited you. Click 'Join Now' & start betting with friends!",feed.pool.creator.firstName];
        
        InviteMessage=[NSString stringWithFormat:@"%@",feed.pool.poolType.subtitle];
        
        cell.PoolCreator.text=[NSString stringWithFormat:@"%@ %@",feed.pool.creator.firstName.uppercaseString,feed.pool.creator.lastName.uppercaseString];
        cell.PoolTitle.text = feed.pool.poolType.title;
        if(feed.pool.joined){
            cell.joinNowButtonImageView.hidden=YES;
            //cell.PoolInviteMessage.hidden=YES;
            cell.PoolSubTitle.text =InviteMessage;
        }
        else{
            cell.joinNowButtonImageView.hidden=NO;
            cell.PoolSubTitle.text =InviteMessage;
        }
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed=[self.feeds objectAtIndex:indexPath.row];
    if([feed.action isEqualToString:@"pool-winner"]){
        Pool *pool=feed.pool;
        if(pool.joined){
            UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
            PoolDetailsViewController *poolDetailsViewController=[[PoolDetailsViewController alloc] initWithBackgroundImage:blurImage pool:pool];
            UINavigationController *poolDetailsNavigationController=[[UINavigationController alloc] initWithRootViewController:poolDetailsViewController];
            poolDetailsNavigationController.navigationBarHidden=YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:poolDetailsNavigationController animated:YES completion:^{}];
            });
        }
    }
    else if([feed.action isEqualToString:@"pool-invite"]){
    
        Pool *pool=feed.pool;
        
        if(pool.joined){
            UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
            PoolDetailsViewController *poolDetailsViewController = [[PoolDetailsViewController alloc] initWithBackgroundImage:blurImage pool:pool];
            UINavigationController *poolDetailsNavigationController = [[UINavigationController alloc] initWithRootViewController:poolDetailsViewController];
            [poolDetailsNavigationController setNavigationBarHidden:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.parentViewController presentViewController:poolDetailsNavigationController animated:YES completion:^{}];
            });
        }
        else{
            UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
            PoolsInfoViewController *poolsInfoViewController=[[PoolsInfoViewController alloc] initWithBackgroundImage:blurImage pool:pool];
            poolsInfoViewController.delegate=self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.parentViewController presentViewController:poolsInfoViewController animated:YES completion:^{}];
            });
        }
        
    }
    else{
        Contest *contest=feed.contest;
        if(contest.joined){
            UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
            ContestDetailsViewController *contestDetailsViewController=[[ContestDetailsViewController alloc] initWithBackgroundImage:blurImage contest:contest];
            UINavigationController *contestDetailsNavigationController=[[UINavigationController alloc] initWithRootViewController:contestDetailsViewController];
            contestDetailsNavigationController.navigationBarHidden=YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:contestDetailsNavigationController animated:YES completion:^{}];
            });
        }
        else{
            UIImage *blurImage=[self.navigationController.parentViewController.view lightBlurImage];
            ContestInfoViewController *contestInfoViewController=[[ContestInfoViewController alloc] initWithBackgroundImage:blurImage contest:contest game:nil];
            contestInfoViewController.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:contestInfoViewController animated:YES completion:^{}];
            });
        }
    }
}

-(IBAction)startBettingAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartBetting" object:nil];
}

-(void)contestInfoViewController:(ContestInfoViewController *)contestInfoViewController didJoinContest:(Contest *)contest{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        ContestDetailsViewController *contestDetailsViewController=[[ContestDetailsViewController alloc] initWithBackgroundImage:blurImage contest:contest];
        UINavigationController *contestDetailsNavigationController=[[UINavigationController alloc] initWithRootViewController:contestDetailsViewController];
        contestDetailsNavigationController.navigationBarHidden=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:contestDetailsNavigationController animated:YES completion:^{}];
        });
    }];
}

-(void)poolsInfoViewController:(PoolsInfoViewController *)poolsInfoViewController didJoinPool:(Pool *)pool{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        PoolDetailsViewController *poolDetailsViewController=[[PoolDetailsViewController alloc] initWithBackgroundImage:blurImage pool:pool];
        UINavigationController *poolDetailsNavigationViewController=[[UINavigationController alloc] initWithRootViewController:poolDetailsViewController];
        poolDetailsNavigationViewController.navigationBarHidden=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:poolDetailsNavigationViewController animated:YES completion:^{}];
        });
    }];
}
@end